import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flowpay/features/account/data/account_repo_impl.dart';
import 'package:flowpay/features/account/presentation/cubit/account_cubit.dart';
import 'package:flowpay/features/auth/data/biometric_auth_impl.dart';
import 'package:flowpay/features/auth/data/face_auth_repo_impl.dart';
import 'package:flowpay/features/auth/data/firebase_auth_repo.dart';
import 'package:flowpay/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flowpay/features/auth/presentation/cubit/auth_state.dart';
import 'package:flowpay/features/auth/presentation/cubit/biometric_cubit.dart';
import 'package:flowpay/features/auth/presentation/pages/auth_page.dart';
import 'package:flowpay/features/bill_payment/data/bill_repo_impl.dart';
import 'package:flowpay/features/bill_payment/presentation/cubit/bill_cubit.dart';
import 'package:flowpay/features/chat/data/chat_repo_impl.dart';
import 'package:flowpay/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:flowpay/features/notification/presentation/cubit/noti_btn_cubit.dart';
import 'package:flowpay/features/pocket/data/goal_repo_impl.dart';
import 'package:flowpay/features/pocket/presentation/components/pocket_icon.dart';
import 'package:flowpay/features/pocket/presentation/cubit/addamount_to_pocket_cubit.dart';
import 'package:flowpay/features/pocket/presentation/cubit/goal_cubit.dart';
import 'package:flowpay/features/notification/data/repo/notification_repo_impl.dart';
import 'package:flowpay/features/notification/presentation/cubit/notification_cubit.dart';
import 'package:flowpay/features/stripe_payment/data/repo/payment_repo_impl.dart';
import 'package:flowpay/features/stripe_payment/presentation/cubit/payment_cubit.dart';
import 'package:flowpay/features/pocket/presentation/cubit/pocket_category_cubit.dart';
import 'package:flowpay/features/profile_and_setting/data/profile_repo_impl.dart';
import 'package:flowpay/features/profile_and_setting/presentation/cubit/profile_cubit.dart';
import 'package:flowpay/features/request_money/data/request_repo_impl.dart';
import 'package:flowpay/features/request_money/presentation/cubit/request_cubit.dart';
import 'package:flowpay/features/search/data/search_repo_impl.dart';
import 'package:flowpay/features/search/presentation/cubit/search_cubit.dart';
import 'package:flowpay/features/storage/data/stroage_repo_impl.dart';
import 'package:flowpay/features/transaction/data/services/receipt_pdf_service.dart';
import 'package:flowpay/features/transaction/data/transaction_repo_impl.dart';
import 'package:flowpay/features/transaction/data/services/transaction_service.dart';
import 'package:flowpay/features/transaction/presentation/cubit/amnt_plus_cmnt_cubit.dart';
import 'package:flowpay/features/transaction/presentation/cubit/recipt_cubit.dart';
import 'package:flowpay/features/transaction/presentation/cubit/transaction_cubit.dart';
import 'package:flowpay/navigations/navigation_cubit.dart';
import 'package:flowpay/navigations/navigation_page.dart';
import 'package:flowpay/themes/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/* 

 APP - Root level
 -------------------------------------------------------------------------------
 Repositories for the DataBase (DB/db)
   - firebase
   - supabase

 Bloc provider: for the State Managment
   - Auth Cubit
   - Profile Cubit
   - Theme Cubit
   - Account Cubit
   - Transaction Cubit
   - Search Cubit
   - Notfication Cubit
   - Payment Cubit
   - Goal Cubit

 Check Auth State:
   - unauthenticated -> AuthPage (login/register)
   - authenticated -> HomePage
 */

class FlowPay extends StatelessWidget {
  final GlobalKey<NavigatorState>? navigator;

  // user id
  //final userId = FirebaseAuth.instance.currentUser!.uid;

  // auth repo + biometric repo + Face Repo
  final firebaseAuthRepo = FirebaseAuthRepo();
  final biometricAuthRepo = BiometricAuthImpl();
  final faceAuthRepo = FaceAuthRepoImpl();

  // profile repo + storage repo (profile images)
  final profileRepoImpl = ProfileRepoImpl();
  final storageRepoImpl = StroageRepoImpl();

  // account repo
  final accountRepoImpl = AccountRepoImpl();

  // search repo
  final searchRepoImpl = SearchRepoImpl();

  // notification repo
  final notificationRepoImpl = NotificationRepoImpl();

