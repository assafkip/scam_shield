import 'dart:math';

enum ScamPhase {
  introduction,
  trustBuilding,
  crisisIntro,
  moneyRequest,
  pressure,
  conclusion,
}

enum ManipulationTactic {
  urgency,
  authority,
  socialProof,
  emotion,
  scarcity,
  reciprocity,
}

class ConversationChoice {
  final String id;
  final String text;
  final String nextMessageId;
  final int suspicionIncrease; // How much this increases user suspicion
  final int resistanceIncrease; // How much this increases user resistance
  final bool isOptimal; // Best choice for avoiding scam

  ConversationChoice({
    required this.id,
    required this.text,
    required this.nextMessageId,
    this.suspicionIncrease = 0,
    this.resistanceIncrease = 0,
    this.isOptimal = false,
  });

  factory ConversationChoice.fromJson(Map<String, dynamic> json) {
    return ConversationChoice(
      id: json['id'] as String,
      text: json['text'] as String,
      nextMessageId: json['nextMessageId'] as String,
      suspicionIncrease: json['suspicionIncrease'] as int? ?? 0,
      resistanceIncrease: json['resistanceIncrease'] as int? ?? 0,
      isOptimal: json['isOptimal'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'nextMessageId': nextMessageId,
      'suspicionIncrease': suspicionIncrease,
      'resistanceIncrease': resistanceIncrease,
      'isOptimal': isOptimal,
    };
  }
}

class DynamicMessage {
  final String id;
  final String text;
  final String from;
  final bool isFromScammer;
  final List<ConversationChoice> choices;
  final ScamPhase phase;
  final List<ManipulationTactic> tactics;
  final int manipulationIntensity; // 0-100

  DynamicMessage({
    required this.id,
    required this.text,
    required this.from,
    required this.isFromScammer,
    this.choices = const [],
    this.phase = ScamPhase.introduction,
    this.tactics = const [],
    this.manipulationIntensity = 0,
  });

  factory DynamicMessage.fromJson(Map<String, dynamic> json) {
    return DynamicMessage(
      id: json['id'] as String,
      text: json['text'] as String,
      from: json['from'] as String,
      isFromScammer: json['isFromScammer'] as bool? ?? true,
      choices: (json['choices'] as List?)
          ?.map((choice) => ConversationChoice.fromJson(choice))
          .toList() ?? [],
      phase: ScamPhase.values[json['phase'] as int? ?? 0],
      tactics: (json['tactics'] as List?)
          ?.map((tactic) => ManipulationTactic.values[tactic as int])
          .toList() ?? [],
      manipulationIntensity: json['manipulationIntensity'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'from': from,
      'isFromScammer': isFromScammer,
      'choices': choices.map((choice) => choice.toJson()).toList(),
      'phase': phase.index,
      'tactics': tactics.map((tactic) => tactic.index).toList(),
      'manipulationIntensity': manipulationIntensity,
    };
  }
}

class ConversationState {
  final List<DynamicMessage> messageHistory;
  final String currentMessageId;
  final int userSuspicion; // 0-100
  final int userResistance; // 0-100
  final int manipulationPressure; // 0-100
  final ScamPhase currentPhase;
  final bool isComplete;
  final bool userFellForScam;
  final List<ManipulationTactic> tacticsUsed;

  ConversationState({
    this.messageHistory = const [],
    this.currentMessageId = '',
    this.userSuspicion = 50,
    this.userResistance = 0,
    this.manipulationPressure = 0,
    this.currentPhase = ScamPhase.introduction,
    this.isComplete = false,
    this.userFellForScam = false,
    this.tacticsUsed = const [],
  });

  ConversationState copyWith({
    List<DynamicMessage>? messageHistory,
    String? currentMessageId,
    int? userSuspicion,
    int? userResistance,
    int? manipulationPressure,
    ScamPhase? currentPhase,
    bool? isComplete,
    bool? userFellForScam,
    List<ManipulationTactic>? tacticsUsed,
  }) {
    return ConversationState(
      messageHistory: messageHistory ?? this.messageHistory,
      currentMessageId: currentMessageId ?? this.currentMessageId,
      userSuspicion: (userSuspicion ?? this.userSuspicion).clamp(0, 100),
      userResistance: (userResistance ?? this.userResistance).clamp(0, 100),
      manipulationPressure: (manipulationPressure ?? this.manipulationPressure).clamp(0, 100),
      currentPhase: currentPhase ?? this.currentPhase,
      isComplete: isComplete ?? this.isComplete,
      userFellForScam: userFellForScam ?? this.userFellForScam,
      tacticsUsed: tacticsUsed ?? this.tacticsUsed,
    );
  }

