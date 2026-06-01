import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flowpay/features/auth/domain/entities/app_user.dart';

/// ─────────────────────────────────────────────────────
/// FavouritesService
///
/// Manages the  users/{uid}/favourites  sub-collection.
///
/// Usage (from FavPlusMoneyBtn or TransferMoney):
///   await FavouritesService.addFavourite(receiver);
///   final isFav = await FavouritesService.isFavourite(receiverUid);
///   await FavouritesService.removeFavourite(receiverUid);
/// ─────────────────────────────────────────────────────
class FavouritesService {
  static final _firestore = FirebaseFirestore.instance;

  static String get _currentUid => FirebaseAuth.instance.currentUser!.uid;

  static CollectionReference _favsRef(String uid) =>
      _firestore.collection('users').doc(uid).collection('favourites');

  // ── ADD ──
  static Future<void> addFavourite(AppUser receiver) async {
    final ref = _favsRef(_currentUid).doc(receiver.uid);
    await ref.set({
      'userId': receiver.uid,
      'name': receiver.name,
      'email': receiver.email,
      'phone': receiver.account?.phone ?? '',
      'profileImageUrl': receiver.profileImageUrl ?? '',
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── REMOVE ──
  static Future<void> removeFavourite(String receiverUid) async {
    await _favsRef(_currentUid).doc(receiverUid).delete();
  }

  // ── CHECK ──
  static Future<bool> isFavourite(String receiverUid) async {
    final doc = await _favsRef(_currentUid).doc(receiverUid).get();
    return doc.exists;
  }

  // ── TOGGLE (add if not fav, remove if already fav) ──
  static Future<bool> toggleFavourite(AppUser receiver) async {
    final already = await isFavourite(receiver.uid);
    if (already) {
      await removeFavourite(receiver.uid);
      return false; // now NOT a favourite
    } else {
      await addFavourite(receiver);
      return true; // now IS a favourite
    }
  }
}
