import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:push_noti_app/getfcm.dart';
import 'package:push_noti_app/message_view.dart';

AndroidNotificationChannel channel = const AndroidNotificationChannel(
  'id channel',
  'tên channel',
  description: 'quèo quéo queo',
  importance: Importance.max,
  ledColor: Colors.red,
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  // SETUP SOUND FOR ANDROID

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  // SETUP SOUND FOR IOS
  if (Platform.isAndroid) {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('mipmap/ic_launcher'),
      ),
    );
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MyHomePage(title: 'APP NÀY ĐỈNH LẮM'),
        MessageView.routeName: (context) => const MessageView(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> _setUpInteractedMessage() async {
    RemoteMessage? iniitialMessgae =
        await FirebaseMessaging.instance.getInitialMessage();

    if (iniitialMessgae != null) {
      _onMessageOpenedApp(iniitialMessgae);
    }
    FirebaseMessaging.onMessage.listen(_onMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);
    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);

    String? fcmKey = await getFcmToken();
    log('FCM Key : $fcmKey');
  }

  void _onMessageOpenedApp(RemoteMessage message) {
    final payload = message.data['title'];
    if (payload != null) {
      Navigator.pushNamed(
        context,
        MessageView.routeName,
        arguments: payload,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _setUpInteractedMessage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const <Widget>[
          Text(
            'EM CÓ ĐỒNG Ý LÀM NGƯỜI YÊU ANH HONG ?',
            style: TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _onMessage(RemoteMessage event) async {
    if (Platform.isAndroid) {
      final notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: channel.importance,
          priority: Priority.max,
        ),
      );

      await _flutterLocalNotificationsPlugin.show(
        event.notification.hashCode,
        event.notification?.title,
        event.notification?.body,
        notificationDetails,
        payload: jsonEncode(event.data),
      );
    }
  }
}

Future<void> _backgroundMessageHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  final payload = message.data['title'];
  if (payload != null) {
    AlertDialog(
      content: payload,
    );
  }
}
