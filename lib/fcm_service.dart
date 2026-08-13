import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Service to manage FCM tokens
/// Call FCMService.setupForUser(uid) after user logs in
class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static StreamSubscription<String>? _tokenRefreshSubscription;
  static String? _currentUid;

  /// Call this after user logs in
  /// This will:
  /// 1. Get FCM token
  /// 2. Save to Firestore (subcollection + user doc)
  /// 3. Setup token refresh listener
  static Future<void> setupForUser(String uid) async {
    try {
      debugPrint('🔐 FCMService: Setting up for user: $uid');

      _currentUid = uid;

      // Cancel previous listener if exists
      await _tokenRefreshSubscription?.cancel();

      // Get current FCM token
      final token = await _messaging.getToken();

      if (token == null || token.isEmpty) {
        debugPrint('⚠️ FCMService: No FCM token available');
        return;
      }

      debugPrint('🔑 FCMService: Got token: ${token.substring(0, 20)}...');

      // Save token to Firestore
      await _saveToken(uid, token);

      // Setup token refresh listener
      _tokenRefreshSubscription =
          _messaging.onTokenRefresh.listen((newToken) async {
        debugPrint(
            '🔄 FCMService: Token refreshed: ${newToken.substring(0, 20)}...');
        await _saveToken(uid, newToken);
      });

      debugPrint('✅ FCMService: Setup complete');
    } catch (e, stack) {
      debugPrint('❌ FCMService: Setup error: $e');
      debugPrint(stack.toString());
    }
  }

  /// Save FCM token to Firestore
  /// Saves to both:
  /// - users/{uid}/deviceTokens/{token} (subcollection - backend reads from here)
  /// - users/{uid} document (fallback)
  static Future<void> _saveToken(String uid, String token) async {
    try {
      // Save to subcollection (preferred - your backend uses this)
      await _db
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

      // Save to user document as fallback
      await _db.collection('users').doc(uid).set({
        'fcmToken': token,
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint('✅ FCMService: Token saved to Firestore');
    } catch (e) {
      debugPrint('❌ FCMService: Error saving token: $e');
      rethrow;
    }
  }

  /// Call this when user logs out
  /// This will:
  /// 1. Delete token from Firestore
  /// 2. Delete FCM token from device
  /// 3. Cancel token refresh listener
  static Future<void> cleanup(String uid) async {
    try {
      debugPrint('🧹 FCMService: Cleaning up for user: $uid');

      final token = await _messaging.getToken();

      if (token != null) {
        // Delete from Firestore subcollection
        await _db
            .collection('users')
            .doc(uid)
            .collection('deviceTokens')
            .doc(token)
            .delete();

        // Delete FCM token from device
        await _messaging.deleteToken();

        debugPrint('✅ FCMService: Token deleted');
      }

      // Cancel token refresh listener
      await _tokenRefreshSubscription?.cancel();
      _tokenRefreshSubscription = null;
      _currentUid = null;

      debugPrint('✅ FCMService: Cleanup complete');
    } catch (e) {
      debugPrint('❌ FCMService: Cleanup error: $e');
    }
  }

  /// Manual token refresh (if needed)
  static Future<void> refreshToken() async {
    if (_currentUid == null) {
      debugPrint('⚠️ FCMService: No user logged in, cannot refresh token');
      return;
    }

    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await _saveToken(_currentUid!, token);
      }
    } catch (e) {
      debugPrint('❌ FCMService: Token refresh error: $e');
    }
  }

  /// Get current FCM token (for debugging)
  static Future<String?> getCurrentToken() async {
    return await _messaging.getToken();
  }

  /// Check if token exists in Firestore (for debugging)
  static Future<bool> verifyTokenInFirestore(String uid) async {
    try {
      final tokensSnap = await _db
          .collection('users')
          .doc(uid)
          .collection('deviceTokens')
          .get();

      final hasTokens = tokensSnap.docs.isNotEmpty;
      debugPrint(
          '🔍 FCMService: Found ${tokensSnap.docs.length} tokens for user $uid');

      return hasTokens;
    } catch (e) {
      debugPrint('❌ FCMService: Error verifying token: $e');
      return false;
    }
  }
}
