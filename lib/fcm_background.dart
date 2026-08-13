import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// If you used FlutterFire CLI, keep this import; otherwise remove it.
import 'firebase_options.dart';

/// MUST be a top-level function and MUST be annotated with vm:entry-point
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background isolate has no Firebase; init it here.
  try {
    // If you didn't use FlutterFire CLI, call: await Firebase.initializeApp();
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  } catch (_) {
    // ignore "already initialized" races
  }

  // Do any background work you need (analytics, update local DB, etc.)
  // If you send DATA-ONLY pushes, show a local notification here.
  // print('BG message: ${message.messageId} ${message.data} ${message.notification?.title}');
}
