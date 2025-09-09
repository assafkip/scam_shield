
import 'package:flutter/material.dart';
import 'package:scamshield/screens/training_screen.dart';
import 'package:scamshield/screens/youth_training_screen.dart';
import 'package:scamshield/screens/sdat_quiz_screen.dart'; // Import SdatQuizScreen

void main() => runApp(const ScamShieldApp());

class ScamShieldApp extends StatelessWidget {
  const ScamShieldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ScamShield',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ScamShield')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Learn to spot scams — through play.',
              style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            FilledButton.icon(
              icon: const Icon(Icons.play_circle_fill),
              label: const Text('Start Training'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TrainingScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              icon: const Icon(Icons.trending_up),
              label: const Text('Next-Gen Scams'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const YouthTrainingScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              icon: const Icon(Icons.quiz),
              label: const Text('Quick Test (10)'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SdatQuizScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
            Text(
              'Short interactive scenarios • Debriefs • Quick quizzes • Badges',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

