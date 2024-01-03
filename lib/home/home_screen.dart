// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../settings/settings.dart';
import '../style/my_button.dart';
import '../style/palette.dart';
import '../style/responsive_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final settingsController = context.watch<SettingsController>();
    final audioController = context.watch<AudioController>();

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
            squarishMainArea: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                  child: InkWell(
                    onTap: () {
                      audioController.playSfx(SfxType.buttonTap);
                      GoRouter.of(context).go('/game');
                    },
                    child: Container(
                      width: 100, // Adjust the size as needed
                      height: 100, // Adjust the size as needed
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.play_arrow,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
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
                  ValueListenableBuilder<bool>(
                    valueListenable: settingsController.audioOn,
                    builder: (context, audioOn, child) {
                      return IconButton(
                        onPressed: () => settingsController.toggleAudioOn(),
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

  static const _gapY = SizedBox(height: 10);
  static const _gapX = SizedBox(width: 10);
}
