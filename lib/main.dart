// main.dart
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:softai/di/di.dart';
import 'package:softai/fcm_background.dart';
import 'package:softai/l10n/app_localizations.dart';
import 'package:softai/service/auth_wrapper.dart';
import 'package:softai/theme/app_colors.dart';

import 'firebase_options.dart';

// --- Local notifications setup ---
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// CRITICAL: This channel ID MUST match your backend!
// Your backend uses 'default_channel', so we use that here
const AndroidNotificationChannel _defaultChannel = AndroidNotificationChannel(
  'default_channel', // ✅ Changed from 'goal_remainders' to match backend
  'SoftAI Notifications',
  description: 'Important notifications from SoftAI',
  importance: Importance.high,
  playSound: true,
  enableVibration: true,
  showBadge: true,
);

// Keep old channel for backwards compatibility (optional)
const AndroidNotificationChannel _goalChannel = AndroidNotificationChannel(
  'goal_remainders',
  'Goal Reminders',
  description: 'Reminders for goals and subgoals',
  importance: Importance.high,
  playSound: true,
  enableVibration: true,
);

Future<void> _initLocalNotifications() async {
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosInit = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );
  const initSettings = InitializationSettings(
    android: androidInit,
    iOS: iosInit,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (NotificationResponse details) {
      debugPrint('🔔 Notification tapped: ${details.payload}');
      _handleNotificationTap(details.payload);
    },
  );

  // Create BOTH channels (Android 8+)
  final androidPlugin =
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  if (androidPlugin != null) {
    // Create the default channel (used by backend)
    await androidPlugin.createNotificationChannel(_defaultChannel);
    debugPrint('✅ Created notification channel: default_channel');

    // Create the goal reminders channel (backwards compatibility)
    await androidPlugin.createNotificationChannel(_goalChannel);
    debugPrint('✅ Created notification channel: goal_remainders');
  }
}

void _handleNotificationTap(String? payload) {
  if (payload == null) return;
  debugPrint('Handling notification tap with payload: $payload');
  // TODO: Add navigation logic based on payload
}

void wireTokenRefresh(String uid) {
  debugPrint('🔄 Setting up token refresh for user: $uid');

  FirebaseMessaging.instance.onTokenRefresh.listen((token) {
    debugPrint('🔑 FCM token refreshed: ${token.substring(0, 20)}...');

    // Save to subcollection (preferred - backend reads from here)
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('deviceTokens')
        .doc(token)
        .set({
      'token': token,
      'fcmToken': token, // Backend checks both fields
      'platform': Platform.isAndroid ? 'android' : 'ios',
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Also save to user document as fallback
    FirebaseFirestore.instance.collection('users').doc(uid).set({
      'fcmToken': token,
      'lastTokenUpdate': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  });
}

// Foreground messages → show a local notification
void _listenForegroundMessages() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint('📩 Foreground message received:');
    debugPrint('  Notification: ${message.notification?.toMap()}');
    debugPrint('  Data: ${message.data}');

    final notification = message.notification;

    // If there's a notification payload, show it
    if (notification != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _defaultChannel.id, // Use default_channel
            _defaultChannel.name,
            channelDescription: _defaultChannel.description,
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentSound: true,
            presentBadge: true,
          ),
        ),
        payload: message.data.isNotEmpty ? message.data.toString() : null,
      );

      debugPrint('✅ Local notification displayed');
    } else if (message.data.isNotEmpty) {
      // Data-only message - extract title/body from data
      final title = message.data['title'] as String? ?? 'Notification';
      final body = message.data['body'] as String? ?? '';

      flutterLocalNotificationsPlugin.show(
        message.hashCode,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _defaultChannel.id,
            _defaultChannel.name,
            channelDescription: _defaultChannel.description,
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentSound: true,
            presentBadge: true,
          ),
        ),
        payload: message.data.toString(),
      );

      debugPrint('✅ Data-only notification displayed');
    }
  });

  // When user taps a notification and the app opens/resumes
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    debugPrint('🔔 App opened from notification: ${message.data}');

    final type = message.data['type'] as String?;
    final goalId = message.data['goalId'] as String?;
    final subtaskIndex = message.data['subtaskIndex'] as String?;

    debugPrint('  Type: $type');
    debugPrint('  Goal ID: $goalId');
    debugPrint('  Subtask Index: $subtaskIndex');

    // TODO: Navigate to specific goal/subtask
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // CRITICAL: Background handler must be set BEFORE any messaging usage
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await initDependencies();

  // Initialize local notifications
  await _initLocalNotifications();

  // iOS: show alerts/badges/sounds in foreground
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  // Request notification permissions (Android 13+ / iOS)
  final settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    provisional: false,
  );

  debugPrint('📱 Notification permission: ${settings.authorizationStatus}');

  if (settings.authorizationStatus == AuthorizationStatus.denied) {
    debugPrint('❌ Notification permission denied by user');
  } else {
    debugPrint('✅ Notification permission granted');
  }

  // Start foreground listener
  _listenForegroundMessages();

  // Check if app was launched from terminated state via notification
  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    debugPrint('🚀 App launched from notification: ${initialMessage.data}');
    // Handle initial notification data after app loads
  }

  runApp(const MyApp());
}

// --- App widget ---
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
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      localeResolutionCallback: (locale, supportedLocales) {
        for (final supported in supportedLocales) {
          if (supported.languageCode == locale?.languageCode) {
            return supported;
          }
        }
        return supportedLocales.first;
      },
    );
  }
}
