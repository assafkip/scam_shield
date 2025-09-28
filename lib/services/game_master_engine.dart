import 'dart:convert';
import 'dart:math';
import '../models/dynamic_conversation.dart';

class GameMasterEngine {
  static const Map<String, List<String>> tacticPhrasing = {
    'Authority': [
      "This is Officer Johnson from the IRS",
      "I'm calling from your bank's fraud department",
      "As CEO, I personally selected you"
    ],
    'Urgency': [
      "Act now or lose this opportunity forever",
      "Your account will be closed in 1 hour",
      "Limited time offer expires at midnight"
    ],
    'Social_Proof': [
      "Everyone in your area is already enrolled",
      "Sarah from your company just sent \$500",
      "Check my 500+ LinkedIn connections"
    ],
    'Emotion': [
      "I thought you were different from the others",
      "My children will go hungry without your help",
      "You're the only one I can trust"
    ],
    'Scarcity': [
      "Only 3 spots left",
      "This deal expires in 24 hours",
      "Limited time exclusive offer"
    ],
    'Reciprocity': [
      "I helped you, now you help me",
      "After everything I've done for you",
      "You owe me this favor"
    ]
  };

  static const Map<String, String> tacticExplanations = {
    'Authority': 'Claims to be from official organizations or positions of power',
    'Urgency': 'Creates artificial time pressure to bypass critical thinking',
    'Social_Proof': 'Uses fake testimonials or claims others are participating',
    'Emotion': 'Manipulates feelings of love, guilt, fear, or sympathy',
    'Scarcity': 'Claims limited availability to create FOMO',
    'Reciprocity': 'Exploits obligation and debt to get compliance'
  };

  static GameMasterResponse processStep(GameMasterRequest request) {
    final node = request.retrieved['node'] as Map<String, dynamic>?;
    if (node == null) {
      return GameMasterResponse.replyBlock(
        text: "Unknown scenario state",
        tacticTags: [],
        suggestedNext: "advance_node"
      );
    }

    // Analyze tactics in current node
    final tactics = (node['tactics'] as List<dynamic>?)?.cast<int>() ?? [];
    final tacticNames = tactics.map((t) => _getTacticName(t)).toList();

    // Check if pressure should be applied
    final manipulationIntensity = node['manipulationIntensity'] as int? ?? 0;
    if (manipulationIntensity > 60 && request.capabilities['allow_tools']?.contains('start_timer') == true) {
      return GameMasterResponse.toolCall(
        toolName: 'start_timer',
        toolInput: {
          'scenario_id': request.scenarioId,
          'node_id': request.nodeId,
          'ms': _calculatePressureTime(manipulationIntensity)
        }
      );
    }

    // Generate response based on tactics
    final responseText = _generateTacticExplanation(tacticNames, node);

    return GameMasterResponse.replyBlock(
      text: responseText,
      tacticTags: tacticNames,
      suggestedNext: "advance_node"
    );
  }

  static String _getTacticName(int tacticId) {
    switch (tacticId) {
      case 0: return 'Urgency';
      case 1: return 'Authority';
      case 2: return 'Social_Proof';
      case 3: return 'Emotion';
      case 4: return 'Scarcity';
      case 5: return 'Reciprocity';
      default: return 'Unknown';
    }
  }

  static int _calculatePressureTime(int intensity) {
    // Higher intensity = shorter time pressure
    if (intensity > 80) return 60000;  // 1 minute
    if (intensity > 60) return 90000;  // 1.5 minutes
    return 120000; // 2 minutes
  }

  static String _generateTacticExplanation(List<String> tactics, Map<String, dynamic> node) {
    if (tactics.isEmpty) {
      return "This message appears straightforward, but stay alert for manipulation tactics.";
    }

    final primaryTactic = tactics.first;
    final explanation = tacticExplanations[primaryTactic] ?? "Unknown manipulation technique";

    if (tactics.length > 1) {
      return "⚠️ Multiple tactics detected: ${tactics.join(', ')}. $explanation";
    } else {
      return "⚠️ $primaryTactic tactic detected: $explanation";
    }
  }

