import 'dart:developer' as dev;

import 'package:digitos/config_manager.dart';
import 'package:digitos/service_locator.dart';
import 'package:digitos/view_models/game_view_model.dart';
import 'package:digitos/view_models/home_view_model.dart';
import 'package:digitos/view_models/register_view_model.dart';
import 'package:digitos/services/account_service.dart';
import 'package:digitos/services/auth_service/auth_app_wrapper.dart';
import 'package:digitos/services/auth_service/auth_service.dart';
import 'package:digitos/services/game_service.dart';
import 'package:digitos/users/user_session_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import 'app_lifecycle/app_lifecycle.dart';
import 'audio/audio_controller.dart';
import 'features/player_progress/player_progress.dart';
import 'router.dart';
import 'screens/settings/settings.dart';
import 'style/palette.dart';

void main() async {
  final _log = Logger('main');
  _log.info('App start');

  WidgetsFlutterBinding.ensureInitialized();
  // Lock the game to portrait mode on mobile devices.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // Put game into full screen mode on mobile devices.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  try {
    await ConfigManager().init();
  } catch (err) {
    _log.severe('Error loading environment vars', err);
  }

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

  // ServiceLocator depends on ConfigManager init...
  // TODO explicity enforce this relationship (currently implicitly enforced via "main" order of execution)
  try {
    await ServiceLocator.loadServices(
      firebaseOptions: ConfigManager().firebaseConfig.currentPlatform,
    );
  } catch (err) {
    _log.severe('Error loading services', err);
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLifecycleObserver(
      child: MultiProvider(
        providers: [
          Provider<UserSessionManager>(
            create: (context) => UserSessionManager(
              authService: ServiceLocator.get<AuthService>(),
              accountService: ServiceLocator.get<AccountService>(),
            ),
            lazy: false,
          ),
          ChangeNotifierProvider(
            create: (context) => HomeViewModel(
              accountService: ServiceLocator.get<AccountService>(),
              gameService: ServiceLocator.get<GameService>(),
            ),
          ),
          ChangeNotifierProvider(
            create: (context) => RegisterViewModel(
              authService: ServiceLocator.get<AuthService>(),
              accountService: ServiceLocator.get<AccountService>(),
            ),
          ),
          ChangeNotifierProvider(
            create: (context) => GameViewModel(
              accountService: ServiceLocator.get<AccountService>(),
              gameService: ServiceLocator.get<GameService>(),
            ),
          ),
          Provider(create: (context) => SettingsController()),
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
          Provider(create: (context) => Palette()),
          ChangeNotifierProvider(create: (context) => PlayerProgress()),
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
