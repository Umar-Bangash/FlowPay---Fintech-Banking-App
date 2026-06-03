import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../helpers/app_animation.dart';
import '../../../../helpers/ui_responsive_helper.dart';

class ContactSearchPage extends StatefulWidget {
  const ContactSearchPage({super.key});

  @override
  State<ContactSearchPage> createState() => _ContactSearchPageState();
}

class _ContactSearchPageState extends State<ContactSearchPage> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;
  Stream<List<Map<String, String>>>? _stream;

  @override
  void initState() {
    super.initState();

    _searchCtrl.addListener(() {
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        final q = _searchCtrl.text.trim();
        if (!mounted) return;
        setState(() => _stream = q.isEmpty ? null : _search(q));
      });
    });
  }

  Stream<List<Map<String, String>>> _search(String phone) async* {
    final snap =
        FirebaseFirestore.instance
            .collection('accounts')
            .where('phone', isEqualTo: phone)
            .snapshots();

    await for (var s in snap) {
      final results = <Map<String, String>>[];

      for (var doc in s.docs) {
        final d = doc.data();
        final userId = d['userId'] as String?;
        if (userId == null) continue;

        final uDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .get();

        if (!uDoc.exists) continue;

        final ud = uDoc.data()!;
        final img = ud['profileImageUrl'];

        results.add({
          'name': ud['name'] ?? 'User',
          'image':
              (img != null && img.toString().isNotEmpty)
                  ? img
                  : 'assets/navigation/profile.png',
          'phone': d['phone'] ?? '',
          'userId': userId,
        });
      }

      yield results;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
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
          child: const Icon(Icons.arrow_back_ios, size: 20),
        ),
        centerTitle: true,
        title: Text(
          'Request Money',
          style: TextStyle(
            fontSize: AppResponsive.fs(17),
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Image.asset(
            'assets/home/notification.png',
            height: AppResponsive.sp(22),
            width: AppResponsive.sp(22),
          ),
          SizedBox(width: AppResponsive.w(20)),
        ],
      ),

      body: AppAnimatedPage(
        direction: SlideDirection.bottom,
        child: SafeArea(
          child: Column(
            children: [
              /// TOP SECTION (NO Expanded here)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppResponsive.w(25)),
                child: AppAnimatedItem(
                  index: 0,
                  direction: SlideDirection.left,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: AppResponsive.h(12)),

                      Text(
                        'Requesting from',
                        style: TextStyle(
                          fontSize: AppResponsive.fs(14),
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      SizedBox(height: AppResponsive.h(12)),

                      ///  SEARCH FIELD
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            AppResponsive.radiusLg,
                          ),
                          border: Border.all(color: const Color(0xffD1D5DC)),
                        ),
                        child: TextFormField(
                          controller: _searchCtrl,
                          style: TextStyle(fontSize: AppResponsive.fs(14)),
                          decoration: InputDecoration(
                            prefixIcon: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppResponsive.w(14),
                              ),
                              child: Image.asset(
                                'assets/transfer/search.png',
                                height: AppResponsive.sp(20),
                                width: AppResponsive.sp(20),
                              ),
                            ),
                            hintText: 'Search by phone...',
                            hintStyle: TextStyle(
                              fontSize: AppResponsive.fs(14),
                              fontWeight: FontWeight.w500,
                              color: const Color(0xffA3A3A3),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: AppResponsive.h(14),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: AppResponsive.h(20)),
                    ],
                  ),
                ),
              ),

              // LIST SECTION (ONLY Expanded here)
              Expanded(
                child:
                    _stream == null
                        ? Center(
                          child: Text(
                            'Enter phone to search',
                            style: TextStyle(
                              fontSize: AppResponsive.fs(14),
                              color: const Color(0xff737373),
                            ),
                          ),
                        )
                        : StreamBuilder<List<Map<String, String>>>(
                          stream: _stream,
                          builder: (context, snap) {
                            if (snap.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (snap.hasError) {
                              return Center(
                                child: Text('Error: ${snap.error}'),
                              );
                            }

                            final contacts = snap.data ?? [];

                            if (contacts.isEmpty) {
                              return Center(
                                child: Text(
                                  'No contact found',
                                  style: TextStyle(
                                    fontSize: AppResponsive.fs(14),
                                    color: const Color(0xff737373),
                                  ),
                                ),
                              );
                            }

                            return ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: contacts.length,
                              itemBuilder: (context, i) {
                                final c = contacts[i];
                                final imgUrl = c['image'] ?? '';
                                final isNet = imgUrl.startsWith('http');

                                return AppAnimatedItem(
                                  index: i,
                                  direction: SlideDirection.left,
                                  child: ListTile(
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: AppResponsive.w(25),
                                      vertical: AppResponsive.h(4),
                                    ),
                                    leading: CircleAvatar(
                                      radius: AppResponsive.sp(22),
                                      backgroundImage:
                                          isNet
                                              ? NetworkImage(imgUrl)
                                              : const AssetImage(
                                                'assets/navigation/profile.png',
                                              ),
                                    ),
                                    title: Text(
                                      c['name']!,
                                      style: TextStyle(
                                        fontSize: AppResponsive.fs(14),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: Text(
                                      c['phone']!,
                                      style: TextStyle(
                                        fontSize: AppResponsive.fs(12),
                                        color: const Color(0xff707070),
                                      ),
                                    ),
                                    trailing: Icon(
                                      Icons.arrow_forward_ios,
                                      size: AppResponsive.sp(14),
                                    ),
                                    onTap: () => Navigator.pop(context, c),
                                  ),
                                );
                              },
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
