import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flowpay/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flowpay/features/auth/presentation/pages/login_page.dart';
import 'package:flowpay/features/profile_and_setting/presentation/cubit/profile_cubit.dart';
import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'package:flowpay/start_pages/components/main_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  bool _isSaving = false;
  String _cnic = '';
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ─────────────────────────────────────────────
  // LOAD ALL DATA
  // ─────────────────────────────────────────────
  Future<void> _loadData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _isLoading = true);

    try {
      // users collection
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      // accounts collection
      final accountQuery =
          await FirebaseFirestore.instance
              .collection('accounts')
              .where('userId', isEqualTo: uid)
              .limit(1)
              .get();

      if (mounted) {
        final data = userDoc.data() ?? {};
        setState(() {
          _nameController.text = data['name'] ?? '';
          _cnic = data['cnic'] ?? 'Not set';
          _profileImageUrl = data['profileImageUrl'];
          if (accountQuery.docs.isNotEmpty) {
            _phoneController.text =
                accountQuery.docs.first.data()['phone'] ?? '';
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─────────────────────────────────────────────
  // SAVE NAME + PHONE
  // ─────────────────────────────────────────────
  Future<void> _saveChanges() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty) {
      _showSnack('Name cannot be empty', isError: true);
      return;
    }
    if (phone.isEmpty || phone.length < 10) {
      _showSnack('Enter a valid phone number', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Update name in users
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'name': name,
      });

      // Update phone in accounts
      final accountQuery =
          await FirebaseFirestore.instance
              .collection('accounts')
              .where('userId', isEqualTo: uid)
              .limit(1)
              .get();

      if (accountQuery.docs.isNotEmpty) {
        await accountQuery.docs.first.reference.update({'phone': phone});
      }

      // Refresh profile cubit
      if (mounted) {
        await context.read<ProfileCubit>().fetchProfileUser(uid);
        _showSnack('Profile updated successfully');
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      _showSnack('Failed to update. Try again.', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ─────────────────────────────────────────────
  // CLOSE ACCOUNT
  // ─────────────────────────────────────────────
  void _showCloseAccountDialog() {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'Close Account',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.red,
              ),
            ),
            content: const Text(
              'This is permanent and cannot be undone. '
              'Your profile, transactions and all data '
              'will be deleted forever.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xff737373),
                height: 1.5,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Color(0xff737373),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _deleteAccount();
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

  Future<void> _deleteAccount() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _isSaving = true);

    try {
      // Delete user doc
      await FirebaseFirestore.instance.collection('users').doc(uid).delete();

      // Delete account doc
      final accountQuery =
          await FirebaseFirestore.instance
              .collection('accounts')
              .where('userId', isEqualTo: uid)
              .limit(1)
              .get();
      if (accountQuery.docs.isNotEmpty) {
        await accountQuery.docs.first.reference.delete();
      }

      // Delete Firebase Auth user
      await FirebaseAuth.instance.currentUser?.delete();

      if (mounted) {
        await context.read<AuthCubit>().logout();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => LoginPage(onTap: () {})),
          (route) => false,
        );
      }
    } catch (e) {
      _showSnack('Failed to close account. Try again.', isError: true);
      setState(() => _isSaving = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xffFFFFFF),
        centerTitle: true,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios, size: 20),
        ),
        title: const Text(
          'Profile Setting',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: context.padSymmetricPx(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    context.spaceHPx(20),

                    // ── Profile picture ──
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            height: context.hPx(100),
                            width: context.wPx(100),
                            decoration: BoxDecoration(
                              color: const Color(0xffDFE5FF),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: const Color(0xffF2F2F2),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child:
                                  (_profileImageUrl != null &&
                                          _profileImageUrl!.isNotEmpty)
                                      ? Image.network(
                                        _profileImageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (c, e, s) => const Icon(
                                              Icons.person,
                                              size: 50,
                                              color: Color(0xff3B6FE8),
                                            ),
                                      )
                                      : const Icon(
                                        Icons.person,
                                        size: 50,
                                        color: Color(0xff3B6FE8),
                                      ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    context.spaceHPx(30),

                    // ── Name ──
                    _fieldLabel('Full Name'),
                    context.spaceHPx(8),
                    _editableField(
                      controller: _nameController,
                      hint: 'Enter your full name',
                      icon: Icons.person_outline,
                    ),

                    context.spaceHPx(16),

                    // ── Phone ──
                    _fieldLabel('Phone Number'),
                    context.spaceHPx(8),
                    _editableField(
                      controller: _phoneController,
                      hint: 'Enter your phone number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),

                    context.spaceHPx(16),

                    // ── CNIC read only ──
                    _fieldLabel('CNIC'),
                    context.spaceHPx(8),
                    _readOnlyField(
                      value: _cnic,
                      icon: Icons.badge_outlined,
                      onCopy: () {
                        Clipboard.setData(ClipboardData(text: _cnic));
                        _showSnack('CNIC copied!');
                      },
                    ),

                    context.spaceHPx(12),

                    // CNIC info note
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 14,
                          color: Color(0xffA3A3A3),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'CNIC cannot be changed after registration.',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xffA3A3A3),
                          ),
                        ),
                      ],
                    ),

                    context.spaceHPx(40),

                    // ── Save button ──
                    Center(
                      child: MainButton(
                        buttonName: _isSaving ? 'Saving...' : 'Save Changes',
                        onTap: _isSaving ? () {} : _saveChanges,
                      ),
                    ),

                    context.spaceHPx(20),

                    // ── Close account ──
                    GestureDetector(
                      onTap: _showCloseAccountDialog,
                      child: Container(
                        height: context.hPx(54),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xffFFEAEC),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Close Account',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    context.spaceHPx(40),
                  ],
                ),
              ),
    );
  }

  // ─────────────────────────────────────────────
  // WIDGETS
  // ─────────────────────────────────────────────
  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
    );
  }

  Widget _editableField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: const Color(0xffFBFCFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffDEE0E5)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(icon, size: 20, color: const Color(0xff737373)),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  color: Color(0xffA3A3A3),
                  fontSize: 14,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 14),
        ],
      ),
    );
  }

  Widget _readOnlyField({
    required String value,
    required IconData icon,
    VoidCallback? onCopy,
  }) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: const Color(0xffF5F5F5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffEEEEEE)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(icon, size: 20, color: const Color(0xffA3A3A3)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value.isEmpty ? 'Not set' : value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xff737373),
                letterSpacing: 0.5,
              ),
            ),
          ),
          // Copy button if value exists
          if (value.isNotEmpty && value != 'Not set' && onCopy != null)
            GestureDetector(
              onTap: onCopy,
              child: const Padding(
                padding: EdgeInsets.only(right: 14),
                child: Icon(
                  Icons.copy_outlined,
                  size: 18,
                  color: Color(0xff3B6FE8),
                ),
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.only(right: 14),
              child: Icon(
                Icons.lock_outline,
                size: 16,
                color: Color(0xffA3A3A3),
              ),
            ),
        ],
      ),
    );
  }
}
