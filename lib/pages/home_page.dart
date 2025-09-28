import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../components/badge_widget.dart';
import '../components/interactive_chat.dart';
import 'trust_page.dart';
import 'research_scenario_picker.dart';
import 'research_scenarios_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ScamShield'),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Consumer<AppState>(
            builder: (context, appState, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                // MANDATORY: FBI/FTC Research Training Section
                Card(
                  color: Colors.blue[100],
                  child: ListTile(
                    leading: const Icon(Icons.science, size: 40),
                    title: const Text(
                      'FBI/FTC Research Training',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text('Real scenarios from victim testimonies'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ResearchScenariosPage(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'Trust Score: ${appState.trustScore.round()}',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Text(
                          'Streak: ${appState.currentStreak} | Best: ${appState.bestStreak}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                BadgeProgressIndicator(
                  earnedBadges: appState.earnedBadges,
                  totalScenarios: appState.scenarios.length,
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Badges',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        BadgeGrid(
                          earnedBadges: appState.earnedBadges,
                          allScenarioIds: appState.allScenarioIds,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFF6B35), Color(0xFFFF9500)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.science, color: Colors.white, size: 32),
                      SizedBox(height: 8),
                      Text(
                        'Research-Based Training',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Real scam + legitimate scenarios • Trust calibration',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ResearchScenarioPicker(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.psychology),
                  label: const Text('Start Trust Calibration'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFFFF6B35),
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => InteractiveChat(scenario: appState.current),
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start Legacy Scenario'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF00C851),
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    appState.nextScenario();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Switched to scenario: ${appState.current.id}'),
                      ),
                    );
                  },
                  child: const Text('Next Scenario (Test)'),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Scenario: ${appState.current.id}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          'Platform: ${appState.current.platform}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          'Difficulty: ${appState.current.difficulty}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        ),
      ),
    );
  }
}