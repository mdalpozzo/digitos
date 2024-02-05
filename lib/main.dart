// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:developer' as dev;

import 'package:digitos/config_manager.dart';
import 'package:digitos/screens/game_screen/game_view_model.dart';
import 'package:digitos/screens/register/register_view_model.dart';
import 'package:digitos/services/account_service.dart';
import 'package:digitos/services/auth_service/auth_app_wrapper.dart';
import 'package:digitos/services/auth_service/auth_service.dart';
import 'package:digitos/services/data_store.dart';
import 'package:digitos/services/game_service.dart';
import 'package:digitos/users/user_session_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app_lifecycle/app_lifecycle.dart';
import 'audio/audio_controller.dart';
import 'features/player_progress/player_progress.dart';
import 'router.dart';
import 'screens/settings/settings.dart';
import 'style/palette.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Put game into full screen mode on mobile devices.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  // Lock the game to portrait mode on mobile devices.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  ConfigManager().loadEnv();

  // Basic logging setup.
  Logger.root.level = kDebugMode ? Level.FINE : Level.INFO;
  Logger.root.onRecord.listen((record) {
    dev.log(
      record.message,
      time: record.time,
      level: record.level.value,
      name: record.loggerName,
    );
  });

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLifecycleObserver(
      child: MultiProvider(
        // This is where you add objects that you want to have available
        // throughout your game.
        //
        // Every widget in the game can access these objects by calling
        // `context.watch()` or `context.read()`.
        // See `lib/main_menu/main_menu_screen.dart` for example usage.
        providers: [
          ChangeNotifierProvider<DataStore>(
            create: (_) => DataStore(),
            lazy: false,
          ),
          ChangeNotifierProvider<AuthService>(
            create: (context) =>
                AuthService(dataStore: context.read<DataStore>()),
            lazy: false,
          ),
          ChangeNotifierProvider<AccountService>(
            create: (context) => AccountService(
              authService: context.read<AuthService>(),
              dataStore: context.read<DataStore>(),
            ),
            lazy: false,
          ),
          ChangeNotifierProvider<GameService>(
            create: (context) => GameService(
              dataStore: context.read<DataStore>(),
            ),
            lazy: false,
          ),
          Provider<UserSessionManager>(
            create: (context) => UserSessionManager(
              context.read<AuthService>(),
              context.read<AccountService>(),
            ),
            lazy: false,
          ),
          Provider(create: (context) => SettingsController()),
          Provider(create: (context) => Palette()),
          ChangeNotifierProvider(create: (context) => PlayerProgress()),
          // Set up audio.
          ProxyProvider2<AppLifecycleStateNotifier, SettingsController,
              AudioController>(
            create: (context) => AudioController(),
            update: (context, lifecycleNotifier, settings, audio) {
              audio!.attachDependencies(lifecycleNotifier, settings);
              return audio;
            },
            dispose: (context, audio) => audio.dispose(),
            // Ensures that music starts immediately.
            lazy: false,
          ),
          ChangeNotifierProvider(
            create: (context) => RegisterViewModel(
              authService: context.read<AuthService>(),
              accountService: context.read<AccountService>(),
            ),
          ),
          ChangeNotifierProvider(
            create: (context) => GameViewModel(
              accountService: context.read<AccountService>(),
              gameService: context.read<GameService>(),
            ),
          ),
        ],
        child: Builder(builder: (context) {
          final palette = context.watch<Palette>();

          return AuthAppWrapper(
            child: MaterialApp.router(
              title: 'Digitos',
              theme: ThemeData.from(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: palette.darkPen,
                  background: palette.backgroundMain,
                ),
                textTheme: TextTheme(
                  bodyMedium: TextStyle(color: palette.ink),
                ),
                useMaterial3: true,
              ).copyWith(
                // Make buttons more fun.
                filledButtonTheme: FilledButtonThemeData(
                  style: FilledButton.styleFrom(
                    textStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              routeInformationProvider: router.routeInformationProvider,
              routeInformationParser: router.routeInformationParser,
              routerDelegate: router.routerDelegate,
            ),
          );
        }),
      ),
    );
  }
}
