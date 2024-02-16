import 'package:digitos/screens/game_screen/components/DailyButton.dart';
import 'package:digitos/screens/game_screen/components/LevelButton.dart';
import 'package:digitos/view_models/game_view_model.dart';
import 'package:digitos/view_models/home_view_model.dart';
import 'package:digitos/view_models/settings_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import '../../style/palette.dart';
import '../../style/responsive_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final settingsViewModel = context.watch<SettingsViewModel>();
    final gameViewModel = context.watch<GameViewModel>();

    return Scaffold(
      backgroundColor: palette.backgroundMain,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/home_background.png'),
                fit: BoxFit
                    .cover, // This will cover the entire widget area without stretching the image
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Color.fromARGB(255, 253, 246, 183).withOpacity(0.8),
                  Colors.transparent
                ],
                stops: const [0.5, 1.0],
                center: Alignment.center,
                radius: 1.8,
              ),
            ),
          ),
          ResponsiveScreen(
            topMessageArea: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Best',
                        style: TextStyle(
                          fontFamily: 'Permanent Marker',
                          fontSize: 30,
                        ),
                      ),
                      SizedBox(width: 20),
                      Selector<HomeViewModel, int?>(
                        selector: (_, viewModel) => viewModel.bestScore,
                        builder: (context, bestScore, child) {
                          return Text(
                            bestScore != null ? bestScore.toString() : '-',
                            style: TextStyle(
                              fontFamily: 'Permanent Marker',
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Selector<HomeViewModel, Tuple2<bool?, String?>>(
                    selector: (_, viewModel) => Tuple2(
                          viewModel.loggedIn,
                          viewModel.displayName,
                        ),
                    builder: (context, values, child) {
                      var loggedIn = values.item1 ?? false;
                      var displayName = values.item2;

                      // Absolutely positioned login button
                      return Align(
                        alignment: Alignment.centerRight,
                        child: !loggedIn
                            ? ElevatedButton(
                                onPressed: () {
                                  GoRouter.of(context).go('/login');
                                },
                                child: Text(
                                  'Login',
                                  style: TextStyle(
                                    fontFamily: 'Permanent Marker',
                                    fontSize: 20,
                                  ),
                                ),
                              )
                            : Text(
                                displayName ?? '',
                                style: TextStyle(
                                  fontSize: 24,
                                  color: Colors.black,
                                ),
                              ),
                      );
                    }),
              ],
            ),
            squarishMainArea: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Transform.rotate(
                        angle: -0.1,
                        child: const Text(
                          'Digitos',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Permanent Marker',
                            fontSize: 55,
                            height: 1,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Transform.rotate(
                        angle: 0.1,
                        child: const Text(
                          'A game of numbers',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Permanent Marker',
                            fontSize: 30,
                            height: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: DailyButton(
                    onPress: gameViewModel.onPressDailyButton,
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      LevelButton(
                        level: 1,
                        onPress: () {
                          gameViewModel.onPressLevelButton(difficulty: 1);
                        },
                      ),
                      LevelButton(
                        level: 2,
                        onPress: () {
                          gameViewModel.onPressLevelButton(difficulty: 2);
                        },
                      ),
                      LevelButton(
                        level: 3,
                        onPress: () {
                          gameViewModel.onPressLevelButton(difficulty: 3);
                        },
                      ),
                      LevelButton(
                        level: 4,
                        onPress: () {
                          gameViewModel.onPressLevelButton(difficulty: 4);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            rectangularMenuArea: Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.settings),
                    iconSize: 50,
                    onPressed: () => GoRouter.of(context).push('/settings'),
                  ),
                  Selector<SettingsViewModel, bool>(
                    selector: (_, viewModel) => viewModel.audioOn,
                    builder: (context, audioOn, child) {
                      return IconButton(
                        onPressed: () => settingsViewModel.toggleAudioOn(),
                        iconSize: 50,
                        icon:
                            Icon(audioOn ? Icons.volume_up : Icons.volume_off),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // static const _gapY = SizedBox(height: 10);
  // static const _gapX = SizedBox(width: 10);
}