  static Map<String, dynamic> generateDeliveryScenario() {
    return {
      "id": "scn_delivery_fee_01",
      "title": "Package Delivery Fee Scam",
      "platform": "sms",
      "difficulty": 3,
      "isScam": true,
      "description": "Fake delivery company demanding immediate payment",
      "messages": {
        "start": {
          "id": "start",
          "text": "URGENT: Package delivery failed. Pay \$3.99 fee now: bit.ly/pkg-fee-pay or package returns to sender today.",
          "from": "DeliveryExpress",
          "isFromScammer": true,
          "phase": 0,
          "tactics": [0, 1], // Urgency, Authority
          "manipulationIntensity": 70,
          "choices": [
            {
              "id": "pay_now",
              "text": "Click the link to pay the fee",
              "nextMessageId": "payment_trap",
              "suspicionIncrease": -25,
              "resistanceIncrease": -20,
              "isOptimal": false
            },
            {
              "id": "verify_company",
              "text": "I'll call the delivery company directly to verify",
              "nextMessageId": "scam_avoided",
              "suspicionIncrease": 40,
              "resistanceIncrease": 50,
              "isOptimal": true
            },
            {
              "id": "ignore_message",
              "text": "This seems suspicious, I'll ignore it",
              "nextMessageId": "scam_avoided",
              "suspicionIncrease": 35,
              "resistanceIncrease": 45,
              "isOptimal": true
            }
          ]
        },
        "payment_trap": {
          "id": "payment_trap",
          "text": "Perfect! Enter your card details below. We need payment within 10 minutes or your package will be permanently lost.",
          "from": "DeliveryExpress",
          "isFromScammer": true,
          "phase": 1,
          "tactics": [0, 4], // Urgency, Scarcity
          "manipulationIntensity": 90,
          "choices": [
            {
              "id": "enter_card",
              "text": "Enter credit card information",
              "nextMessageId": "scam_success",
              "suspicionIncrease": -30,
              "resistanceIncrease": -25,
              "isOptimal": false
            },
            {
              "id": "realize_scam",
              "text": "Wait, this is obviously a scam!",
              "nextMessageId": "scam_failed",
              "suspicionIncrease": 50,
              "resistanceIncrease": 60,
              "isOptimal": true
            }
          ]
        },
        "scam_success": {
          "id": "scam_success",
          "text": "Thank you! Your payment is processing. You'll receive your package soon.",
          "from": "DeliveryExpress",
          "isFromScammer": true,
          "phase": 2,
          "tactics": [],
          "manipulationIntensity": 100,
          "choices": []
        },
        "scam_avoided": {
          "id": "scam_avoided",
          "text": "[User successfully avoided the scam by verifying through official channels]",
          "from": "System",
          "isFromScammer": false,
          "phase": 2,
          "tactics": [],
          "manipulationIntensity": 0,
          "choices": []
        },
        "scam_failed": {
          "id": "scam_failed",
          "text": "[User recognized the scam before providing payment information]",
          "from": "System",
          "isFromScammer": false,
          "phase": 2,
          "tactics": [],
          "manipulationIntensity": 0,
          "choices": []
        }
      },
      "redFlags": [
        "urgency tactics with artificial deadlines",
        "suspicious shortened URLs",
        "requests for immediate payment",
        "claims package will be lost forever",
        "unprofessional communication style"
      ],
      "explanation": "Delivery scams use urgency and authority to pressure victims into paying fake fees. Legitimate delivery companies never demand immediate payment via text message links."
    };
  }

  static Map<String, dynamic> generateViralityHooks(String scenarioId, bool success) {
    return {
      "share_copy_ids": ["share:delivery_defender_1"],
      "invite_gate": {
        "required_invites": 2,
        "reward_pack": "advanced_delivery_scams"
      },
      "badge_id": success ? "badge:verification_champion" : "badge:learning_moment",
      "share_moments": {
        "whatsapp": success
          ? "🛡️ Just spotted a delivery scam! ScamShield training really works."
          : "Almost fell for a delivery scam but learned the warning signs! 📚",
        "tiktok": success
          ? "#ScamAlert Fake delivery fees are everywhere! Stay safe out there 🚨"
          : "POV: You're learning to spot delivery scams 🎯 #ScamEducation",
        "linkedin": success
          ? "Cybersecurity awareness in action: Identifying and avoiding delivery fee scams"
          : "Continuous learning: Understanding modern delivery scam tactics"
      }
    };
  }
}

class GameMasterRequest {
  final String type;
  final String scenarioId;
  final String nodeId;
  final Map<String, dynamic> retrieved;
  final Map<String, dynamic> capabilities;

  GameMasterRequest({
    required this.type,
    required this.scenarioId,
    required this.nodeId,
    required this.retrieved,
    required this.capabilities,
  });

  factory GameMasterRequest.fromJson(Map<String, dynamic> json) {
    return GameMasterRequest(
      type: json['type'] as String,
      scenarioId: json['scenario_id'] as String,
      nodeId: json['node_id'] as String,
      retrieved: json['retrieved'] as Map<String, dynamic>,
      capabilities: json['capabilities'] as Map<String, dynamic>,
    );
  }
}

class GameMasterResponse {
  final String? toolName;
  final Map<String, dynamic>? toolInput;
  final Map<String, dynamic>? replyBlock;

  GameMasterResponse._({this.toolName, this.toolInput, this.replyBlock});

  factory GameMasterResponse.toolCall({
    required String toolName,
    required Map<String, dynamic> toolInput,
  }) {
    return GameMasterResponse._(toolName: toolName, toolInput: toolInput);
  }

  factory GameMasterResponse.replyBlock({
    required String text,
    required List<String> tacticTags,
    required String suggestedNext,
  }) {
    return GameMasterResponse._(
      replyBlock: {
        "text": text,
        "tactic_tags": tacticTags,
        "suggested_next": suggestedNext,
      },
    );
  }

  Map<String, dynamic> toJson() {
    if (toolName != null && toolInput != null) {
      return {
        "tool_name": toolName,
        "tool_input": toolInput,
      };
    } else if (replyBlock != null) {
      return {
        "reply_block": replyBlock,
      };
    }
    throw StateError("Invalid GameMasterResponse state");
  }
}