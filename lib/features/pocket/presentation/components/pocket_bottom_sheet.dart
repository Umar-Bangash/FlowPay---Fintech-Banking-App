import 'package:flowpay/features/pocket/presentation/components/pocket_dialog.dart';
import 'package:flowpay/features/pocket/presentation/pages/pocket_edit_page.dart';
import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/goal.dart';

class ManagePocketBottomSheet extends StatelessWidget {
  final Goal goal;
  const ManagePocketBottomSheet({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    //final cubit = context.read<GoalCubit>();

    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xffFFFFFF),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 25,
              spreadRadius: 3,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Manage Pocket", style: TextStyle(fontSize: 19.9)),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, size: 24),
                ),
              ],
            ),
            const SizedBox(height: 20),

            const SizedBox(height: 12),

            // Edit Pocket
            _BottomSheetTile(
              icon: 'assets/pocket/edit.png',
              title: "Edit Pocket",
              subtitle: "Change Pocket details",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PocketEditPage(goal: goal),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            // Delete Pocket
            _BottomSheetTile(
              icon: 'assets/pocket/delete.png',
              title: "Delete Pocket",
              subtitle: "Remove funds permanently",
              onTap: () {
                showDialog(
                  context: context,
                  builder:
                      (context) => Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: PocketDialog(goal: goal),
                      ),
                );
              },
            ),

            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}

class _BottomSheetTile extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _BottomSheetTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: const Color(0xffFAFAFA),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              spreadRadius: 1,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Row(
              children: [
                Image.asset(
                  icon,
                  height: context.hPx(33.83),
                  width: context.wPx(33.83),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15.92,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 11.49,
                          color: Color(0xffA3A3A3),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// import 'package:flowpay/features/pocket/presentation/components/pocket_dialog.dart';
// import 'package:flowpay/features/pocket/presentation/pages/pocket_edit_page.dart';
// import 'package:flowpay/helpers/ui_responsive_helper.dart';
// import 'package:flutter/material.dart';

// class ManagePocketBottomSheet extends StatelessWidget {
//   final String pocketImage;
//   final String pocketName;
//   final double targetAmount;
//   const ManagePocketBottomSheet({
//     super.key,
//     required this.pocketImage,
//     required this.pocketName,
//     required this.targetAmount,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.transparent,
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 8),
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           color: Color(0xffFFFFFF),
//           borderRadius: const BorderRadius.only(
//             topLeft: Radius.circular(30),
//             topRight: Radius.circular(30),
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.15),
//               blurRadius: 25,
//               spreadRadius: 3,
//               offset: const Offset(0, -5),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Title Row
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text("Manage Pocket", style: TextStyle(fontSize: 19.9)),
//                 GestureDetector(
//                   onTap: () => Navigator.pop(context),
//                   child: const Icon(Icons.close, size: 24),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 20),

//             // Edit Pocket
//             _BottomSheetTile(
//               icon: 'assets/pocket/edit.png',
//               title: "Edit Pocket",
//               subtitle: "Change Pocket details",
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder:
//                         (context) => PocketEditPage(
//                           categoryImage: pocketImage,
//                           categoryName: pocketName,
//                           targetAmount: targetAmount,
//                         ),
//                   ),
//                 );
//               },
//             ),

//             const SizedBox(height: 12),

//             // Delete Pocket
//             _BottomSheetTile(
//               icon: 'assets/pocket/delete.png',
//               title: "Delete Pocket",
//               subtitle: "Remove funds permanently",
//               onTap: () {
//                 showDialog(
//                   context: context,
//                   builder:
//                       (context) => Dialog(
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                         child: PocketDialog(saveAmount: 10),
//                       ),
//                 );
//               },
//             ),

//             const SizedBox(height: 15),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _BottomSheetTile extends StatelessWidget {
//   final String icon;
//   final String title;
//   final String subtitle;
//   final VoidCallback onTap;

//   const _BottomSheetTile({
//     required this.icon,
//     required this.title,
//     required this.subtitle,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.transparent, // outer layer okay
//       child: Ink(
//         decoration: BoxDecoration(
//           color: const Color(0xffFAFAFA),
//           borderRadius: BorderRadius.circular(14),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 15,
//               spreadRadius: 1,
//               offset: const Offset(0, 0),
//             ),
//           ],
//         ),
//         child: InkWell(
//           borderRadius: BorderRadius.circular(14),
//           onTap: onTap,
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
//             child: Row(
//               children: [
//                 Image.asset(
//                   icon,
//                   height: context.hPx(33.83),
//                   width: context.wPx(33.83),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         title,
//                         style: const TextStyle(
//                           fontSize: 15.92,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       const SizedBox(height: 2),
//                       Text(
//                         subtitle,
//                         style: const TextStyle(
//                           fontSize: 11.49,
//                           color: Color(0xffA3A3A3),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const Icon(Icons.arrow_forward_ios, size: 20),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
