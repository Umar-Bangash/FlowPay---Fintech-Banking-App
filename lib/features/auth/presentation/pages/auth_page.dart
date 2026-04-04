/* 

 Auth Page: This page determines weather to show login or register page

*/

import 'package:flowpay/features/auth/presentation/pages/login_page.dart';
import 'package:flowpay/features/auth/presentation/pages/register_page.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  // initially show login page
  bool showLoginPage = true;

  // toggel b/w pages
  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return Scaffold(body: LoginPage(onTap: togglePages));
    } else {
      return Scaffold(body: RegisterPage(onTap: togglePages));
    }
  }
}
