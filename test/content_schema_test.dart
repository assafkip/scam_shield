import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:scamshield/content/schema.dart';

void main() {
  group('Scenario JSON Schema', () {
    test('parses valid Scenario JSON correctly', () {
      final jsonString = '''
      {
        "id": "test_scenario",
        "title": "Test Scenario",
        "context": "This is a test context.",
        "tacticTags": ["authority", "emotion"],
        "steps": [
          {
            "id": "step1",
            "type": "message",
            "text": "Hello!"
          },
          {
            "id": "step2",
            "type": "choice",
            "text": "Choose wisely.",
            "choices": [
              {"id": "choice1", "text": "Option A", "isSafe": true},
              {"id": "choice2", "text": "Option B", "isSafe": false}
            ]
          },
          {
            "id": "step3",
            "type": "debrief",
            "text": "Debrief text.",
            "isCorrect": true,
            "explanation": "Explanation text."
          }
        ],
        "quiz": {
          "items": [
            {
              "id": "quiz1",
              "question": "What is this?",
              "options": [
                {"id": "opt1", "text": "Opt 1"},
                {"id": "opt2", "text": "Opt 2"}
              ],
              "correctAnswerId": "opt1"
            }
          ]
        }
      }
      ''';
      final jsonMap = json.decode(jsonString);
      final scenario = Scenario.fromJson(jsonMap);

      expect(scenario.id, 'test_scenario');
      expect(scenario.title, 'Test Scenario');
      expect(scenario.context, 'This is a test context.');
      expect(scenario.tacticTags, containsAll([Tactic.authority, Tactic.emotion]));
      expect(scenario.steps.length, 3);
      expect(scenario.steps[0].type, StepType.message);
      expect(scenario.steps[1].type, StepType.choice);
      expect(scenario.steps[1].choices?.length, 2);
      expect(scenario.steps[2].type, StepType.debrief);
      expect(scenario.quiz.items.length, 1);
      expect(scenario.quiz.items[0].question, 'What is this?');
    });

    test('detects duplicate IDs in scenario steps', () {
      final jsonString = '''
      {
        "id": "test_scenario",
        "title": "Test Scenario",
        "context": "Context.",
        "tacticTags": [],
        "steps": [
          {"id": "step1", "type": "message", "text": "Msg 1"},
          {"id": "step1", "type": "message", "text": "Msg 2"}
        ],
        "quiz": {"items": []}
      }
      ''';
      final jsonMap = json.decode(jsonString);
      expect(() => Scenario.fromJson(jsonMap), throwsA(isA<StateError>()));
    });

    test('detects duplicate IDs in quiz items', () {
      final jsonString = '''
      {
        "id": "test_scenario",
        "title": "Test Scenario",
        "context": "Context.",
        "tacticTags": [],
        "steps": [],
        "quiz": {
          "items": [
            {"id": "q1", "question": "Q1", "options": [], "correctAnswerId": "a1"},
            {"id": "q1", "question": "Q2", "options": [], "correctAnswerId": "a2"}
          ]
        }
      }
      ''';
      final jsonMap = json.decode(jsonString);
      expect(() => Scenario.fromJson(jsonMap), throwsA(isA<StateError>()));
    });

    test('detects duplicate IDs in quiz options', () {
      final jsonString = '''
      {
        "id": "test_scenario",
        "title": "Test Scenario",
        "context": "Context.",
        "tacticTags": [],
        "steps": [],
        "quiz": {
          "items": [
            {
              "id": "q1",
              "question": "Q1",
              "options": [
                {"id": "o1", "text": "Opt 1"},
                {"id": "o1", "text": "Opt 2"}
              ],
              "correctAnswerId": "o1"
            }
          ]
        }
      }
      ''';
      final jsonMap = json.decode(jsonString);
      expect(() => Scenario.fromJson(jsonMap), throwsA(isA<StateError>()));
    });
  });
}
