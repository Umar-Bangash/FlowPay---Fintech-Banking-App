import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowpay/features/chat/presentation/cubit/chat_cubit.dart';

/// Paste this mixin onto your NavigationPage or root widget.
///
/// Usage:
///   class NavigationPage extends StatefulWidget { ... }
///   class _NavigationPageState extends State<NavigationPage>
///       with WidgetsBindingObserver, _PresenceMixin {
///
///     @override
///     void initState() {
///       super.initState();
///       WidgetsBinding.instance.addObserver(this);
///       _setOnline(context, true);   // ← user opened app
///     }
///
///     @override
///     void dispose() {
///       WidgetsBinding.instance.removeObserver(this);
///       super.dispose();
///     }
///
///     @override
///     void didChangeAppLifecycleState(AppLifecycleState state) {
///       switch (state) {
///         case AppLifecycleState.resumed:
///           _setOnline(context, true);
///           break;
///         case AppLifecycleState.paused:
///         case AppLifecycleState.inactive:
///         case AppLifecycleState.detached:
///           _setOnline(context, false);
///           break;
///         default:
///           break;
///       }
///     }
///   }

// Simple standalone StatefulWidget you can wrap around NavigationPage
// if you don't want to mix into your existing widget.
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
