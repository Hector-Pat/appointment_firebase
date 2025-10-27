import 'package:flutter/material.dart';
import 'package:appointment_firebase/presentation/pages/login_page.dart';
import 'package:appointment_firebase/presentation/pages/register_page.dart';
import 'package:appointment_firebase/presentation/pages/home_page.dart';
import 'package:appointment_firebase/presentation/pages/password_reset_page.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/login': (context) => const LoginPage(),
  '/register': (context) => const RegisterPage(),
  '/home': (context) => const HomePage(),
  '/reset-password': (context) => const PasswordResetPage(),
};
