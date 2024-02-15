import 'package:flutter/material.dart';

class DailyButton extends StatelessWidget {
  const DailyButton({
    super.key,
    required this.onPress,
  });

  final void Function() onPress;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPress,
      child: Column(
        children: [
          Container(
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
          Text(
            'The Daily',
            style: TextStyle(
              fontFamily: 'Permanent Marker',
              fontSize: 30,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
