import 'package:flutter/material.dart';
import 'package:appointment_firebase/presentation/pages/login_page.dart';
import 'package:appointment_firebase/presentation/pages/register_page.dart';
import 'package:appointment_firebase/presentation/pages/home_page.dart';
import 'package:appointment_firebase/presentation/pages/password_reset_page.dart';
import 'package:appointment_firebase/presentation/pages/messages_page.dart';
import 'package:appointment_firebase/presentation/pages/settings_page.dart';
import 'package:appointment_firebase/presentation/pages/profile_page.dart';
import 'package:appointment_firebase/presentation/pages/info_page.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/login': (context) => const LoginPage(),
  '/register': (context) => const RegisterPage(),
  '/home': (context) => const HomePage(),
  '/reset-password': (context) => const PasswordResetPage(),
  '/messages': (context) => const MessagesPage(),
  '/settings': (context) => const SettingsPage(),
  '/profile': (context) => const ProfilePage(),
  '/info': (context) => const InfoPage(title: 'Información'),
};
