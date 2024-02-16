import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class NumbersLoadingScreen extends StatelessWidget {
  const NumbersLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: RiveAnimation.asset(
          'assets/animations/rive/loading_numbers.riv',
        ),
      ),
    );
  }
}
