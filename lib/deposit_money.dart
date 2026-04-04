import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'package:flutter/material.dart';

class DepositMoney extends StatelessWidget {
  const DepositMoney({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back_ios, size: 20),
        ),
        centerTitle: true,
        title: Text(
          'Deposite Money',
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
        backgroundColor: Color(0xffFFFFFF),
      ),
      body: SizedBox(
        width: double.maxFinite,
        child: Padding(
          padding: context.padSymmetricPx(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              context.spaceHPx(20),
              Text(
                'Deposite Money via Bank',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                'It\'s super easy!',
                style: TextStyle(fontSize: 16, color: Color(0xff737373)),
              ),
              Divider(color: Color.fromARGB(255, 226, 225, 225)),
              context.spaceHPx(18),
              _buildStep(
                icon: Image.asset("assets/transfer/in.png"),
                title: "Open Banking Application",
                subtitle:
                    "Open your banking app or log on to your online banking website.",
                showLine: true,
              ),
              _buildStep(
                icon: Image.asset("assets/transfer/bank.png"),
                title: "Tap Money Transfer",
                subtitle: 'Go to Money Transfer and select "FlowPay Bank"',
                showLine: true,
              ),
              _buildStep(
                icon: Image.asset("assets/transfer/detail.png"),
                title: "Enter Details",
                subtitle:
                    "Enter your FlowPay account number and amount to be transferred.",
                showLine: true,
              ),
              _buildStep(
                icon: Image.asset("assets/transfer/lock.png"),
                title: "Confirm Payment",
                subtitle: "Provide authentication to confirm your payment.",
                showLine: true,
              ),
              _buildStep(
                icon: Image.asset("assets/transfer/done.png"),
                title: "You're done!",
                subtitle:
                    "You will automatically receive the amount in your FlowPay account",
                showLine: false,
                isLast: true,
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Color(0xffFFFFFF),
    );
  }

  Widget _buildStep({
    required Widget icon,
    required String title,
    required String subtitle,
    required bool showLine,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // LEFT SIDE: ICON + DOTTED LINE
        Column(
          children: [
            // ICON BOX (same rounded square as screenshot)
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color:
                    isLast ? const Color(0xFF007AFF) : const Color(0xFFEFF1F5),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(10),
              child: icon,
            ),

            // DOTTED LINE BELOW ICON
            if (showLine)
              Column(
                children: List.generate(
                  11,
                  (index) => Container(
                    width: 2,
                    height: 2,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    color: Colors.grey.withOpacity(0.7),
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(width: 18),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }
}