  double get suspicionLevel => userSuspicion / 100.0;
  double get resistanceLevel => userResistance / 100.0;
  double get pressureLevel => manipulationPressure / 100.0;

  bool get shouldScammerEscalate => userResistance > 60;
  bool get shouldShowPressureWarning => manipulationPressure > 70;
}

class ScamTactics {
  static const Map<ManipulationTactic, List<String>> tacticPhrases = {
    ManipulationTactic.urgency: [
      "Act now or lose this opportunity forever",
      "Your account will be closed in 1 hour",
      "Limited time offer expires at midnight",
      "This is time-sensitive, we need to move quickly",
      "Every second we delay makes this worse",
    ],
    ManipulationTactic.authority: [
      "This is Officer Johnson from the IRS",
      "I'm calling from your bank's fraud department",
      "As CEO, I personally selected you",
      "The government requires immediate action",
      "This is an official notice from",
    ],
    ManipulationTactic.socialProof: [
      "Everyone in your area is already enrolled",
      "Sarah from your company just sent \$500",
      "Check my 500+ LinkedIn connections",
      "Thousands of people trust me with their investments",
      "All my other clients have already signed up",
    ],
    ManipulationTactic.emotion: [
      "I thought you were different from the others",
      "My children will go hungry without your help",
      "You're the only one I can trust",
      "Please, I'm desperate and have nowhere else to turn",
      "I've never felt this connection with anyone before",
    ],
    ManipulationTactic.scarcity: [
      "Only 3 spots left available",
      "This won't be offered again",
      "I can only help a select few people",
      "Once this window closes, it's gone forever",
      "I'm only doing this for my closest friends",
    ],
    ManipulationTactic.reciprocity: [
      "After everything I've shared with you",
      "I've already sent you the proof",
      "I helped you, now I need your help",
      "I'm giving you this exclusive opportunity",
      "I've been so open and honest with you",
    ],
  };

  static String getRandomPhrase(ManipulationTactic tactic) {
    final phrases = tacticPhrases[tactic] ?? [];
    if (phrases.isEmpty) return '';
    return phrases[Random().nextInt(phrases.length)];
  }

  static String getTacticName(ManipulationTactic tactic) {
    switch (tactic) {
      case ManipulationTactic.urgency:
        return 'Creating Urgency';
      case ManipulationTactic.authority:
        return 'False Authority';
      case ManipulationTactic.socialProof:
        return 'Social Proof';
      case ManipulationTactic.emotion:
        return 'Emotional Manipulation';
      case ManipulationTactic.scarcity:
        return 'Artificial Scarcity';
      case ManipulationTactic.reciprocity:
        return 'Reciprocity Pressure';
    }
  }

  static String getTacticDescription(ManipulationTactic tactic) {
    switch (tactic) {
      case ManipulationTactic.urgency:
        return 'Creating false time pressure to prevent careful thinking';
      case ManipulationTactic.authority:
        return 'Impersonating officials or experts to gain trust';
      case ManipulationTactic.socialProof:
        return 'Claiming others have already participated';
      case ManipulationTactic.emotion:
        return 'Using emotional appeals to bypass logical thinking';
      case ManipulationTactic.scarcity:
        return 'Claiming limited availability to create fear of missing out';
      case ManipulationTactic.reciprocity:
        return 'Making you feel obligated to return a "favor"';
    }
  }
}

class ManipulationEngine {
  static String generateScammerResponse({
    required String scenarioType,
    required ConversationState state,
    required ConversationChoice userChoice,
    required DynamicMessage currentMessage,
  }) {
    // Update manipulation pressure based on user resistance
    int newPressure = state.manipulationPressure;

    if (state.userResistance > 70) {
      // User is highly resistant - scammer gets desperate
      newPressure += 30;
      return _getDesperateResponse(scenarioType, state);
    } else if (state.userSuspicion > 60) {
      // User is suspicious - scammer tries to rebuild trust
      newPressure += 15;
      return _getTrustBuildingResponse(scenarioType, state);
    } else if (state.userResistance < 30) {
      // User seems vulnerable - scammer escalates
      newPressure += 20;
      return _getEscalationResponse(scenarioType, state);
    }

    return _getStandardResponse(scenarioType, state);
  }

