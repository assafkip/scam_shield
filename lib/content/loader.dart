import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:scamshield/content/schema.dart';

class ContentLoader {
  static Future<List<Scenario>> loadScenarios() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);

    final contentPaths = manifestMap.keys
        .where((String key) => key.startsWith('assets/content/'))
        .toList();

    final List<Scenario> scenarios = [];
    for (final path in contentPaths) {
      final String jsonString = await rootBundle.loadString(path);
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      scenarios.add(Scenario.fromJson(jsonMap));
    }
    return scenarios;
  }
}