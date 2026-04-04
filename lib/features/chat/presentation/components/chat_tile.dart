import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'package:flutter/material.dart';

class ChatTile extends StatelessWidget {
  final String imagePath;
  final String name;
  final String message;
  final DateTime dateTime;
  final void Function() onTap;
  const ChatTile({
    super.key,
    required this.imagePath,
    required this.name,
    required this.message,
    required this.dateTime,
    required this.onTap,
    required String trailingLabel,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: double.maxFinite,
        child: Column(
          children: [
            Padding(
              padding: context.padSymmetricPx(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    width: 43,
                    height: 43,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image:
                            imagePath.startsWith('http')
                                ? NetworkImage(imagePath)
                                : AssetImage(imagePath) as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  context.spaceWPx(10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        message,
                        style: TextStyle(
                          fontSize: 11.57,
                          color: Color(0xff707070),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Text(
                      dateTime.toIso8601String(),
                      style: TextStyle(
                        fontSize: 9.57,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff707070),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            context.spaceHPx(8),
            Divider(color: Color.fromARGB(255, 214, 214, 214)),
            context.spaceHPx(8),
          ],
        ),
      ),
    );
  }
}
