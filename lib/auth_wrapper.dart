import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:softai/cubit/auth_cubit.dart';
import 'package:softai/fcm_service.dart';
import 'package:softai/screens/main_screen.dart';
import 'package:softai/screens/start_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final AuthCubit authCubit;
  String? _lastAuthenticatedUid; // Track last authenticated user

  @override
  void initState() {
    super.initState();
    authCubit = GetIt.I<AuthCubit>();
    authCubit.checkAuth(); // Trigger checkAuth when the widget is initialized
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      bloc: authCubit,
      builder: (context, state) {
        if (state is AuthLoading || state is AuthInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is AuthAuthenticated) {
          if (_lastAuthenticatedUid != state.user.uid) {
            _lastAuthenticatedUid = state.user.uid;
            FCMService.setupForUser(state.user.uid);
          }
          return MainScreen(user: state.user);
        }

        // Handles both AuthUnauthenticated AND AuthError
        if (_lastAuthenticatedUid != null) {
          FCMService.cleanup(_lastAuthenticatedUid!);
          _lastAuthenticatedUid = null;
        }
        return const StartScreen();
      },
    );
  }
}
