import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flowpay/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flowpay/features/auth/presentation/pages/login_page.dart';
import 'package:flowpay/features/profile_and_setting/presentation/cubit/profile_cubit.dart';
import 'package:flowpay/start_pages/components/main_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../helpers/app_animation.dart';
import '../../../../helpers/ui_responsive_helper.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});
  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _loading = false;
  bool _saving = false;
  String _cnic = '';
  String? _imgUrl;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    setState(() => _loading = true);
    try {
      final uDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final acctQ =
          await FirebaseFirestore.instance
              .collection('accounts')
              .where('userId', isEqualTo: uid)
              .limit(1)
              .get();
      if (mounted) {
        final d = uDoc.data() ?? {};
        setState(() {
          _nameCtrl.text = d['name'] ?? '';
          _cnic = d['cnic'] ?? 'Not set';
          _imgUrl = d['profileImageUrl'];
          if (acctQ.docs.isNotEmpty) {
            _phoneCtrl.text = acctQ.docs.first.data()['phone'] ?? '';
          }
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    if (name.isEmpty) {
      _snack('Name cannot be empty', err: true);
      return;
    }
    if (phone.isEmpty || phone.length < 10) {
      _snack('Enter a valid phone number', err: true);
      return;
    }
    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'name': name,
      });
      final q =
          await FirebaseFirestore.instance
              .collection('accounts')
              .where('userId', isEqualTo: uid)
              .limit(1)
              .get();
      if (q.docs.isNotEmpty) {
        await q.docs.first.reference.update({'phone': phone});
      }
      if (mounted) {
        await context.read<ProfileCubit>().fetchProfileUser(uid);
        _snack('Profile updated successfully');
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) Navigator.pop(context);
      }
    } catch (_) {
      _snack('Failed to update. Try again.', err: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showCloseDialog() {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppResponsive.radiusLg),
            ),
            title: const Text(
              'Close Account',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
            content: const Text(
              'This is permanent and cannot be undone. Your profile, '
              'transactions and all data will be deleted forever.',
              style: TextStyle(color: Color(0xff737373), height: 1.5),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Color(0xff737373)),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _delete();
                },
                child: const Text(
                  'Yes, Close It',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _delete() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).delete();
      final q =
          await FirebaseFirestore.instance
              .collection('accounts')
              .where('userId', isEqualTo: uid)
              .limit(1)
              .get();
      if (q.docs.isNotEmpty) await q.docs.first.reference.delete();
      await FirebaseAuth.instance.currentUser?.delete();
      if (mounted) {
        await context.read<AuthCubit>().logout();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => LoginPage(onTap: () {})),
          (r) => false,
        );
      }
    } catch (_) {
      _snack('Failed to close account. Try again.', err: true);
      setState(() => _saving = false);
    }
  }

  void _snack(String msg, {bool err = false}) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: err ? Colors.red : Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppResponsive.radiusSm),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios, size: 20),
        ),
        title: Text(
          'Profile Setting',
          style: TextStyle(
            fontSize: AppResponsive.fs(15),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : AppAnimatedPage(
                direction: SlideDirection.bottom,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: AppResponsive.w(25),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: AppResponsive.h(20)),

                      // Avatar
                      AppAnimatedItem(
                        index: 0,
                        direction: SlideDirection.bottom,
                        child: Center(
                          child: AppScaleIn(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                AppResponsive.radiusLg,
                              ),
                              child: Container(
                                height: AppResponsive.sp(96),
                                width: AppResponsive.sp(96),
                                color: const Color(0xffDFE5FF),
                                child:
                                    (_imgUrl?.isNotEmpty ?? false)
                                        ? Image.network(
                                          _imgUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (_, __, ___) => Icon(
                                                Icons.person,
                                                size: AppResponsive.sp(46),
                                                color: const Color(0xff3B6FE8),
                                              ),
                                        )
                                        : Icon(
                                          Icons.person,
                                          size: AppResponsive.sp(46),
                                          color: const Color(0xff3B6FE8),
                                        ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: AppResponsive.h(28)),

                      // Name
                      AppAnimatedItem(
                        index: 1,
                        direction: SlideDirection.left,
                        child: _Label('Full Name'),
                      ),
                      SizedBox(height: AppResponsive.h(8)),
                      AppAnimatedItem(
                        index: 1,
                        direction: SlideDirection.left,
                        child: _EditField(
                          controller: _nameCtrl,
                          hint: 'Enter your full name',
                          icon: Icons.person_outline,
                        ),
                      ),

                      SizedBox(height: AppResponsive.h(14)),

                      // Phone
                      AppAnimatedItem(
                        index: 2,
                        direction: SlideDirection.right,
                        child: _Label('Phone Number'),
                      ),
                      SizedBox(height: AppResponsive.h(8)),
                      AppAnimatedItem(
                        index: 2,
                        direction: SlideDirection.right,
                        child: _EditField(
                          controller: _phoneCtrl,
                          hint: 'Enter your phone number',
                          icon: Icons.phone_outlined,
                          type: TextInputType.phone,
                        ),
                      ),

                      SizedBox(height: AppResponsive.h(14)),

                      // CNIC (read-only)
                      AppAnimatedItem(
                        index: 3,
                        direction: SlideDirection.left,
                        child: _Label('CNIC'),
                      ),
                      SizedBox(height: AppResponsive.h(8)),
                      AppAnimatedItem(
                        index: 3,
                        direction: SlideDirection.left,
                        child: _ReadField(
                          value: _cnic,
                          icon: Icons.badge_outlined,
                          onCopy: () {
                            Clipboard.setData(ClipboardData(text: _cnic));
                            _snack('CNIC copied!');
                          },
                        ),
                      ),

                      SizedBox(height: AppResponsive.h(8)),
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: AppResponsive.sp(13),
                            color: const Color(0xffA3A3A3),
                          ),
                          SizedBox(width: AppResponsive.w(5)),
                          Text(
                            'CNIC cannot be changed after registration.',
                            style: TextStyle(
                              fontSize: AppResponsive.fs(10),
                              color: const Color(0xffA3A3A3),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: AppResponsive.h(36)),

                      // Save
                      AppAnimatedItem(
                        index: 4,
                        direction: SlideDirection.bottom,
                        child: MainButton(
                          buttonName: _saving ? 'Saving...' : 'Save Changes',
                          onTap: _saving ? () {} : _save,
                        ),
                      ),

                      SizedBox(height: AppResponsive.h(16)),

                      // Close account
                      AppAnimatedItem(
                        index: 5,
                        direction: SlideDirection.bottom,
                        child: GestureDetector(
                          onTap: _showCloseDialog,
                          child: Container(
                            width: double.infinity,
                            height: AppResponsive.h(52),
                            decoration: BoxDecoration(
                              color: const Color(0xffFFEAEC),
                              borderRadius: BorderRadius.circular(
                                AppResponsive.radiusMd,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                  size: AppResponsive.sp(18),
                                ),
                                SizedBox(width: AppResponsive.w(8)),
                                Text(
                                  'Close Account',
                                  style: TextStyle(
                                    fontSize: AppResponsive.fs(14),
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: AppResponsive.h(36)),
                    ],
                  ),
                ),
              ),
    );
  }
}

class _Label extends StatelessWidget {
  final String t;
  const _Label(this.t);
  @override
  Widget build(BuildContext context) => Text(
    t,
    style: TextStyle(
      fontSize: AppResponsive.fs(13),
      fontWeight: FontWeight.w500,
      color: Colors.black87,
    ),
  );
}

class _EditField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType type;
  const _EditField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.type = TextInputType.text,
  });
  @override
  Widget build(BuildContext context) => Container(
    height: AppResponsive.h(52),
    decoration: BoxDecoration(
      color: const Color(0xffFBFCFF),
      borderRadius: BorderRadius.circular(AppResponsive.radiusMd),
      border: Border.all(color: const Color(0xffDEE0E5)),
    ),
    child: Row(
      children: [
        SizedBox(width: AppResponsive.w(12)),
        Icon(icon, size: AppResponsive.sp(18), color: const Color(0xff737373)),
        SizedBox(width: AppResponsive.w(10)),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: type,
            style: TextStyle(fontSize: AppResponsive.fs(13)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: const Color(0xffA3A3A3),
                fontSize: AppResponsive.fs(13),
              ),
              border: InputBorder.none,
              isDense: true,
            ),
          ),
        ),
        SizedBox(width: AppResponsive.w(12)),
      ],
    ),
  );
}

