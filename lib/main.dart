import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:softai/di/di.dart';
import 'package:softai/l10n/app_localizations.dart';
import 'package:softai/service/auth_wrapper.dart';
import 'package:softai/theme/app_colors.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initDependencies();

  runApp(const MyApp());
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Skillena',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: AppColors.primaryBlue,
//         ),
//         useMaterial3: true,
//       ),
//       home: const AuthGate(),
//     );
//   }
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Skillena',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryBlue),
        useMaterial3: true,
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: WidgetStateProperty.all(AppColors.primaryBlue),
        ),
      ),
      home: const AuthGate(),

      // 🟢 Localization Setup
      localizationsDelegates: const [
        AppLocalizations.delegate, // generated from .arb files
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supported in supportedLocales) {
          if (supported.languageCode == locale?.languageCode) {
            return supported;
          }
        }
        return supportedLocales.first;
      },
    );
  }
}
