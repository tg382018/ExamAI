import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'api_service.dart';

class NotificationService {
  final ApiService _api;

  // Helper to check if Firebase is initialized
  bool get _isFirebaseReady => Firebase.apps.isNotEmpty;

  // Lazy getter for FirebaseMessaging instance
  FirebaseMessaging get _fcm => FirebaseMessaging.instance;

  NotificationService(this._api);

  Future<void> init() async {
    if (!_isFirebaseReady) return;
    // 1. Request permissions (especially for iOS)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('[NotificationService] User granted permission');

      // 2. Get the token
      await _registerToken();

      // 3. Listen for token refreshes
      _fcm.onTokenRefresh.listen((newToken) {
        debugPrint('[NotificationService] Token refreshed');
        _api.registerDeviceToken(newToken, Platform.isIOS ? 'ios' : 'android');
      });

      // 4. Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint(
            '[NotificationService] Got a message whilst in the foreground!');
        debugPrint('Message data: ${message.data}');

        if (message.notification != null) {
          debugPrint(
              'Message also contained a notification: ${message.notification?.title}');
        }
      });

      // 5. Handle background click
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _handleMessage(message);
      });

      // 6. Handle terminated state click
      _fcm.getInitialMessage().then((message) {
        if (message != null) _handleMessage(message);
      });
    } else {
      debugPrint(
          '[NotificationService] User declined or has not accepted permission');
    }
  }

  void _handleMessage(RemoteMessage message) {
    if (message.data['type'] == 'exam_ready' &&
        message.data['examId'] != null) {
      final examId = message.data['examId'];
      // Use a global key or a navigation service if needed,
      // but for now we can just print and let the app handle it
      // if it's already set up to listen to deep links.
      debugPrint('[NotificationService] Navigating to exam: $examId');
      // Note: Full navigation logic usually requires context or a GlobalKey.
      // Since this is a service, we'll need a way to reach the router.
    }
  }

  Future<void> updateToken() async {
    if (!_isFirebaseReady) return;
    await _registerToken();
  }

  Future<void> _registerToken() async {
    if (!_isFirebaseReady) return;
    try {
      // For iOS, we should wait for the APNS token before calling getToken()
      if (Platform.isIOS) {
        String? apnsToken = await _fcm.getAPNSToken();
        if (apnsToken == null) {
          debugPrint(
              '[NotificationService] APNS token is null. This is expected on SIMULATORS or if certificates are missing.');
          // On simulator, stop here because getToken() will crash/throw.
          if (!kReleaseMode) {
            debugPrint(
                '[NotificationService] Skipping getToken() for iOS Simulator testing.');
            return;
          }
        }
      }

      String? token = await _fcm.getToken();
      if (token != null) {
        debugPrint('[NotificationService] FCM Token: $token');
        await _api.registerDeviceToken(
            token, Platform.isIOS ? 'ios' : 'android');
      }
    } catch (e) {
      debugPrint('[NotificationService] Error getting token: $e');
    }
  }
}
