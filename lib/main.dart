
import 'package:flutter/material.dart';
import 'package:scamshield/screens/main_screen.dart';

void main() => runApp(const ScamShieldApp());

class ScamShieldApp extends StatelessWidget {
  const ScamShieldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ScamShield',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      home: const MainScreen(),
    );
  }
}

