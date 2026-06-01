import 'package:flowpay/features/pocket/presentation/components/packet_appbar.dart';
import 'package:flowpay/features/pocket/presentation/components/pocket_category_card.dart';
import 'package:flowpay/features/pocket/presentation/cubit/pocket_category_cubit.dart';
import 'package:flowpay/features/pocket/presentation/pages/create_pocket_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../helpers/app_animation.dart';
import '../../../../helpers/ui_responsive_helper.dart';

class PocketCategory extends StatelessWidget {
  const PocketCategory({super.key});

  @override
  Widget build(BuildContext context) {
    AppResponsive.init(context);
    final cubit = context.read<PocketCategoryCubit>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: pocketAppBar(
        context,
        'My Pocket',
        Image.asset(
          'assets/home/notification.png',
          height: AppResponsive.sp(22),
          width: AppResponsive.sp(22),
        ),
      ),
      body: AppAnimatedPage(
        direction: SlideDirection.bottom,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppResponsive.w(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppResponsive.h(8)),

              AppAnimatedItem(
                index: 0,
                direction: SlideDirection.left,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What are you saving for?',
                      style: TextStyle(
                        fontSize: AppResponsive.fs(22),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: AppResponsive.h(4)),
                    Text(
                      'Choose a preset or create your custom pocket',
                      style: TextStyle(
                        fontSize: AppResponsive.fs(12),
                        color: const Color(0xff737373),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppResponsive.h(14)),

              Expanded(
                child: AppAnimatedItem(
                  index: 1,
                  direction: SlideDirection.bottom,
                  child: BlocBuilder<PocketCategoryCubit, PocketCategoryState>(
                    builder: (context, state) {
                      return GridView.builder(
                        itemCount: pocketsList.length,
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: AppResponsive.w(14),
                          mainAxisSpacing: AppResponsive.h(14),
                          // aspect ratio driven by available width — safe on all screens
                          childAspectRatio: 172 / 126,
                        ),
                        itemBuilder: (context, i) {
                          final pocket = pocketsList[i];
                          return PocketCategoryCard(
                            id: pocket.id,
                            pocketImage: pocket.pocketImage,
                            pocketName: pocket.pocketName,
                            isSelected: state.selectedIndex == i,
                            onClick: () {
                              cubit.selectPocket(i);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => CreatePocketPage(
                                        categoryId: pocket.id,
                                        categoryImage:
                                            i == 7 ? null : pocket.pocketImage,
                                        categoryName:
                                            i == 7 ? null : pocket.pocketName,
                                        index: i == 7 ? null : i,
                                      ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
