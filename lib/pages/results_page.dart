import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../main.dart';

class ResultsPage extends StatelessWidget {
  final int delta;
  final bool wasCorrect;

  const ResultsPage({
    super.key,
    required this.delta,
    required this.wasCorrect,
  });

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Results'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF2196F3), // Primary blue
                Color(0xFF1976D2), // Darker blue
              ],
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Consumer<AppState>(
          builder: (context, appState, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  color: wasCorrect ? customColors.success : Theme.of(context).colorScheme.error,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(
                          wasCorrect ? Icons.check_circle : Icons.cancel,
                          size: 64,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          wasCorrect ? 'Correct!' : 'Incorrect',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Score Change: ${delta >= 0 ? '+' : ''}$delta',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Stats',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text('Trust Score: ${appState.trustScore.round()}'),
                        Text('Current Streak: ${appState.currentStreak}'),
                        Text('Best Streak: ${appState.bestStreak}'),
                        Text('Total Played: ${appState.totalScenariosPlayed}'),
                        Text('Correct IDs: ${appState.correctIdentifications}'),
                        Text('Scams Caught: ${appState.scamsCaught}'),
                        Text('False Alarms: ${appState.falseAlarms}'),
                        Text('Perfect Scores: ${appState.perfectScores}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Explanation',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(appState.current.explanation),
                        const SizedBox(height: 16),
                        if (appState.current.redFlags.isNotEmpty) ...[
                          Text(
                            'Red Flags:',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: appState.current.redFlags
                                .map((flag) => Chip(
                                      label: Text(flag),
                                      backgroundColor: Theme.of(context).colorScheme.error.withOpacity(0.1),
                                      side: BorderSide(color: Theme.of(context).colorScheme.error),
                                    ))
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Back to Home'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}