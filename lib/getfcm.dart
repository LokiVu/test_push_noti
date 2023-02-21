import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  debugPrint("Handling a background message: ${message.messageId}");
}

Future<void> setupInteractedMessage() async {
  RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();

  if (initialMessage != null) {
    _directToScreen(initialMessage);
  }

  FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await getFcmToken();
}

Future<String?> getFcmToken() async {
  String? fcmKey = await FirebaseMessaging.instance.getToken();
  return fcmKey;
}

void _onMessageOpenedApp(RemoteMessage event) {
  log('Handling _onMessageOpenedApp ${event.data}');
  _directToScreen(event);
}

void _directToScreen(RemoteMessage event) {}
