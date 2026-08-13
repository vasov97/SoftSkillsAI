import 'package:flutter/material.dart';
import 'package:softai/extensions/l10n_extension.dart';
import 'package:softai/screens/create_account_screen.dart';
import 'package:softai/screens/login_screen.dart';
import 'package:softai/theme/app_colors.dart';

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

  // @override
  // Widget build(BuildContext context) {
  //   bool isEnglish = context.isEnglish;
  //   return Scaffold(
  //     body: Stack(
  //       children: [
  //         Container(
  //           width: double.infinity,
  //           height: double.infinity,
  //           decoration: const BoxDecoration(
  //             gradient: LinearGradient(
  //               begin: Alignment.topCenter,
  //               end: Alignment.bottomCenter,
  //               colors: [
  //                 Color(0xFF006FFF),
  //                 Color(0xFF00AAF2),
  //                 Color(0xFF00E5E5),
  //                 Color(0xFF0BFF96),
  //               ],
  //               stops: [0.0, 0.24, 0.49, 1.0],
  //             ),
  //           ),
  //         ),
  //         Positioned(
  //           top: 54,
  //           left: 32,
  //           right: 32,
  //           child: AnimatedOpacity(
  //             opacity: _columnOpacity,
  //             duration: const Duration(milliseconds: 600),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.center,
  //               children: [
  //                 Column(
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   children: [
  //                     Text(
  //                       'Skillena',
  //                       style: TextStyle(
  //                         fontFamily: 'Montserrat',
  //                         color: Colors.white,
  //                         fontSize: 48,
  //                         fontWeight: FontWeight.w800,
  //                       ),
  //                     ),
  //                     Container(
  //                       margin: const EdgeInsets.only(bottom: 16),
  //                       padding: const EdgeInsets.symmetric(
  //                           horizontal: 22, vertical: 4),
  //                       decoration: BoxDecoration(
  //                         color: Color.fromARGB(255, 84, 204, 204),
  //                         borderRadius: BorderRadius.circular(10),
  //                       ),
  //                       child: const Text(
  //                         'AI',
  //                         style: TextStyle(
  //                           fontFamily: 'Montserrat',
  //                           color: Colors.white,
  //                           fontSize: 24,
  //                           fontWeight: FontWeight.w800,
  //                         ),
  //                       ),
  //                     ),
  //                     Image.asset(
  //                       'assets/avatar.png',
  //                       scale: 3.8,
  //                     ),
  //                     SizedBox(
  //                       height: 8,
  //                     ),
  //                     SizedBox(
  //                       width: MediaQuery.of(context).size.width * 0.7,
  //                       child: Text(
  //                         context.l10n.tagline,
  //                         textAlign: TextAlign.center,
  //                         style: TextStyle(
  //                           fontFamily: 'Montserrat',
  //                           color: const Color.fromARGB(240, 255, 255, 255),
  //                           fontWeight: FontWeight.w700,
  //                           fontSize: 36,
  //                         ),
  //                       ),
  //                     ),
  //                     SizedBox(
  //                       height: 8,
  //                     ),
  //                     Text(
  //                       context.l10n.subtitleStart,
  //                       textAlign: TextAlign.center,
  //                       style: TextStyle(
  //                         fontFamily: 'Montserrat',
  //                         color: const Color.fromARGB(235, 255, 255, 255),
  //                         fontWeight: FontWeight.w500,
  //                         fontSize: 24,
  //                       ),
  //                     ),
  //                     SizedBox(height: 24),
  //                     ElevatedButton.icon(
  //                       onPressed: () {
  //                         Navigator.of(context).push(
  //                           MaterialPageRoute(
  //                             builder: (context) => const LoginScreen(),
  //                           ),
  //                         );
  //                       },
  //                       icon: const Icon(Icons.chat, color: Colors.white),
  //                       label: Text(
  //                         context.l10n.buttonStart,
  //                         style: const TextStyle(
  //                           fontFamily: 'Montserrat',
  //                           fontSize: 24,
  //                           fontWeight: FontWeight.w700,
  //                           color: Colors.white,
  //                         ),
  //                       ),
  //                       style: ElevatedButton.styleFrom(
  //                         backgroundColor: AppColors.primaryBlue,
  //                         shape: RoundedRectangleBorder(
  //                           borderRadius: BorderRadius.circular(24),
  //                         ),
  //                         padding: const EdgeInsets.symmetric(
  //                             horizontal: 40, vertical: 16),
  //                         elevation: 0,
  //                       ),
  //                     ),
  //                     SizedBox(
  //                       height: 24,
  //                     ),
  //                     Row(
  //                       children: [
  //                         Expanded(
  //                           child: Container(
  //                             height: 1.5,
  //                             margin: const EdgeInsets.only(right: 12),
  //                             color: Colors.white.withValues(alpha: 0.7),
  //                           ),
  //                         ),
  //                         Text(
  //                           context.l10n.or,
  //                           style: const TextStyle(
  //                             fontFamily: 'Montserrat',
  //                             fontSize: 16,
  //                             color: Colors.white,
  //                             fontWeight: FontWeight.w700,
  //                           ),
  //                         ),
  //                         Expanded(
  //                           child: Container(
  //                             height: 1.5,
  //                             margin: const EdgeInsets.only(left: 12),
  //                             color: Colors.white.withValues(alpha: 0.7),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //         Positioned(
  //           bottom: 80,
  //           left: 16,
  //           right: 16,
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               SizedBox(
  //                 width: 180,
  //                 height: 44,
  //                 child: ElevatedButton(
  //                   onPressed: () {
  //                     Navigator.of(context).push(
  //                       MaterialPageRoute(
  //                           builder: (context) => const LoginScreen()),
  //                     );
  //                   },
  //                   style: ElevatedButton.styleFrom(
  //                     backgroundColor: Colors.transparent,
  //                     foregroundColor: Colors.white,
  //                     //side: const BorderSide(color: Colors.white, width: 2),
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(22),
  //                     ),
  //                     elevation: 0, // bez senke
  //                   ),
  //                   child: Text(
  //                     context.l10n.login,
  //                     style: TextStyle(
  //                       fontFamily: 'Montserrat',
  //                       fontSize: 16,
  //                       fontWeight: FontWeight.w700,
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //               const SizedBox(height: 16),
  //               SizedBox(
  //                 width: 180,
  //                 height: 44,
  //                 child: ElevatedButton(
  //                   onPressed: () {
  //                     Navigator.of(context).push(
  //                       MaterialPageRoute(
  //                           builder: (context) => const CreateAccountScreen()),
  //                     );
  //                   },
  //                   style: ElevatedButton.styleFrom(
  //                     backgroundColor: Colors.transparent,
  //                     //foregroundColor: Colors.blue,
  //                     foregroundColor: Colors.white,
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(22),
  //                     ),
  //                     elevation: 0,
  //                   ),
  //                   child: Text(
  //                     context.l10n.createAccount,
  //                     style: TextStyle(
  //                       fontFamily: 'Montserrat',
  //                       fontSize: 16,
  //                       fontWeight: FontWeight.w700,
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    bool isEnglish = context.isEnglish;
    return Scaffold(
      body: Container(
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: AnimatedOpacity(
              opacity: _columnOpacity,
              duration: const Duration(milliseconds: 600),
              child: Column(
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
                    margin: const EdgeInsets.only(bottom: 16),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 22, vertical: 4),
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
                  Image.asset(
                    'assets/avatar.png',
                    scale: 3.8,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: Text(
                      context.l10n.tagline,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: const Color.fromARGB(240, 255, 255, 255),
                        fontWeight: FontWeight.w700,
                        fontSize: 36,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.subtitleStart,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      color: const Color.fromARGB(235, 255, 255, 255),
                      fontWeight: FontWeight.w500,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chat, color: Colors.white),
                    label: Text(
                      context.l10n.buttonStart,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 16),
                      elevation: 0,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1.5,
                          margin: const EdgeInsets.only(right: 12),
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                      Text(
                        context.l10n.or,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1.5,
                          margin: const EdgeInsets.only(left: 12),
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 150,
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            context.l10n.login,
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 150,
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
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
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
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
