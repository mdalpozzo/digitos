import 'package:digitos/screens/game_screen/game_screen.dart';
import 'package:digitos/screens/login/login_screen.dart';
import 'package:digitos/screens/register/register.dart';
import 'package:digitos/screens/update_username/update_username_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import 'screens/home/home_screen.dart';
import 'screens/settings/settings_screen.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(key: Key('main menu')),
      routes: [
        GoRoute(
          path: 'game',
          builder: (context, state) {
            // todo transition?
            return const GameScreen(key: Key('game'));
          },
        ),
        GoRoute(
          path: 'settings',
          builder: (context, state) =>
              const SettingsScreen(key: Key('settings')),
        ),
        GoRoute(
          path: 'login',
          builder: (context, state) => const LoginScreen(key: Key('login')),
        ),
        GoRoute(
          path: 'register',
          builder: (context, state) =>
              const RegisterScreen(key: Key('register')),
        ),
        GoRoute(
          path: 'register',
          builder: (context, state) =>
              const UpdateUserNameScreen(key: Key('updateUserName')),
        ),
      ],
    ),
  ],
);
