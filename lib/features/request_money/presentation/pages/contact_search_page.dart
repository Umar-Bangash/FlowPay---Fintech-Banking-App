import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flowpay/helpers/ui_responsive_helper.dart';
import '../../../chat/presentation/components/chat_tile.dart';

class ContactSearchPage extends StatefulWidget {
  const ContactSearchPage({super.key});

  @override
  State<ContactSearchPage> createState() => _ContactSearchPageState();
}

class _ContactSearchPageState extends State<ContactSearchPage> {
  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;

  Stream<List<Map<String, String>>>? contactStream;

  @override
  void initState() {
    super.initState();

    searchController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        final query = searchController.text.trim();
        if (!mounted) return;

        if (query.isEmpty) {
          setState(() {
            contactStream = null;
          });
        } else {
          setState(() {
            contactStream = _searchContacts(query);
          });
        }
      });
    });
  }

  Stream<List<Map<String, String>>> _searchContacts(String phone) async* {
    // Step 1: Search accounts by phone
    final accountQuery =
        FirebaseFirestore.instance
            .collection('accounts')
            .where('phone', isEqualTo: phone)
            .snapshots();

    await for (var accountSnapshot in accountQuery) {
      List<Map<String, String>> results = [];

      for (var doc in accountSnapshot.docs) {
        final accountData = doc.data();
        final userId = accountData['userId'] as String?;

        if (userId == null) continue;

        // Step 2: Fetch linked user
        final userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .get();

        if (!userDoc.exists) continue;

        final userData = userDoc.data()!;
        final profileUrl = userData['profileImageUrl'];

        results.add({
          'name': userData['name'] ?? 'User',
          'image':
              (profileUrl != null && profileUrl.toString().isNotEmpty)
                  ? profileUrl
                  : 'assets/navigation/profile.png',
          'phone': accountData['phone'] ?? '',
          'userId': userId,
        });
      }

      yield results;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFFFFF),
      appBar: AppBar(
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios, size: 20),
        ),
        centerTitle: true,
        title: const Text(
          'Request Money',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          Image.asset(
            'assets/home/notification.png',
            height: context.hPx(24),
            width: context.wPx(24),
          ),
          context.spaceWPx(20),
        ],
        backgroundColor: const Color(0xffFFFFFF),
      ),
      body: Column(
        children: [
          Padding(
            padding: context.padSymmetricPx(horizontal: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Requesting from',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                context.spaceHPx(15),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xffD1D5DC)),
                  ),
                  child: TextFormField(
                    controller: searchController,
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 25, right: 10),
                        child: Image.asset(
                          'assets/transfer/search.png',
                          height: context.hPx(24),
                          width: context.wPx(24),
                        ),
                      ),
                      hintText: 'Search by phone...',
                      hintStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xffA3A3A3),
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          context.spaceHPx(25),
          Expanded(
            child:
                contactStream == null
                    ? const Center(child: Text('Enter phone to search'))
                    : StreamBuilder<List<Map<String, String>>>(
                      stream: contactStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        }

                        final contacts = snapshot.data ?? [];

                        if (contacts.isEmpty) {
                          return const Center(child: Text('No contact found'));
                        }

                        return ListView.builder(
                          itemCount: contacts.length,
                          itemBuilder: (context, index) {
                            final contact = contacts[index];

                            return ChatTile(
                              imagePath:
                                  contact['image']!.isNotEmpty
                                      ? contact['image']!
                                      : 'assets/navigation/profile.png',
                              name: contact['name']!,
                              message: contact['phone']!,
                              dateTime: DateTime.now(),
                              trailingLabel: '',
                              onTap: () {
                                Navigator.pop(context, contact);
                              },
                            );
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
