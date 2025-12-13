import 'dart:math';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../services/api_service.dart';
import '../models/meal.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final ApiService _apiService = ApiService();

  Future<void> initialize() async {
    // Request notification permissions
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    }

    // Initialize local notifications
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'daily_recipe_channel',
      'Daily Recipe Notifications',
      description: 'Notifications for daily recipe recommendations',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Get FCM token
    String? token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');
  }

  void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Handling foreground message: ${message.messageId}');

    final notification = message.notification;
    if (notification != null) {
      await _showLocalNotification(
        notification.title ?? 'Рецепт на денот',
        notification.body ?? 'Погледнете го денешниот рецепт!',
      );
    }
  }

  Future<void> _showLocalNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'daily_recipe_channel',
      'Daily Recipe Notifications',
      channelDescription: 'Notifications for daily recipe recommendations',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      0,
      title,
      body,
      details,
    );
  }

  Future<void> scheduleDailyRecipeNotification() async {
    // Fetch a random meal from a random category
    final categories = ['Beef', 'Chicken', 'Dessert', 'Lamb', 'Pasta', 'Seafood', 'Vegetarian'];
    final random = Random();
    final randomCategory = categories[random.nextInt(categories.length)];

    try {
      final meals = await _apiService.getMealsByCategory(randomCategory);
      if (meals.isNotEmpty) {
        final randomMeal = meals[random.nextInt(meals.length)];

        await _showLocalNotification(
          'Рецепт на денот 🍽️',
          'Денес ви препорачуваме: ${randomMeal.strMeal}',
        );
      }
    } catch (e) {
      print('Error fetching random meal: $e');
      await _showLocalNotification(
        'Рецепт на денот 🍽️',
        'Отворете ја апликацијата и погледнете нов рецепт!',
      );
    }
  }
}

// Top-level function for background message handling
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling background message: ${message.messageId}');
}
