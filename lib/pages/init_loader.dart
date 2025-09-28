import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import 'home_page.dart';

class InitLoader extends StatefulWidget {
  const InitLoader({super.key});

  @override
  State<InitLoader> createState() => _InitLoaderState();
}

class _InitLoaderState extends State<InitLoader> {
  @override
  void initState() {
    super.initState();
    _loadAndNavigate();
  }

  Future<void> _loadAndNavigate() async {
    try {
      print('🚀 InitLoader: Starting app initialization');
      final appState = context.read<AppState>();
      print('🔄 InitLoader: Calling loadScenarios()');
      
      await appState.loadScenarios();
      print('✅ InitLoader: Scenarios loaded');

      await appState.loadBadgesFromStorage();
      print('✅ InitLoader: Badges loaded, navigating to HomePage');
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
        print('✅ InitLoader: Navigation completed');
      } else {
        print('⚠️  InitLoader: Widget unmounted, skipping navigation');
      }
    } catch (e, stackTrace) {
      print('❌ InitLoader ERROR: $e');
      print('❌ Stack trace: $stackTrace');
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Loading Error'),
            content: Text('Failed to load scenarios: $e'),
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
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading ScamShield...'),
          ],
        ),
      ),
    );
  }
}