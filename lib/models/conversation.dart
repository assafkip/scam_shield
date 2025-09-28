class ConversationChoice {
  final String id;
  final String buttonText;
  final String? nextMessageId;
  final bool isSafe;
  final String? nextScammerResponse;

  ConversationChoice({
    required this.id,
    required this.buttonText,
    this.nextMessageId,
    required this.isSafe,
    this.nextScammerResponse,
  });

  factory ConversationChoice.fromJson(Map<String, dynamic> json) {
    return ConversationChoice(
      id: json['id'] as String,
      buttonText: json['buttonText'] as String,
      nextMessageId: json['nextMessageId'] as String?,
      isSafe: json['isSafe'] as bool,
      nextScammerResponse: json['nextScammerResponse'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'buttonText': buttonText,
      'nextMessageId': nextMessageId,
      'isSafe': isSafe,
      'nextScammerResponse': nextScammerResponse,
    };
  }
}

class ConversationMessage {
  final String id;
  final String from;
  final String text;
  final List<ConversationChoice> choices;
  final bool isFromScammer;
  final DateTime timestamp;

  ConversationMessage({
    required this.id,
    required this.from,
    required this.text,
    this.choices = const [],
    required this.isFromScammer,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory ConversationMessage.fromJson(Map<String, dynamic> json) {
    return ConversationMessage(
      id: json['id'] as String,
      from: json['from'] as String,
      text: json['text'] as String,
      choices: (json['choices'] as List<dynamic>? ?? [])
          .map((choice) => ConversationChoice.fromJson(choice as Map<String, dynamic>))
          .toList(),
      isFromScammer: json['isFromScammer'] as bool? ?? (json['from'] != 'You'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'from': from,
      'text': text,
      'choices': choices.map((c) => c.toJson()).toList(),
      'isFromScammer': isFromScammer,
    };
  }
}

class ConversationState {
  final List<ConversationMessage> messages;
  final List<ConversationChoice> userChoices;
  final String? currentMessageId;
  final bool isComplete;
  final double suspicionScore; // Based on choices made

  ConversationState({
    this.messages = const [],
    this.userChoices = const [],
    this.currentMessageId,
    this.isComplete = false,
    this.suspicionScore = 50.0,
  });

  ConversationState copyWith({
    List<ConversationMessage>? messages,
    List<ConversationChoice>? userChoices,
    String? currentMessageId,
    bool? isComplete,
    double? suspicionScore,
  }) {
    return ConversationState(
      messages: messages ?? this.messages,
      userChoices: userChoices ?? this.userChoices,
      currentMessageId: currentMessageId ?? this.currentMessageId,
      isComplete: isComplete ?? this.isComplete,
      suspicionScore: suspicionScore ?? this.suspicionScore,
    );
  }

  // Calculate suspicion based on choices made
  double calculateSuspicion() {
    if (userChoices.isEmpty) return 50.0;

    int safeChoices = userChoices.where((choice) => choice.isSafe).length;
    int totalChoices = userChoices.length;

    // Higher suspicion for more safe choices
    return (safeChoices / totalChoices) * 100;
  }
}