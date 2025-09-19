import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:softai/cubit/auth_cubit.dart';
import 'package:softai/di/di.dart';
import 'package:softai/extensions/l10n_extension.dart';
import 'package:softai/screens/login_screen.dart';
import 'package:softai/screens/onboard_screen.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmController = TextEditingController();

  bool obscurePassword = false;
  bool obscureConfimedPassword = false;

  late final AuthCubit authCubit;

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    passwordConfirmController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    authCubit = locator<AuthCubit>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BlocConsumer<AuthCubit, AuthState>(
        bloc: authCubit,
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const OnboardScreen(),
              ),
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF007BFF),
                      Color(0xFF00FFD5),
                    ],
                  ),
                ),
              ),
              Positioned.fill(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 64,
                      ),
                      Text(
                        l10n.createAnAccount,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 28,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      Image.asset(
                        'assets/avatar.png',
                        scale: 5.8,
                      ),
                      const SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          children: [
                            TextField(
                              controller: nameController,
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.white),
                              decoration: InputDecoration(
                                labelText: l10n.name,
                                labelStyle: TextStyle(color: Colors.white70),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            TextField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.white),
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                labelStyle: TextStyle(color: Colors.white70),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            TextField(
                              controller: passwordController,
                              obscureText: obscurePassword,
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.white),
                              decoration: InputDecoration(
                                labelText: l10n.password,
                                labelStyle:
                                    const TextStyle(color: Colors.white70),
                                enabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.white70,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      obscurePassword = !obscurePassword;
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: passwordConfirmController,
                              obscureText: obscureConfimedPassword,
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.white),
                              decoration: InputDecoration(
                                labelText: l10n.confirmPassword,
                                labelStyle:
                                    const TextStyle(color: Colors.white70),
                                enabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    obscureConfimedPassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.white70,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      obscureConfimedPassword =
                                          !obscureConfimedPassword;
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                            SizedBox(
                              width: 220,
                              height: 44,
                              child: ElevatedButton(
                                onPressed: () {
                                  final name = nameController.text.trim();
                                  final email = emailController.text.trim();
                                  final password =
                                      passwordController.text.trim();
                                  final confirmPassword =
                                      passwordConfirmController.text.trim();

                                  authCubit.signUp(
                                      name, email, password, confirmPassword);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(
                                      color: Colors.white, width: 2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  elevation: 0, // bez senke
                                ),
                                child: Text(
                                  l10n.createAnAccount,
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Container(
                                      width: 120,
                                      height: 1,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    l10n.or,
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 16,
                                      color: const Color.fromARGB(
                                          255, 245, 244, 244),
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Container(
                                      width: 120,
                                      height: 1,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: 260,
                              height: 44,
                              child: ElevatedButton(
                                onPressed: () {
                                  authCubit.login(
                                    emailController.text.trim(),
                                    passwordController.text.trim(),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(
                                      color: Colors.white, width: 2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  elevation: 0, // bez senke
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/google.png',
                                        height: 18,
                                        width: 18,
                                      ),
                                      SizedBox(
                                        width: 8,
                                      ),
                                      Text(
                                        l10n.continueGoogle,
                                        style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: 260,
                              height: 44,
                              child: ElevatedButton(
                                onPressed: () {
                                  authCubit.login(
                                    emailController.text.trim(),
                                    passwordController.text.trim(),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(
                                      color: Colors.white, width: 2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  elevation: 0, // bez senke
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/apple.png',
                                      height: 22,
                                      width: 22,
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Text(
                                      l10n.continueApple,
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "${l10n.alreadyHaveAccount} ",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    l10n.login,
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w800,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