  static String _getDesperateResponse(String scenarioType, ConversationState state) {
    switch (scenarioType) {
      case 'romance':
        return "Wait! Please don't walk away. After everything we've shared? I thought you were different. I guess I was wrong about you.";
      case 'irs':
        return "FINAL WARNING! This is your last chance before we dispatch officers to your location. Do you want to go to jail over \$2,847?";
      case 'job':
        return "Fine, I'll give this opportunity to someone who actually wants to succeed. Your loss - this position pays \$8,000/month.";
      case 'tech':
        return "Sir/Madam, your computer is about to crash! I'm trying to help you but you're not listening. Don't blame me when you lose everything!";
      default:
        return "Please reconsider - this is a limited time opportunity that won't come again.";
    }
  }

  static String _getTrustBuildingResponse(String scenarioType, ConversationState state) {
    switch (scenarioType) {
      case 'romance':
        return "I understand you're being cautious - that's smart. Look, here's my LinkedIn profile. I have 500+ connections. I'm verified.";
      case 'irs':
        return "I understand your concern. This is Agent badge #47291. You can verify my credentials at IRS.gov/verify-agent.";
      case 'job':
        return "I completely understand the skepticism. Here's our company website and my direct corporate email. This is 100% legitimate.";
      case 'tech':
        return "I know this seems suspicious, but check my Microsoft certification number: MS-47291. I'm here to help protect your data.";
      default:
        return "I understand your hesitation. Let me provide some verification to put your mind at ease.";
    }
  }

  static String _getEscalationResponse(String scenarioType, ConversationState state) {
    switch (scenarioType) {
      case 'romance':
        return "I knew I could trust you! You have such a good heart. I hate to ask, but I'm in a desperate situation and you're the only one who can help...";
      case 'irs':
        return "Good, you're being smart about this. Now, to stop the arrest warrant, you need to pay immediately. Buy iTunes gift cards worth \$2,847.";
      case 'job':
        return "Excellent! You're hired. To process your \$5,000/week salary, I just need your SSN and bank routing number for direct deposit setup.";
      case 'tech':
        return "Perfect! Now I can help you. Download TeamViewer so I can remotely access your computer and remove these 47 viruses immediately.";
      default:
        return "Great! Now that you're interested, let me explain exactly what I need from you...";
    }
  }

  static String _getStandardResponse(String scenarioType, ConversationState state) {
    switch (scenarioType) {
      case 'romance':
        return "Thank you for being so understanding. You seem like such a genuine person - that's rare these days.";
      case 'irs':
        return "I'm glad you're taking this seriously. Many people ignore these notices and face serious consequences.";
      case 'job':
        return "I appreciate your interest. We've reviewed thousands of applications and yours stood out.";
      case 'tech':
        return "I can see the viruses multiplying on your system right now. We need to act fast to prevent data loss.";
      default:
        return "I appreciate your attention to this matter. Let me explain more about this opportunity.";
    }
  }

  static List<ManipulationTactic> getTacticsForPhase(ScamPhase phase, String scenarioType) {
    switch (phase) {
      case ScamPhase.introduction:
        return [ManipulationTactic.authority, ManipulationTactic.socialProof];
      case ScamPhase.trustBuilding:
        return [ManipulationTactic.emotion, ManipulationTactic.reciprocity];
      case ScamPhase.crisisIntro:
        return [ManipulationTactic.urgency, ManipulationTactic.emotion];
      case ScamPhase.moneyRequest:
        return [ManipulationTactic.urgency, ManipulationTactic.scarcity];
      case ScamPhase.pressure:
        return [ManipulationTactic.urgency, ManipulationTactic.emotion, ManipulationTactic.authority];
      case ScamPhase.conclusion:
        return [];
    }
  }
}