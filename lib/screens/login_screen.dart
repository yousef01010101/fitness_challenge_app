import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 1. استيراد المكتبة
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // متغير لحالة التحميل
  bool _isLoading = false;

  // دالة تسجيل الدخول الحقيقية
  Future<void> _login() async {
    // 1. تفعيل التحميل
    setState(() {
      _isLoading = true;
    });

    try {
      // 2. محاولة تسجيل الدخول
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      // 3. النجاح: الانتقال للرئيسية
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      // 4. معالجة الأخطاء الشائعة برسائل واضحة للمستخدم
      String message = '';
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided.';
      } else if (e.code == 'invalid-credential') {
        message = 'Wrong email or password.';
      } else {
        message = 'Error: ${e.message}';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } finally {
      // 5. إيقاف التحميل دائماً
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.fitness_center,
                    size: 80,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Welcome Back!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 48),

                  CustomTextField(
                    label: 'Email',
                    hint: 'Enter your email',
                    controller: emailController,
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Password',
                    hint: 'Enter your password',
                    controller: passwordController,
                    prefixIcon: Icons.lock_outline,
                  ),
                  const SizedBox(height: 32),

                  // الزر الآن مربوط بالدالة _login ومتغير _isLoading
                  CustomButton(
                    label: 'Login',
                    isLoading: _isLoading, // تفعيل التحميل في الزر
                    onPressed: _login,
                  ),

                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {},
                    child: const Text("Don't have an account? Sign Up"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
