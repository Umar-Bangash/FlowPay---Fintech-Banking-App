import 'package:flutter/material.dart';
import '../../../../helpers/ui_responsive_helper.dart';

class TrxTile extends StatelessWidget {
  final String? profileImageUrl;
  final String name;
  final String datetime;
  final String amount;
  final Color amountColor;
  final VoidCallback onTap;

  const TrxTile({
    super.key,
    this.profileImageUrl,
    required this.name,
    required this.datetime,
    required this.amount,
    required this.amountColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);
    final avSz = AppResponsive.sp(46).clamp(36.0, 56.0);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppResponsive.radiusLg),
      child: Container(
        // No fixed height — sized by content
        padding: EdgeInsets.symmetric(
          horizontal: AppResponsive.w(12),
          vertical: AppResponsive.h(10),
        ),
        decoration: BoxDecoration(
          color: const Color(0xffFBFCFF),
          borderRadius: BorderRadius.circular(AppResponsive.radiusLg),
          border: Border.all(color: const Color(0xffDFDFDF)),
        ),
        child: Row(
          children: [
            // Avatar
            ClipRRect(
              borderRadius: BorderRadius.circular(AppResponsive.radiusSm),
              child: Container(
                height: avSz,
                width: avSz,
                color: const Color(0xffDFE5FF),
                child:
                    (profileImageUrl?.isNotEmpty ?? false)
                        ? Image.network(
                          profileImageUrl!,
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

            SizedBox(width: AppResponsive.w(10)),

            // Name + date — Expanded so they never push amount off screen
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: AppResponsive.fs(14),
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  SizedBox(height: AppResponsive.h(3)),
                  Text(
                    datetime,
                    style: TextStyle(
                      fontSize: AppResponsive.fs(11),
                      color: const Color(0xff707070),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),

            SizedBox(width: AppResponsive.w(8)),

            // Amount — FittedBox so long "- Rs 25,000" never overflows
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                amount,
                style: TextStyle(
                  fontSize: AppResponsive.fs(13),
                  fontWeight: FontWeight.w500,
                  color: amountColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
