import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowpay/features/chat/presentation/cubit/chat_cubit.dart';

class PresenceWrapper extends StatefulWidget {
  final Widget child;
  const PresenceWrapper({super.key, required this.child});

  @override
  State<PresenceWrapper> createState() => _PresenceWrapperState();
}

class _PresenceWrapperState extends State<PresenceWrapper>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Set online when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatCubit>().setOnlineStatus(true);
    });
  }

  @override
  void dispose() {
    context.read<ChatCubit>().setOnlineStatus(false);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cubit = context.read<ChatCubit>();
    switch (state) {
      case AppLifecycleState.resumed:
        cubit.setOnlineStatus(true);
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        cubit.setOnlineStatus(false);
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
