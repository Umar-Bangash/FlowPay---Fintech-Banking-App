import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flowpay/features/auth/domain/repo/face_auth_repo.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class FaceAuthRepoImpl implements FaceAuthRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Your friend's HF endpoint
  static const String _embedUrl = 'https://hamadalikhan-faceapi.hf.space/embed';

  // Similarity threshold — tune this (0.80 = lenient, 0.90 = strict)
  static const double _threshold = 0.85;

  // ─────────────────────────────────────────────
  // STEP 1: Call HF API → get embedding vector
  // Tries 'image' field first, then 'file' field
  // ─────────────────────────────────────────────
  Future<List<double>?> _getEmbedding(List<int> imageBytes) async {
    // Try with field name 'image' first
    List<double>? result = await _callEmbedApi(imageBytes, fieldName: 'image');

    // If failed, try with field name 'file'
    result ??= await _callEmbedApi(imageBytes, fieldName: 'file');

    return result;
  }

  Future<List<double>?> _callEmbedApi(
    List<int> imageBytes, {
    required String fieldName,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(_embedUrl));

      request.files.add(
        http.MultipartFile.fromBytes(
          fieldName,
          imageBytes,
          filename: 'face.jpg',
        ),
      );

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 15),
      );
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('FaceAPI [$fieldName] status: ${response.statusCode}');
      debugPrint('FaceAPI [$fieldName] body: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        // Handle possible response formats:
        // { "embedding": [...] }  or  { "embeddings": [...] }  or  [...]
        List<dynamic>? rawList;

        if (json is List) {
          rawList = json;
        } else if (json is Map) {
          rawList =
              json['embedding'] ??
              json['embeddings'] ??
              json['vector'] ??
              json['data'];
        }

        if (rawList != null) {
          return rawList.map((e) => (e as num).toDouble()).toList();
        }
      }

      return null;
    } catch (e) {
      debugPrint('_callEmbedApi error [$fieldName]: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────
  // STEP 2: Cosine Similarity between 2 vectors
  // Returns value between -1 and 1
  // Closer to 1 = same face
  // ─────────────────────────────────────────────
  double _cosineSimilarity(List<double> a, List<double> b) {
    if (a.length != b.length) {
      throw Exception(
        'Embedding dimension mismatch: ${a.length} vs ${b.length}',
      );
    }

    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;

    for (int i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }

    if (normA == 0.0 || normB == 0.0) return 0.0;

    return dotProduct / (sqrt(normA) * sqrt(normB));
  }

  // ─────────────────────────────────────────────
  // REGISTER: get embedding → store in Firestore
  // ─────────────────────────────────────────────
  @override
  Future<void> registerFaceEmbedding({
    required String uid,
    required List<int> imageBytes,
  }) async {
    try {
      final embedding = await _getEmbedding(imageBytes);

      if (embedding == null || embedding.isEmpty) {
        throw Exception('Could not generate face embedding. Please try again.');
      }

      debugPrint('Embedding generated: ${embedding.length} dimensions');

      // Store in Firestore under users/{uid}
      await _firestore.collection('users').doc(uid).update({
        'faceEmbedding': embedding, // vector stored as List<double>
        'faceRegisteredAt': FieldValue.serverTimestamp(),
        'faceEnabled': true,
      });

      debugPrint('Face embedding stored successfully for uid: $uid');
    } catch (e) {
      debugPrint('registerFaceEmbedding error: $e');
      rethrow;
    }
  }

  // ─────────────────────────────────────────────
  // VERIFY: get embedding → fetch stored → compare
  // ─────────────────────────────────────────────
  @override
  Future<bool> verifyFace({
    required String uid,
    required List<int> imageBytes,
  }) async {
    try {
      // 1. Get live embedding from camera image
      final liveEmbedding = await _getEmbedding(imageBytes);

      if (liveEmbedding == null || liveEmbedding.isEmpty) {
        throw Exception('Could not process face. Please try again.');
      }

      // 2. Fetch stored embedding from Firestore
      final userDoc = await _firestore.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        throw Exception('User not found');
      }

      final data = userDoc.data();
      final rawStored = data?['faceEmbedding'] as List<dynamic>?;

      if (rawStored == null || rawStored.isEmpty) {
        throw Exception('No face registered for this user');
      }

      final storedEmbedding =
          rawStored.map((e) => (e as num).toDouble()).toList();

      // 3. Compare using cosine similarity
      final similarity = _cosineSimilarity(liveEmbedding, storedEmbedding);

      debugPrint('Face similarity score: $similarity (threshold: $_threshold)');

      return similarity >= _threshold;
    } catch (e) {
      debugPrint('verifyFace error: $e');
      rethrow;
    }
  }

  // ─────────────────────────────────────────────
  // CHECK: does user have a registered face?
  // ─────────────────────────────────────────────
  @override
  Future<bool> hasFaceRegistered(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      final data = doc.data();
      final embedding = data?['faceEmbedding'];
      final faceEnabled = data?['faceEnabled'] ?? false;
      return embedding != null && faceEnabled == true;
    } catch (e) {
      debugPrint('hasFaceRegistered error: $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // DELETE: reset face registration
  // ─────────────────────────────────────────────
  @override
  Future<void> deleteFaceEmbedding(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'faceEmbedding': FieldValue.delete(),
      'faceEnabled': false,
      'faceRegisteredAt': FieldValue.delete(),
    });
  }
}
