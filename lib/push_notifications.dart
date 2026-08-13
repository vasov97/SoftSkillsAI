import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushNotifications {
  static final _messaging = FirebaseMessaging.instance;
  static final _db = FirebaseFirestore.instance;
  static final _fln = FlutterLocalNotificationsPlugin();

  // IMPORTANT: This must match the channelId in your backend!
  static const _channelId = 'default_channel';
  static const _channelName = 'SoftAI Notifications';
  static const _channelDesc = 'Important notifications from SoftAI';

  /// Call once after login
  static Future<void> ensureRegistered() async {
    try {
      print('🔔 Starting push notification setup...');

      // 1) Request permissions (iOS + Android 13+)
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      print('📱 Permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        print('❌ Notification permission denied');
        return;
      }

      // iOS: allow banners in foreground
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // 2) Init local notifications
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

      await _fln.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse details) {
          print('🔔 Notification tapped: ${details.payload}');
          // Handle notification tap here
        },
      );

      // 3) Create Android notification channel (CRITICAL!)
      final android = _fln.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      if (android != null) {
        await android.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: _channelDesc,
            importance: Importance.high,
            playSound: true,
            enableVibration: true,
            showBadge: true,
          ),
        );
        print('✅ Android notification channel created: $_channelId');
      }

      // 4) Save current token and keep it fresh
      await _saveCurrentToken();
      _messaging.onTokenRefresh.listen((_) async {
        print('🔄 FCM token refreshed');
        await _saveCurrentToken();
      });

      // 5) Foreground message handler
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        print('📩 Foreground message received:');
        print('  Notification: ${message.notification?.toMap()}');
        print('  Data: ${message.data}');

        // Extract title and body
        String? title =
            message.notification?.title ?? message.data['title'] as String?;
        String? body =
            message.notification?.body ?? message.data['body'] as String?;

        if (title == null && body == null) {
          print('⚠️ No title or body in message, skipping display');
          return;
        }

        // Show local notification
        await _fln.show(
          message.hashCode, // Use unique ID per message
          title ?? 'SoftAI',
          body ?? '',
          NotificationDetails(
            android: AndroidNotificationDetails(
              _channelId,
              _channelName,
              channelDescription: _channelDesc,
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

        print('✅ Local notification displayed');
      });

      // 6) Background/terminated message handler (when app opens from notification)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('🔔 App opened from notification: ${message.data}');
        // Handle navigation based on message.data
        _handleNotificationTap(message.data);
      });

      // 7) Check if app was opened from a terminated state
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        print('🔔 App launched from notification: ${initialMessage.data}');
        _handleNotificationTap(initialMessage.data);
      }

      print('✅ Push notifications setup complete');
    } catch (e, stack) {
      print('❌ Push notification setup error: $e');
      print(stack);
    }
  }

  /// Handle notification tap actions
  static void _handleNotificationTap(Map<String, dynamic> data) {
    print('Handling notification tap with data: $data');

    // Example: Navigate to specific goal if it's a subtask notification
    if (data['type'] == 'SUBTASK_CHECKED') {
      final goalId = data['goalId'];
      final subtaskIndex = data['subtaskIndex'];
      print('Navigate to goal: $goalId, subtask: $subtaskIndex');
      // Add your navigation logic here
    }
  }

  /// Saves FCM token under users/{uid}/deviceTokens/{token}
  static Future<void> _saveCurrentToken() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        print('⚠️ No authenticated user, cannot save token');
        return;
      }

      final token = await _messaging.getToken();
      if (token == null || token.isEmpty) {
        print('⚠️ No FCM token available');
        return;
      }

      print('💾 Saving FCM token: ${token.substring(0, 20)}...');

      final docRef = _db
          .collection('users')
          .doc(uid)
          .collection('deviceTokens')
          .doc(token); // docId = token (easy server pruning)

      final tokenData = <String, dynamic>{
        'token': token,
        'fcmToken': token, // Backend checks both fields
        'platform': defaultTargetPlatform.name,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final snap = await docRef.get();
      if (snap.exists) {
        await docRef.update(tokenData);
        print('✅ FCM token updated');
      } else {
        await docRef.set({
          ...tokenData,
          'createdAt': FieldValue.serverTimestamp(),
        });
        print('✅ FCM token saved for first time');
      }

      // Also save to main user document as fallback
      await _db.collection('users').doc(uid).set({
        'fcmToken': token,
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e, stack) {
      print('❌ Error saving FCM token: $e');
      print(stack);
    }
  }

  /// Optional: Manual token refresh
  static Future<void> refreshToken() async {
    await _saveCurrentToken();
  }

  /// Optional: Delete token on logout
  static Future<void> deleteToken() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      final token = await _messaging.getToken();

      if (uid != null && token != null) {
        // Delete from subcollection
        await _db
            .collection('users')
            .doc(uid)
            .collection('deviceTokens')
            .doc(token)
            .delete();

        // Delete FCM token from Firebase
        await _messaging.deleteToken();

        print('✅ FCM token deleted');
      }
    } catch (e) {
      print('❌ Error deleting token: $e');
    }
  }
}
