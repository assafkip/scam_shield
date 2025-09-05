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

  String _getLabel(CompanionState state) {
    switch (state) {
      case CompanionState.neutral:
        return 'Neutral';
      case CompanionState.happy:
        return 'Happy';
      case CompanionState.concerned:
        return 'Concerned';
      case CompanionState.sad:
        return 'Sad';
    }
  }

  Color _getColor(CompanionState state) {
    switch (state) {
      case CompanionState.neutral:
        return Colors.grey;
      case CompanionState.happy:
        return Colors.green;
      case CompanionState.concerned:
        return Colors.orange;
      case CompanionState.sad:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      color: _getColor(state),
      alignment: Alignment.center,
      child: Text(
        _getLabel(state),
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}