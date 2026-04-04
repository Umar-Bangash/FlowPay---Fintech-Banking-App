import 'package:flowpay/features/pocket/presentation/components/packet_appbar.dart';
import 'package:flowpay/features/pocket/presentation/components/pocket_category_card.dart';
import 'package:flowpay/features/pocket/presentation/cubit/pocket_category_cubit.dart';
import 'package:flowpay/features/pocket/presentation/pages/create_pocket_page.dart';
import 'package:flowpay/helpers/ui_responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PocketCategory extends StatelessWidget {
  const PocketCategory({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PocketCategoryCubit>();
    return Scaffold(
      appBar: pocketAppBar(
        context,
        'My Pocket',
        Image.asset(
          'assets/home/notification.png',
          height: context.hPx(24),
          width: context.wPx(24),
        ),
      ),
      body: Padding(
        padding: context.padSymmetricPx(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What are you saving for?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            Text(
              'Choose a present or create your custom\npocket',
              style: TextStyle(fontSize: 13, color: Color(0xff0A0A0A)),
            ),
            context.spaceHPx(10),
            Expanded(
              child: BlocBuilder<PocketCategoryCubit, PocketCategoryState>(
                builder: (context, state) {
                  return GridView.builder(
                    itemCount: pocketsList.length,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 172 / 126,
                    ),
                    itemBuilder: (context, index) {
                      final pocket = pocketsList[index];
                      debugPrint("pocket id is ${pocket.id}");
                      return PocketCategoryCard(
                        id: pocket.id,
                        pocketImage: pocket.pocketImage,
                        pocketName: pocket.pocketName,
                        onClick: () {
                          cubit.selectPocket(index);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => CreatePocketPage(
                                    categoryId: pocket.id,
                                    categoryImage:
                                        index == 7 ? null : pocket.pocketImage,
                                    categoryName:
                                        index == 7 ? null : pocket.pocketName,
                                    index: index == 7 ? null : index,
                                  ),
                            ),
                          );
                        },
                        isSelected: state.selectedIndex == index,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Color(0xffFFFFFF),
    );
  }
}
