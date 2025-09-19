import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:softai/cubit/auth_cubit.dart';
import 'package:softai/screens/profile_screen.dart';
import 'package:softai/screens/start_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final AuthCubit authCubit;

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
          return ProfileScreen(user: state.user);
        }

        return const StartScreen();
      },
    );
  }
}
