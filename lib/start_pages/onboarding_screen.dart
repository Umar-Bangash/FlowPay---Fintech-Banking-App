import 'package:flowpay/features/auth/presentation/pages/auth_page.dart';
import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'package:flowpay/start_pages/components/custom_indicator.dart';
import 'package:flowpay/start_pages/components/main_button.dart';
import 'package:flowpay/start_pages/components/slide_container.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int currentIndex = 0;

  final List<Map<String, String>> slides = [
    {
      'image': 'assets/images/onboard1.png',
      'title': 'Smart Transfer',
      'subtitle':
          'Transfer instantly to friends or bank \naccounts with zero hassle',
    },
    {
      'image': 'assets/images/onboard2.png',
      'title': 'Scan. Pay. Done.',
      'subtitle':
          'Make or receive payments using your unique \nPayple QR code.',
    },
    {
      'image': 'assets/images/onboard3.png',
      'title': 'Save Smarter.',
      'subtitle':
          'Create personal savings goals or secure \ndeposits with real progress tracking',
    },
    {
      'image': 'assets/images/onboard4.png',
      'title': 'Track Progress.',
      'subtitle':
          'Stay informed with your financial goals and progress tracking in real time.',
    },
  ];

  void nextPage() {
    if (currentIndex < slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AuthPage()),
      );
    }
  }

  void previousPage() {
    if (currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: currentIndex == 0 ? null : previousPage,
        ),
      ),
      body: Column(
        children: [
          context.spaceHPx(40),

          /// SLIDES
          SizedBox(
            height: context.hPx(500),
            child: Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: slides.length,
                onPageChanged: (index) {
                  setState(() => currentIndex = index);
                },
                itemBuilder: (context, index) {
                  final slide = slides[index];
                  return Column(
                    children: [
                      SlideContainer(
                        imagePath: slide['image']!,
                        imgHeight: context.hPx(300), // FIXED SIZE
                        imgWidth: context.wPx(320), // FIXED SIZE
                        title: slide['title']!,
                        subTitle: slide['subtitle']!,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          /// DOT INDICATOR
          CustomIndicator(currentIndex: currentIndex, itemCount: slides.length),

          context.spaceHPx(30),

          /// BUTTON
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: MainButton(
              buttonName:
                  currentIndex == slides.length - 1 ? 'Get Started' : 'Next',
              onTap: nextPage,
            ),
          ),

          context.spaceHPx(20),

          /// SKIP
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => AuthPage()),
              );
            },
            child: const Text(
              'Skip',
              style: TextStyle(
                fontSize: 16,
                decoration: TextDecoration.underline,
              ),
            ),
          ),

          context.spaceHPx(30),
        ],
      ),
    );
  }
}
