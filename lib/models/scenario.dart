import 'message.dart';

class Scenario {
  final String id;
  final String audience;
  final String platform;
  final int difficulty;
  final bool isScam;
  final String hint;
  final String explanation;
  final List<String> redFlags;
  final List<Message> messages;
  final int timerSec;

  Scenario({
    required this.id,
    required this.audience,
    required this.platform,
    required this.difficulty,
    required this.isScam,
    required this.hint,
    required this.explanation,
    required this.redFlags,
    required this.messages,
    required this.timerSec,
  });

  factory Scenario.fromJson(Map<String, dynamic> json) {
    return Scenario(
      id: json['id'] as String,
      audience: json['audience'] as String,
      platform: json['platform'] as String,
      difficulty: json['difficulty'] as int,
      isScam: json['isScam'] as bool,
      hint: json['hint'] as String,
      explanation: json['explanation'] as String,
      redFlags: List<String>.from(json['redFlags'] ?? []),
      messages: (json['messages'] as List)
          .map((m) => Message.fromJson(m as Map<String, dynamic>))
          .toList(),
      timerSec: json['timerSec'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'audience': audience,
      'platform': platform,
      'difficulty': difficulty,
      'isScam': isScam,
      'hint': hint,
      'explanation': explanation,
      'redFlags': redFlags,
      'messages': messages.map((m) => m.toJson()).toList(),
      'timerSec': timerSec,
    };
  }
}