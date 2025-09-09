
import 'package:scamshield/content/schema.dart';
import 'package:scamshield/content/loader.dart';

// This list will be populated by the ContentLoader
// For now, it's a placeholder to satisfy the TrainingEngine constructor
// In a real app, you would load these dynamically.
final trainingScenarios = <Scenario>[];

// Function to load scenarios (used by TrainingScreen)
Future<List<Scenario>> loadAllTrainingScenarios() async {
  return await ContentLoader.loadScenarios();
}
