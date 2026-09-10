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
                      Color(0xFF006FFF),
                      Color(0xFF00AAF2),
                      Color(0xFF00E5E5),
                      Color(0xFF0BFF96),
                    ],
                    stops: [0.0, 0.24, 0.49, 1.0],
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
                              Container(
                                // margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 22, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 84, 204, 204),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'AI',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Image.asset(
                            'assets/avatar.png',
                            scale: 6.4,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.hello,
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.pleaseLoginToContinue,
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
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
                                  fontSize: 16, color: Color(0xFF0055CC)),
                              decoration: InputDecoration(
                                hintText: 'Email',
                                hintStyle: TextStyle(
                                  color: const Color(0xFF0055CC)
                                      .withValues(alpha: 0.5),
                                  fontFamily: 'Montserrat',
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: passwordController,
                              obscureText: _obscurePassword,
                              style: const TextStyle(
                                  fontSize: 16, color: Color(0xFF0055CC)),
                              decoration: InputDecoration(
                                hintText: l10n.password,
                                hintStyle: TextStyle(
                                  color: const Color(0xFF0055CC)
                                      .withValues(alpha: 0.5),
                                  fontFamily: 'Montserrat',
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: const Color(0xFF0055CC)
                                        .withValues(alpha: 0.6),
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
                                    showDialog(
                                      context: context,
                                      builder: (dialogContext) {
                                        return Dialog(
                                          backgroundColor: Colors.transparent,
                                          child: Container(
                                            padding: const EdgeInsets.all(3),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: Colors.white
                                                    .withValues(alpha: 0.8),
                                                width: 1.5,
                                              ),
                                            ),
                                            child: Container(
                                              padding: const EdgeInsets.all(20),
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                    Color(0xFF4DD9E8),
                                                    Color(0xFF80F0D0),
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    context.isEnglish
                                                        ? 'Reset password'
                                                        : 'Resetuj šifru',
                                                    style: const TextStyle(
                                                      fontFamily: 'Montserrat',
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: Color(0xFF0055CC),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    context.isEnglish
                                                        ? 'Enter your email and we\'ll send you a reset link.'
                                                        : 'Unesi svoj email i poslaćemo ti link za resetovanje.',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontFamily: 'Montserrat',
                                                      fontSize: 13,
                                                      color: Colors.black
                                                          .withValues(
                                                              alpha: 0.7),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 16),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              14),
                                                    ),
                                                    child: TextField(
                                                      controller:
                                                          emailController,
                                                      keyboardType:
                                                          TextInputType
                                                              .emailAddress,
                                                      style: const TextStyle(
                                                        fontFamily:
                                                            'Montserrat',
                                                        fontSize: 15,
                                                        color: Colors.black87,
                                                      ),
                                                      decoration:
                                                          InputDecoration(
                                                        hintText: context
                                                                .isEnglish
                                                            ? 'your@email.com'
                                                            : 'tvoj@email.com',
                                                        hintStyle: TextStyle(
                                                          fontFamily:
                                                              'Montserrat',
                                                          fontSize: 14,
                                                          color: Colors
                                                              .grey.shade400,
                                                        ),
                                                        border:
                                                            InputBorder.none,
                                                        contentPadding:
                                                            const EdgeInsets
                                                                .all(14),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 20),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                dialogContext),
                                                        child: Text(
                                                          context.isEnglish
                                                              ? 'Cancel'
                                                              : 'Otkaži',
                                                          style:
                                                              const TextStyle(
                                                            fontFamily:
                                                                'Montserrat',
                                                            fontSize: 15,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      ElevatedButton(
                                                        onPressed: () async {
                                                          final email =
                                                              emailController
                                                                  .text
                                                                  .trim();
                                                          if (email.isEmpty)
                                                            return;

                                                          final navigator =
                                                              Navigator.of(
                                                                  dialogContext);
                                                          final scaffoldMessenger =
                                                              ScaffoldMessenger
                                                                  .of(context);
                                                          final isEng =
                                                              context.isEnglish;

                                                          navigator.pop();

                                                          try {
                                                            await locator<
                                                                    AuthCubit>()
                                                                .forgotPassword(
                                                                    email);
                                                            scaffoldMessenger
                                                                .showSnackBar(
                                                              SnackBar(
                                                                content: Text(isEng
                                                                    ? 'Reset link sent to $email'
                                                                    : 'Link za resetovanje poslat na $email'),
                                                                backgroundColor:
                                                                    const Color(
                                                                        0xFF0055CC),
                                                                behavior:
                                                                    SnackBarBehavior
                                                                        .floating,
                                                              ),
                                                            );
                                                          } catch (e) {
                                                            scaffoldMessenger
                                                                .showSnackBar(
                                                              SnackBar(
                                                                content: Text(
                                                                    'Error: $e'),
                                                                backgroundColor:
                                                                    Colors.red
                                                                        .shade700,
                                                                behavior:
                                                                    SnackBarBehavior
                                                                        .floating,
                                                              ),
                                                            );
                                                          }
                                                        },
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              const Color(
                                                                  0xFF0055CC),
                                                          foregroundColor:
                                                              Colors.white,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12),
                                                          ),
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      20,
                                                                  vertical: 12),
                                                          elevation: 0,
                                                        ),
                                                        child: Text(
                                                          context.isEnglish
                                                              ? 'Send link'
                                                              : 'Pošalji link',
                                                          style:
                                                              const TextStyle(
                                                            fontFamily:
                                                                'Montserrat',
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Text(
                                    l10n.forgotPassword,
                                    style: TextStyle(
                                      color: const Color.fromARGB(
                                          226, 255, 255, 255),
                                      fontWeight: FontWeight.w800,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.82,
                              height: 44,
                              child: ElevatedButton(
                                onPressed: () {
                                  authCubit.login(
                                    emailController.text.trim(),
                                    passwordController.text.trim(),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0055CC),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  l10n.login,
                                  style: const TextStyle(
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
                              width: MediaQuery.of(context).size.width * 0.82,
                              height: 44,
                              child: ElevatedButton(
                                onPressed: () {
                                  authCubit.signInWithGoogle();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black87,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  elevation: 0,
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
                                      const SizedBox(width: 8),
                                      Text(
                                        l10n.continueGoogle,
                                        style: const TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.82,
                              height: 44,
                              child: ElevatedButton(
                                onPressed: () {
                                  authCubit.login(
                                    emailController.text.trim(),
                                    passwordController.text.trim(),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black87,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  elevation: 0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/apple.png',
                                      height: 22,
                                      width: 22,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      l10n.continueApple,
                                      style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87,
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