class _ReadField extends StatelessWidget {
  final String value;
  final IconData icon;
  final VoidCallback? onCopy;
  const _ReadField({required this.value, required this.icon, this.onCopy});
  @override
  Widget build(BuildContext context) => Container(
    height: AppResponsive.h(52),
    decoration: BoxDecoration(
      color: const Color(0xffF5F5F5),
      borderRadius: BorderRadius.circular(AppResponsive.radiusMd),
      border: Border.all(color: const Color(0xffEEEEEE)),
    ),
    child: Row(
      children: [
        SizedBox(width: AppResponsive.w(12)),
        Icon(icon, size: AppResponsive.sp(18), color: const Color(0xffA3A3A3)),
        SizedBox(width: AppResponsive.w(10)),
        Expanded(
          child: Text(
            value.isEmpty ? 'Not set' : value,
            style: TextStyle(
              fontSize: AppResponsive.fs(13),
              color: const Color(0xff737373),
              letterSpacing: 0.5,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (value.isNotEmpty && value != 'Not set' && onCopy != null)
          GestureDetector(
            onTap: onCopy,
            child: Padding(
              padding: EdgeInsets.only(right: AppResponsive.w(12)),
              child: Icon(
                Icons.copy_outlined,
                size: AppResponsive.sp(16),
                color: const Color(0xff3B6FE8),
              ),
            ),
          )
        else
          Padding(
            padding: EdgeInsets.only(right: AppResponsive.w(12)),
            child: Icon(
              Icons.lock_outline,
              size: AppResponsive.sp(14),
              color: const Color(0xffA3A3A3),
            ),
          ),
      ],
    ),
  );
}
