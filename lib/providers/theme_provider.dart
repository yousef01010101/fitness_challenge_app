import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  // الحالة الافتراضية: الوضع النهاري
  ThemeMode _themeMode = ThemeMode.light;

  // Getter لقراءة الحالة من الخارج
  ThemeMode get themeMode => _themeMode;

  // دالة للتبديل بين الوضعين
  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    
    // 🔔 هذا هو السحر: إبلاغ التطبيق بأن شيئاً تغير ليقوم بإعادة الرسم
    notifyListeners();
  }
}