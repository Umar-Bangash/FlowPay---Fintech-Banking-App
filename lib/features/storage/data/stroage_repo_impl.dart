import 'dart:io';
import 'dart:typed_data';
import 'package:flowpay/features/storage/domain/storage_repo.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StroageRepoImpl implements StorageRepo {
  final SupabaseClient supabase = Supabase.instance.client;
  final String bucket = 'profileImages'; // Your Supabase bucket name

  /* 
  
    PROFILE PICTURES: upload images to supabase storage (bucket -> files)  
  
  */

  @override
  Future<String?> uploadProfileImageMobile(String path, String uid) async {
    return await _uploadFile(path, uid, 'profiles');
  }

  @override
  Future<String?> uploadProfileImageWeb(Uint8List fileBytes, String uid) async {
    return await _uploadFileBytes(fileBytes, uid, 'profiles');
  }

  /* 
  
    POST PICTURES: upload images to supabase storage (bucket -> posts)  
  
  */
  @override
  Future<String?> uploadPostImageMobile(String path, String uid) async {
    return await _uploadFile(path, uid, 'posts');
  }

  @override
  Future<String?> uploadPostImageWeb(Uint8List fileBytes, String uid) async {
    return await _uploadFileBytes(fileBytes, uid, 'posts');
  }

  /* 
  
    HELPERs METHODs  
  
  */

  // Mobile upload helper
  Future<String?> _uploadFile(String path, String uid, String folder) async {
    try {
      final file = File(path);

      // Generate unique filename with timestamp
      final storagePath =
          '$folder/$uid/profile_${DateTime.now().millisecondsSinceEpoch}.png';

      // Upload
      await supabase.storage
          .from(bucket)
          .upload(
            storagePath,
            file,
            fileOptions: const FileOptions(upsert: true),
          );

      // Get public URL
      final downloadUrl = supabase.storage
          .from(bucket)
          .getPublicUrl(storagePath);

      // Return URL
      return downloadUrl;
    } catch (e) {
      debugPrint("Upload error: $e");
      return null;
    }
  }

  // Web upload helper
  Future<String?> _uploadFileBytes(
    Uint8List fileBytes,
    String uid,
    String folder,
  ) async {
    try {
      // Generate unique filename with timestamp
      final storagePath =
          '$folder/$uid/profile_${DateTime.now().millisecondsSinceEpoch}.png';

      // Upload
      await supabase.storage
          .from(bucket)
          .uploadBinary(
            storagePath,
            fileBytes,
            fileOptions: const FileOptions(upsert: true),
          );

      final downloadUrl = supabase.storage
          .from(bucket)
          .getPublicUrl(storagePath);

      return downloadUrl;
    } catch (e) {
      debugPrint("Upload error: $e");
      return null;
    }
  }
}
