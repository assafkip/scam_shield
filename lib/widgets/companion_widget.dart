import 'package:flutter/material.dart';
import 'package:scamshield/models/scenario.dart';

class CompanionWidget extends StatelessWidget {
  final CompanionState state;

  const CompanionWidget({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getBackgroundColor(context),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIcon(),
              size: 48,
              color: _getIconColor(context),
            ),
            const SizedBox(height: 4),
            Text(
              _getLabel(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _getIconColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor(BuildContext context) {
    switch (state) {
      case CompanionState.neutral:
        return Theme.of(context).colorScheme.surfaceVariant;
      case CompanionState.happy:
        return Colors.green.withOpacity(0.2);
      case CompanionState.sad:
        return Colors.red.withOpacity(0.2);
      case CompanionState.concerned:
        return Colors.orange.withOpacity(0.2);
    }
  }

  Color _getIconColor(BuildContext context) {
    switch (state) {
      case CompanionState.neutral:
        return Theme.of(context).colorScheme.onSurfaceVariant;
      case CompanionState.happy:
        return Colors.green;
      case CompanionState.sad:
        return Colors.red;
      case CompanionState.concerned:
        return Colors.orange;
    }
  }

  IconData _getIcon() {
    switch (state) {
      case CompanionState.neutral:
        return Icons.face;
      case CompanionState.happy:
        return Icons.sentiment_very_satisfied;
      case CompanionState.sad:
        return Icons.sentiment_very_dissatisfied;
      case CompanionState.concerned:
        return Icons.sentiment_neutral;
    }
  }

  String _getLabel() {
    switch (state) {
      case CompanionState.neutral:
        return 'Watching';
      case CompanionState.happy:
        return 'Good!';
      case CompanionState.sad:
        return 'Risky!';
      case CompanionState.concerned:
        return 'Thinking...';
    }
  }
}