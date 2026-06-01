import 'package:cloud_firestore/cloud_firestore.dart';

Future<String?> getProfileImage(String? receiverId) async {
  if (receiverId == null || receiverId.isEmpty) return null;
  try {
    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(receiverId)
            .get();
    return doc.data()?['profileImageUrl'];
  } catch (_) {
    return null;
  }
}
