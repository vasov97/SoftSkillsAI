import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:softai/cubit/auth_cubit.dart';
import 'package:softai/di/di.dart';
import 'package:softai/extensions/l10n_extension.dart';
import 'package:softai/screens/create_account_screen.dart';
import 'package:softai/screens/onboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscurePassword = true;

  late final AuthCubit authCubit;

  @override
  void dispose() {
    emailController.dispose();
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
            // Navigate to HomeScreen after successful login
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const OnboardScreen()),
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              // Pozadinski gradient
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 40,
                          ),
                          Image.asset(
                            'assets/avatar.png',
                            scale: 6.4,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Skillena',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  color: Colors.white,
                                  fontSize: 48,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: Image.asset(
                                  'assets/ai.png',
                                  scale: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          children: [
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
                            const SizedBox(height: 16),
                            TextField(
                              controller: passwordController,
                              obscureText: _obscurePassword,
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
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.white70,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    authCubit.forgotPassword(
                                        emailController.text.trim());
                                  },
                                  child: Text(
                                    l10n.forgotPassword,
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w800,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: 180,
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
                                child: Text(
                                  l10n.login,
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 16,
                            ),
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
                            SizedBox(
                              height: 16,
                            ),
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
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  l10n.dontHaveAccount,
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
                                            const CreateAccountScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    l10n.createOne,
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w800,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
