import 'package:flutter/material.dart';
import 'package:softai/extensions/l10n_extension.dart';
import 'package:softai/screens/create_account_screen.dart';
import 'package:softai/screens/login_screen.dart';
import 'package:softai/widgets/concentric_circles.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen>
    with TickerProviderStateMixin {
  double _columnOpacity = 0;
  double _avatarOpacity = 0;
  double _helloOpacity = 0;
  double _circlesOpacity = 0;
  double _buttonsOpacity = 0;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() => _columnOpacity = 1);
    });
    Future.delayed(const Duration(milliseconds: 900), () {
      setState(() => _avatarOpacity = 1);
    });
    Future.delayed(const Duration(milliseconds: 1500), () {
      setState(() => _helloOpacity = 1);
    });
    Future.delayed(const Duration(milliseconds: 2100), () {
      setState(() => _circlesOpacity = 1);
    });
    Future.delayed(const Duration(milliseconds: 2700), () {
      setState(() => _buttonsOpacity = 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isEnglish = context.isEnglish;
    return Scaffold(
      body: Stack(
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
          Positioned(
            top: 54,
            left: 32,
            right: 32,
            child: AnimatedOpacity(
              opacity: _columnOpacity,
              duration: const Duration(milliseconds: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    context.l10n.welcome,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      color: Colors.white,
                      fontSize: 40,
                    ),
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
                  Text(
                    context.l10n.tagline,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      color: const Color.fromARGB(186, 255, 255, 255),
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            //left: 32,
            bottom: 260,
            right: 24,
            child: AnimatedOpacity(
              opacity: _avatarOpacity,
              duration: const Duration(milliseconds: 600),
              child: Image.asset(
                'assets/avatar.png',
                scale: 3.8,
              ),
            ),
          ),
          Positioned(
            left: isEnglish ? 32 : 16,
            top: isEnglish ? 260 : 240,
            child: AnimatedOpacity(
              opacity: _helloOpacity,
              duration: const Duration(milliseconds: 600),
              child: Image.asset(
                isEnglish ? 'assets/hello.png' : 'assets/zdravo.png',
                scale: isEnglish ? 3.8 : 5.2,
              ),
            ),
          ),
          Positioned(
            bottom: 280,
            left: 70,
            child: AnimatedOpacity(
              opacity: _circlesOpacity,
              duration: const Duration(milliseconds: 600),
              child: ConcentricCircles(),
            ),
          ),
          Positioned(
            bottom: 80,
            left: 16,
            right: 16,
            child: AnimatedOpacity(
              opacity: _buttonsOpacity,
              duration: const Duration(milliseconds: 600),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 180,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        elevation: 0, // bez senke
                      ),
                      child: Text(
                        context.l10n.login,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 180,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) =>
                                  const CreateAccountScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        context.l10n.createAccount,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
