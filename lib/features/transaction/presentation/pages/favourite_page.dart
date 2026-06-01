import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flowpay/features/account/domain/entities/account.dart';
import 'package:flowpay/features/auth/domain/entities/app_user.dart';
import 'package:flowpay/features/transaction/presentation/pages/transfer_money.dart';
import 'package:flutter/material.dart';
import '../../../../helpers/app_animation.dart';
import '../../../../helpers/ui_responsive_helper.dart';

class FavouritesPage extends StatefulWidget {
  const FavouritesPage({super.key});
  @override
  State<FavouritesPage> createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage>
    with SingleTickerProviderStateMixin {
  final _uid = FirebaseAuth.instance.currentUser!.uid;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  CollectionReference get _favsRef => FirebaseFirestore.instance
      .collection('users')
      .doc(_uid)
      .collection('favourites');

  Future<void> _remove(String docId, String name) async {
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppResponsive.radiusLg),
            ),
            title: Text(
              'Remove Favourite',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: AppResponsive.fs(16),
              ),
            ),
            content: Text(
              'Remove $name from favourites?',
              style: TextStyle(fontSize: AppResponsive.fs(13)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: const Color(0xff737373),
                    fontSize: AppResponsive.fs(13),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'Remove',
                  style: TextStyle(
                    color: const Color(0xffEB5757),
                    fontSize: AppResponsive.fs(13),
                  ),
                ),
              ),
            ],
          ),
    );
    if (ok == true) {
      await _favsRef.doc(docId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$name removed from favourites'),
            backgroundColor: const Color(0xffEB5757),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppResponsive.radiusMd),
            ),
          ),
        );
      }
    }
  }

  void _goToTransfer(Map<String, dynamic> data) {
    final receiver = AppUser(
      uid: data['userId'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      profileImageUrl: data['profileImageUrl'],
    );
    receiver.account = Account(
      userId: data['userId'] ?? '',
      phone: data['phone'] ?? '',
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TransferMoney(receiver: receiver)),
    );
  }

  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        title: Text(
          'Favourites',
          style: TextStyle(
            fontSize: AppResponsive.fs(16),
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: StreamBuilder<QuerySnapshot>(
          stream: _favsRef.orderBy('addedAt', descending: true).snapshots(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xff007AFF)),
              );
            }
            if (snap.hasError) {
              return Center(child: Text('Error: ${snap.error}'));
            }
            final docs = snap.data?.docs ?? [];
            if (docs.isEmpty) return _emptyState();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppResponsive.w(25),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: AppResponsive.h(14)),
                      Text(
                        '${docs.length} saved ${docs.length == 1 ? 'contact' : 'contacts'}',
                        style: TextStyle(
                          fontSize: AppResponsive.fs(12),
                          color: const Color(0xff737373),
                        ),
                      ),
                      SizedBox(height: AppResponsive.h(3)),
                      Text(
                        'Tap to send money · Long press to remove',
                        style: TextStyle(
                          fontSize: AppResponsive.fs(11),
                          color: const Color(0xffA3A3A3),
                        ),
                      ),
                      SizedBox(height: AppResponsive.h(14)),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppResponsive.w(25),
                    ),
                    itemCount: docs.length,
                    separatorBuilder:
                        (_, __) => SizedBox(height: AppResponsive.h(12)),
                    itemBuilder: (context, i) {
                      final doc = docs[i];
                      final data = doc.data() as Map<String, dynamic>;
                      return AppAnimatedItem(
                        index: i,
                        direction:
                            i.isEven
                                ? SlideDirection.left
                                : SlideDirection.right,
                        child: _FavCard(
                          data: data,
                          docId: doc.id,
                          onTap: () => _goToTransfer(data),
                          onLongPress:
                              () => _remove(doc.id, data['name'] ?? 'User'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _emptyState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: AppResponsive.sp(72),
          width: AppResponsive.sp(72),
          decoration: BoxDecoration(
            color: const Color(0xff007AFF).withOpacity(0.08),
            borderRadius: BorderRadius.circular(AppResponsive.radiusLg),
          ),
          child: Icon(
            Icons.star_outline_rounded,
            size: AppResponsive.sp(32),
            color: const Color(0xff007AFF),
          ),
        ),
        SizedBox(height: AppResponsive.h(14)),
        Text(
          'No favourites yet',
          style: TextStyle(
            fontSize: AppResponsive.fs(15),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppResponsive.h(6)),
        Text(
          'Tap ☆ while sending money\nto save someone here',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppResponsive.fs(12),
            color: const Color(0xff737373),
          ),
        ),
      ],
    ),
  );
}

class _FavCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String docId;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  const _FavCard({
    required this.data,
    required this.docId,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final name = data['name'] ?? 'Unknown';
    final phone = data['phone'] ?? '';
    final imageUrl = data['profileImageUrl'];
    final av = AppResponsive.sp(46);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: EdgeInsets.all(AppResponsive.w(14)),
        decoration: BoxDecoration(
          color: const Color(0xffFBFCFF),
          borderRadius: BorderRadius.circular(AppResponsive.radiusLg),
          border: Border.all(color: const Color(0xffF0F0F0)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppResponsive.radiusMd),
              child: Container(
                width: av,
                height: av,
                color: const Color(0xffCFE8FE),
                child:
                    (imageUrl?.isNotEmpty ?? false)
                        ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) => Icon(
                                Icons.person,
                                color: const Color(0xff007AFF),
                                size: AppResponsive.sp(22),
                              ),
                        )
                        : Icon(
                          Icons.person,
                          color: const Color(0xff007AFF),
                          size: AppResponsive.sp(22),
                        ),
              ),
            ),
            SizedBox(width: AppResponsive.w(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: AppResponsive.fs(14),
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppResponsive.h(3)),
                  Text(
                    'FlowPay  $phone',
                    style: TextStyle(
                      fontSize: AppResponsive.fs(11),
                      color: const Color(0xff737373),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              height: AppResponsive.sp(36),
              width: AppResponsive.sp(36),
              decoration: BoxDecoration(
                color: const Color(0xff007AFF),
                borderRadius: BorderRadius.circular(AppResponsive.radiusMd),
              ),
              child: Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: AppResponsive.sp(16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
