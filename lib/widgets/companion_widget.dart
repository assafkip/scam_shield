import 'package:flutter/material.dart';

enum CompanionState { neutral, happy, concerned, sad }

class CompanionWidget extends StatelessWidget {
  final CompanionState state;

  const CompanionWidget({super.key, required this.state});

  String _getImageAsset(CompanionState state) {
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
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          _getImageAsset(state),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey.shade200,
              child: const Icon(
                Icons.error_outline,
                color: Colors.grey,
                size: 32,
              ),
            );
          },
        ),
      ),
    );
  }
}
