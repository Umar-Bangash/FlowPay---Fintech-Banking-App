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
import 'package:flowpay/features/qr/data/qr_repo_impl.dart';
import 'package:flowpay/features/qr/presentation/cubit/qr_cubit.dart';
import 'package:flowpay/features/request_money/data/request_noti_service.dart';
import 'package:flowpay/features/stripe_payment/data/repo/payment_repo_impl.dart';
import 'package:flowpay/features/stripe_payment/presentation/cubit/payment_cubit.dart';
import 'package:flowpay/features/pocket/presentation/cubit/pocket_category_cubit.dart';
import 'package:flowpay/features/profile_and_setting/data/profile_repo_impl.dart';
import 'package:flowpay/features/profile_and_setting/presentation/cubit/profile_cubit.dart';
import 'package:flowpay/features/request_money/data/request_repo_impl.dart';
import 'package:flowpay/features/request_money/presentation/cubit/request_cubit.dart';
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
import 'package:firebase_auth/firebase_auth.dart';
import 'features/request_money/presentation/pages/presence_wrapper.dart';

class FlowPay extends StatelessWidget {
  final GlobalKey<NavigatorState>? navigator;

  final firebaseAuthRepo = FirebaseAuthRepo();
  final biometricAuthRepo = BiometricAuthImpl();
  final faceAuthRepo = FaceAuthRepoImpl();

  final profileRepoImpl = ProfileRepoImpl();
  final storageRepoImpl = StroageRepoImpl();

  final accountRepoImpl = AccountRepoImpl();
  final transactionRepoImpl = TransactionRepoImpl();
  final paymentRepoImpl = PaymentRepoImpl();
  final goalRepoImpl = GoalRepoImpl();
  final chatRepo = ChatRepoImpl();
  final firestore = FirebaseFirestore.instance;

  final notificationRepoImpl = NotificationRepoImpl();

  late final transactionService = TransactionService(notificationRepoImpl);
  late final requestNotiService = RequestMoneyNotificationService(
    notificationRepoImpl,
  );

  late final requestRepo = RequestRepositoryImpl(FirebaseFirestore.instance);

  late final qrRepo = QrRepoImpl(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  );

  late final billRepoImpl = BillRepositoryImpl(FirebaseFirestore.instance);

  FlowPay({super.key, this.navigator});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create:
              (context) => AuthCubit(
                authRepo: firebaseAuthRepo,
                biometricAuthRepo: biometricAuthRepo,
                faceAuthRepo: faceAuthRepo,
              )..checkAuth(),
        ),
        BlocProvider<ProfileCubit>(
          create: (context) => ProfileCubit(profileRepoImpl, storageRepoImpl),
        ),
        BlocProvider<AccountCubit>(
          create: (context) => AccountCubit(accountRepoImpl),
        ),
        BlocProvider<TransactionCubit>(
          create:
              (context) =>
                  TransactionCubit(transactionRepoImpl, transactionService),
        ),

        BlocProvider<NotificationCubit>(
          create: (context) => NotificationCubit(notificationRepoImpl),
        ),
        BlocProvider(create: (context) => ReceiptCubit(ReceiptPdfService())),
        BlocProvider<PaymentCubit>(
          create: (context) => PaymentCubit(paymentRepoImpl),
        ),
        BlocProvider(create: (context) => GoalCubit(goalRepoImpl)),
        BlocProvider<ThemeCubit>(create: (context) => ThemeCubit()),
        BlocProvider<BiometricCubit>(create: (context) => BiometricCubit()),
        BlocProvider<NavigationCubit>(create: (context) => NavigationCubit()),
        BlocProvider<AmountCubit>(create: (context) => AmountCubit()),
        BlocProvider<CommentCubit>(create: (context) => CommentCubit()),
        BlocProvider<NotiBtnCubit>(create: (context) => NotiBtnCubit()),
        BlocProvider<PocketCategoryCubit>(
          create: (context) => PocketCategoryCubit(),
        ),
        BlocProvider<PocketIconCubit>(create: (context) => PocketIconCubit()),
        BlocProvider<PocketAmountCubit>(
          create: (context) => PocketAmountCubit(),
        ),
        BlocProvider<ChatCubit>(
          create: (context) => ChatCubit(chatRepo, notificationRepoImpl),
        ),
        BlocProvider<RequestCubit>(
          create: (context) => RequestCubit(requestRepo, requestNotiService),
        ),
        BlocProvider<QRCubit>(create: (context) => QRCubit(qrRepo)),
        BlocProvider<BillCubit>(create: (context) => BillCubit(billRepoImpl)),
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
                    if (authState is UnAuthenticated ||
                        authState is AuthError) {
                      return AuthPage();
                    }
                    if (authState is Authenticated) {
                      // PresenceWrapper listens to app lifecycle and writes
                      // isOnline=true/false to Firestore automatically.
                      // This drives the single/double tick logic in ChatCubit.
                      return PresenceWrapper(child: NavigationPage());
                    }
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