  // transiction repo
  final transactionRepoImpl = TransactionRepoImpl();
  late final transactionService = TransactionService(notificationRepoImpl);

  // payment repo
  final paymentRepoImpl = PaymentRepoImpl();

  // goal repo
  final goalRepoImpl = GoalRepoImpl();

  // chat repo
  final chatRepo = ChatRepoImpl();

  // request money repo
  final firestore = FirebaseFirestore.instance;
  late final requestRepo = RequestRepositoryImpl(firestore);

  // bill repository
  late final billRepoImpl = BillRepositoryImpl(firestore);

  FlowPay({super.key, this.navigator});

  @override
  Widget build(BuildContext context) {
    // provide cubit to app
    return MultiBlocProvider(
      // passing all cubits of app ..... !!
      providers: [
        // Auth Cubit
        BlocProvider<AuthCubit>(
          create:
              (context) => AuthCubit(
                authRepo: firebaseAuthRepo,
                biometricAuthRepo: biometricAuthRepo,
                faceAuthRepo: faceAuthRepo,
              )..checkAuth(), // this checkAuth function check that
          //current user is authenticated or not
        ),

        // Profile Cubit
        BlocProvider<ProfileCubit>(
          create: (context) => ProfileCubit(profileRepoImpl, storageRepoImpl),
        ),

        // Account Cubit
        BlocProvider<AccountCubit>(
          create: (context) => AccountCubit(accountRepoImpl),
        ),

        // Transaction Cubit
        BlocProvider<TransactionCubit>(
          create:
              (context) =>
                  TransactionCubit(transactionRepoImpl, transactionService),
        ),

        // Search Cubit
        BlocProvider<SearchCubit>(
          create: (context) => SearchCubit(searchRepoImpl),
        ),

        // Notification Cubit
        BlocProvider<NotificationCubit>(
          create: (context) => NotificationCubit(notificationRepoImpl),
        ),

        // transaction recipt cubit
        BlocProvider(create: (context) => ReceiptCubit(ReceiptPdfService())),

        // Payment Cubit
        BlocProvider<PaymentCubit>(
          create: (context) => PaymentCubit(paymentRepoImpl),
        ),

        // Goal Cubiit
        BlocProvider(create: (context) => GoalCubit(goalRepoImpl)),

        // Theme Cubit
        BlocProvider<ThemeCubit>(create: (context) => ThemeCubit()),

        // Biometric Cubit
        BlocProvider(create: (context) => BiometricCubit()),

        // Navigation Cubit
        BlocProvider(create: (context) => NavigationCubit()),

        // Amount Cubit
        BlocProvider(create: (context) => AmountCubit()),

        // Comment Cubit
        BlocProvider(create: (context) => CommentCubit()),

        // Notification Btn Cubit
        BlocProvider(create: (context) => NotiBtnCubit()),

        // Pocket Category Cubit
        BlocProvider(create: (context) => PocketCategoryCubit()),

        // Pocket Icon Cubit
        BlocProvider(create: (context) => PocketIconCubit()),

        // Pocket ready made amount adding cubit
        BlocProvider(create: (context) => PocketAmountCubit()),

        // Chat Cubit ( also handle notification for request money )
        BlocProvider(
          create: (context) => ChatCubit(chatRepo, notificationRepoImpl),
        ),

        // Request Money Cubit
        BlocProvider(create: (context) => RequestCubit(requestRepo)),

        // Bill Cubit
        BlocProvider(create: (context) => BillCubit(billRepoImpl)),
      ],
      child: BlocBuilder<ThemeCubit, ThemeData>(
        builder:
            (context, currentTheme) => MaterialApp(
              debugShowCheckedModeBanner: false,
              navigatorKey: navigator,
              theme: currentTheme,
              home: Scaffold(
                body: BlocConsumer<AuthCubit, AuthStates>(
                  builder: (context, authState) {
                    // Not logged in
                    if (authState is UnAuthenticated ||
                        authState is AuthError) {
                      return AuthPage();
                    }

                    // Fully authenticated → go to home
                    if (authState is Authenticated) {
                      return NavigationPage();
                    }

                    // Loading
                    return const Center(child: CircularProgressIndicator());
                  },
                  listener: (context, state) {
                    if (state is AuthError) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(state.message)));
                    }
                  },
                ),
              ),
            ),
      ),
    );
  }
}
