/// Test page for PRD-01 unified conversation engine
/// Allows testing unified engine with sample scenarios

import 'package:flutter/material.dart';
import '../conversation/conversation.dart';
import '../conversation/loader_migration.dart';
import '../conversation/renderer.dart';
import '../feature_flags.dart';

class UnifiedConversationTestPage extends StatefulWidget {
  const UnifiedConversationTestPage({super.key});

  @override
  State<UnifiedConversationTestPage> createState() => _UnifiedConversationTestPageState();
}

class _UnifiedConversationTestPageState extends State<UnifiedConversationTestPage> {
  final _loader = ConversationMigrationLoader();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unified Engine Test'),
        backgroundColor: Colors.green[100],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Feature flag status
            Card(
              color: FeatureFlags.useUnifiedEngine ? Colors.green[50] : Colors.red[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Feature Flag Status',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text('Unified Engine: ${FeatureFlags.useUnifiedEngine ? 'ENABLED' : 'DISABLED'}'),
                    Text('Whitelisted IDs: ${FeatureFlags.whitelistScenarioIds.join(', ')}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Test scenarios
            const Text(
              'Test Scenarios',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Sample scenario (always available)
            Card(
              child: ListTile(
                leading: const Icon(Icons.science),
                title: const Text('Sample Bank Scam'),
                subtitle: const Text('Built-in test scenario (≥8 steps, ≥2 branches)'),
                trailing: _isLoading ? const CircularProgressIndicator() : const Icon(Icons.arrow_forward),
                onTap: _isLoading ? null : () => _launchSampleScenario(),
              ),
            ),

            // Whitelisted scenarios
            ...FeatureFlags.whitelistScenarioIds.where((id) => id != 'sample_001').map(
              (scenarioId) => Card(
                child: ListTile(
                  leading: const Icon(Icons.folder),
                  title: Text('Legacy: $scenarioId'),
                  subtitle: const Text('Migrated from existing assets'),
                  trailing: _isLoading ? null : const Icon(Icons.arrow_forward),
                  onTap: _isLoading ? null : () => _launchLegacyScenario(scenarioId),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Debug info
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Debug Information',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text('Feature flags: ${FeatureFlags.getAllFlags()}'),
                    const Text('This page allows testing the unified conversation engine.'),
                    const Text('Choose a scenario above to test the new rendering system.'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Launch the built-in sample scenario
  void _launchSampleScenario() {
    final conversation = ConversationMigrationLoader.createSampleConversation();
    _navigateToRenderer(conversation);
  }

  /// Launch a legacy scenario through migration loader
  Future<void> _launchLegacyScenario(String scenarioId) async {
    setState(() => _isLoading = true);

    try {
      final conversation = await _loader.loadConversation(scenarioId);
      if (conversation != null) {
        _navigateToRenderer(conversation);
      } else {
        _showError('Failed to load scenario: $scenarioId');
      }
    } catch (e) {
      _showError('Error loading $scenarioId: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Navigate to unified conversation renderer
  void _navigateToRenderer(UnifiedConversation conversation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UnifiedConversationRenderer(
          conversation: conversation,
          onChoiceSelected: (choice) {
            print('Choice selected: ${choice.label} (safe: ${choice.safe})');
          },
          onQuizCompleted: (answers) {
            print('Quiz completed with answers: $answers');
          },
          onConversationCompleted: () {
            print('Conversation completed');
            Navigator.of(context).pop(); // Return to test page
          },
        ),
      ),
    );
  }

  /// Show error dialog
  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}