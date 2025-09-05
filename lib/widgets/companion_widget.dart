import 'package:flutter/material.dart';

enum CompanionState {
  neutral,
  happy,
  concerned,
  sad,
}

class CompanionWidget extends StatelessWidget {
  final CompanionState state;

  const CompanionWidget({super.key, required this.state});

  String _getImagePath(CompanionState state) {
    switch (state) {
      case CompanionState.neutral:
        return 'assets/images/companion_neutral.png';
      case CompanionState.happy:
        return 'assets/images/companion_happy.png';
      case CompanionState.concerned:
        return 'assets/images/companion_concerned.png';
      case CompanionState.sad:
        return 'assets/images/companion_sad.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _getImagePath(state),
      width: 100, // Example size, can be adjusted
      height: 100, // Example size, can be adjusted
      errorBuilder: (context, error, stackTrace) {
        // Fallback to neutral if asset is missing
        return Image.asset('assets/images/companion_neutral.png', width: 100, height: 100);
      },
    );
  }
}