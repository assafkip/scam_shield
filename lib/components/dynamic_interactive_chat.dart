import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../models/dynamic_conversation.dart';
import '../models/user_progress.dart';
import '../components/platform_authentic_chat.dart';
import '../services/celebration_service.dart';
import '../utils/haptic_feedback.dart';
import '../pages/trust_page.dart';

class DynamicInteractiveChat extends StatefulWidget {
  final Map<String, dynamic> scenarioData;
  final UserProgress? userProgress;
  final Function(UserProgress)? onComplete;

  const DynamicInteractiveChat({
    Key? key,
    required this.scenarioData,
    this.userProgress,
    this.onComplete,
  }) : super(key: key);

  @override
  State<DynamicInteractiveChat> createState() => _DynamicInteractiveChatState();
}

class _DynamicInteractiveChatState extends State<DynamicInteractiveChat>
    with TickerProviderStateMixin {
  late ConversationState _conversationState;
  late Map<String, DynamicMessage> _messageTree;
  late AnimationController _pressureMeterController;
  late Animation<double> _pressureMeterAnimation;

  @override
  void initState() {
    super.initState();
    _initializeConversation();
    _setupAnimations();
  }

  void _setupAnimations() {
    _pressureMeterController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _pressureMeterAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pressureMeterController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressureMeterController.dispose();
    super.dispose();
  }

  void _initializeConversation() {
    // Parse the message tree from scenario data
    _messageTree = {};
    final messagesData = widget.scenarioData['messages'] as Map<String, dynamic>;

    for (final entry in messagesData.entries) {
      _messageTree[entry.key] = DynamicMessage.fromJson(entry.value);
    }

    // Start with the first message
    final startMessage = _messageTree['start']!;
    _conversationState = ConversationState(
      messageHistory: [startMessage],
      currentMessageId: 'start',
      userSuspicion: 50,
      userResistance: 0,
      manipulationPressure: startMessage.manipulationIntensity,
      currentPhase: startMessage.phase,
    );
  }

  void _makeChoice(ConversationChoice choice) {
    HapticHelper.lightImpact();

    setState(() {
      // Add user's choice message
      final userMessage = DynamicMessage(
        id: 'user_${_conversationState.messageHistory.length}',
        text: choice.text,
        from: 'You',
        isFromScammer: false,
      );

      // Update conversation state based on choice
      final newSuspicion = _conversationState.userSuspicion + choice.suspicionIncrease;
      final newResistance = _conversationState.userResistance + choice.resistanceIncrease;

      // Get the next message
      final nextMessage = _messageTree[choice.nextMessageId];

      if (nextMessage == null) {
        // Conversation ended
        final isSuccess = choice.nextMessageId == 'scam_failed';
        _conversationState = _conversationState.copyWith(
          messageHistory: [..._conversationState.messageHistory, userMessage],
          userSuspicion: newSuspicion,
          userResistance: newResistance,
          isComplete: true,
          userFellForScam: !isSuccess,
        );

        _endConversation(isSuccess);
        return;
      }

      // Add manipulation tactics if user is becoming resistant
      String responseText = nextMessage.text;
      List<ManipulationTactic> newTactics = [..._conversationState.tacticsUsed];

      if (newResistance > 60 && !_conversationState.shouldScammerEscalate) {
        // Scammer escalates tactics
        responseText = ManipulationEngine.generateScammerResponse(
          scenarioType: widget.scenarioData['id'],
          state: _conversationState,
          userChoice: choice,
          currentMessage: nextMessage,
        );

        // Add tactics used in this phase
        newTactics.addAll(nextMessage.tactics);
      }

      final adaptedMessage = DynamicMessage(
        id: nextMessage.id,
        text: responseText,
        from: nextMessage.from,
        isFromScammer: nextMessage.isFromScammer,
        choices: nextMessage.choices,
        phase: nextMessage.phase,
        tactics: nextMessage.tactics,
        manipulationIntensity: nextMessage.manipulationIntensity,
      );

      _conversationState = _conversationState.copyWith(
        messageHistory: [..._conversationState.messageHistory, userMessage, adaptedMessage],
        currentMessageId: choice.nextMessageId,
        userSuspicion: newSuspicion,
        userResistance: newResistance,
        manipulationPressure: nextMessage.manipulationIntensity,
        currentPhase: nextMessage.phase,
        tacticsUsed: newTactics.toSet().toList(),
      );
    });

    // Update pressure meter animation
    _pressureMeterController.animateTo(_conversationState.pressureLevel);

    // Show feedback for choice
    _showChoiceFeedback(choice);

    // Auto-scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _showChoiceFeedback(ConversationChoice choice) {
    if (choice.isOptimal) {
      CelebrationService.show(
        CelebrationType.correctAnswer,
        context,
        xp: 50,
        position: Offset(
          MediaQuery.of(context).size.width / 2,
          MediaQuery.of(context).size.height / 2,
        ),
      );
    } else if (choice.suspicionIncrease < 0) {
      // User made a risky choice
      HapticHelper.heavyImpact();
    }
  }

  void _scrollToBottom() {
    // Implement scroll to bottom logic
  }

  void _endConversation(bool isSuccess) {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => TrustPage(
              conversationState: null, // We'll need to adapt TrustPage for dynamic conversations
              userProgress: widget.userProgress,
              onComplete: widget.onComplete,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.scenarioData['title'] ?? 'Scam Simulation'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: Column(
        children: [
          _buildPressureMeter(),
          _buildTacticsIndicator(),
          Expanded(
            child: _buildChatInterface(),
          ),
          if (!_conversationState.isComplete && _hasCurrentChoices())
            _buildChoicesSection(),
        ],
      ),
    );
  }

  Widget _buildPressureMeter() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: _conversationState.shouldShowPressureWarning
          ? Colors.red.withOpacity(0.1)
          : Colors.grey.withOpacity(0.05),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Manipulation Pressure',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
              Text(
                '${(_conversationState.pressureLevel * 100).round()}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _conversationState.pressureLevel > 0.7 ? Colors.red : Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          AnimatedBuilder(
            animation: _pressureMeterAnimation,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: _pressureMeterAnimation.value * _conversationState.pressureLevel,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _conversationState.pressureLevel > 0.7
                      ? Colors.red
                      : _conversationState.pressureLevel > 0.4
                          ? Colors.orange
                          : Colors.green,
                ),
              );
            },
          ),
          if (_conversationState.shouldShowPressureWarning)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                '⚠️ High pressure tactics detected',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTacticsIndicator() {
    if (_conversationState.tacticsUsed.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.orange.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Manipulation Tactics Being Used:',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _conversationState.tacticsUsed.map((tactic) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.5)),
                ),
                child: Text(
                  ScamTactics.getTacticName(tactic),
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildChatInterface() {
    // Convert DynamicMessage to format compatible with PlatformAuthenticChat
    final convertedMessages = _conversationState.messageHistory.map((msg) {
      return {
        'id': msg.id,
        'text': msg.text,
        'from': msg.from,
        'isFromScammer': msg.isFromScammer,
      };
    }).toList();

    return Container(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: convertedMessages.length,
        itemBuilder: (context, index) {
          final message = convertedMessages[index];
          final isFromScammer = message['isFromScammer'] as bool;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: isFromScammer
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.end,
              children: [
                if (!isFromScammer) const Spacer(),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isFromScammer
                          ? Colors.grey.shade200
                          : const Color(0xFF2196F3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message['from'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isFromScammer ? Colors.grey.shade600 : Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          message['text'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            color: isFromScammer ? Colors.black87 : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (isFromScammer) const Spacer(),
              ],
            ),
          );
        },
      ),
    );
  }

  bool _hasCurrentChoices() {
    if (_conversationState.messageHistory.isEmpty) return false;
    final lastMessage = _conversationState.messageHistory.last;
    return lastMessage.isFromScammer && lastMessage.choices.isNotEmpty;
  }

  Widget _buildChoicesSection() {
    if (_conversationState.messageHistory.isEmpty) {
      return const SizedBox.shrink();
    }

    final lastMessage = _conversationState.messageHistory.last;
    if (!lastMessage.isFromScammer || lastMessage.choices.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'How do you respond?',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          ...lastMessage.choices.map((choice) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: ElevatedButton(
                onPressed: () => _makeChoice(choice),
                style: ElevatedButton.styleFrom(
                  backgroundColor: choice.isOptimal
                      ? Colors.green.withOpacity(0.1)
                      : choice.suspicionIncrease < 0
                          ? Colors.red.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                  foregroundColor: choice.isOptimal
                      ? Colors.green.shade700
                      : choice.suspicionIncrease < 0
                          ? Colors.red.shade700
                          : Colors.black87,
                  side: BorderSide(
                    color: choice.isOptimal
                        ? Colors.green
                        : choice.suspicionIncrease < 0
                            ? Colors.red
                            : Colors.grey,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  choice.text,
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.left,
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}