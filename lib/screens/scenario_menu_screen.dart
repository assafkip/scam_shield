import 'package:flutter/material.dart';
import 'package:scamshield/models/scenario.dart';
import 'package:scamshield/services/content_loader.dart';
import 'package:scamshield/screens/scene_play_screen.dart';

class ScenarioMenuScreen extends StatelessWidget {
  final bool isYouth;

  const ScenarioMenuScreen({super.key, required this.isYouth});

  @override
  Widget build(BuildContext context) {
    final scenarios = isYouth 
        ? ContentLoader.getYouthScenarios()
        : ContentLoader.getCapsuleScenarios();

    return Scaffold(
      appBar: AppBar(
        title: Text(isYouth ? 'Youth Pack' : 'Training Scenarios'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: scenarios.length,
          itemBuilder: (context, index) {
            final scenario = scenarios[index];
            return _buildScenarioCard(context, scenario);
          },
        ),
      ),
    );
  }

  Widget _buildScenarioCard(BuildContext context, Scenario scenario) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScenePlayScreen(scenario: scenario),
          ),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                scenario.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Context: ${scenario.context}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: scenario.tacticTags.map((tag) => Chip(
                  label: Text(
                    tag,
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                  side: BorderSide.none,
                )).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}