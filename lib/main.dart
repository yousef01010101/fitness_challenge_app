import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart'; // 1. استيراد البروفايدر
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'providers/theme_provider.dart'; // 2. استيراد ملف الثيم

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    // 3. تغليف التطبيق بالبروفايدر
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 4. الاستماع للتغييرات
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Fitness Challenge App',
      debugShowCheckedModeBanner: false,
      
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      
      // 5. ربط المود بالبروفايدر بدلاً من النظام
      themeMode: themeProvider.themeMode, 
      
      home: const LoginScreen(),
    );
  }
}
