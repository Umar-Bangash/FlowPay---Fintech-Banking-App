// This repo outline the functionality of Needed for Face Authentication .

abstract class FaceAuthRepo {
  // Registration: capture embedding → store in Firestore
  Future<void> registerFaceEmbedding({
    required String uid,
    required List<int> imageBytes,
  });

  // Verification: capture embedding → compare with stored → return bool
  Future<bool> verifyFace({required String uid, required List<int> imageBytes});

  // Check if user has registered face
  Future<bool> hasFaceRegistered(String uid);

  // Delete face embedding (optional, for reset)
  Future<void> deleteFaceEmbedding(String uid);
}
