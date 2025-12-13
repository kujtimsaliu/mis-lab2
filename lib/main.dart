import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/categories_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Notification Service
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Schedule daily notification (you can call this at a specific time)
  // For demonstration, it will show immediately
  await notificationService.scheduleDailyRecipeNotification();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Рецепти',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const CategoriesScreen(),
    );
  }
}
