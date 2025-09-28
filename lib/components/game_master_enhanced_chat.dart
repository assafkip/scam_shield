import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/dynamic_conversation.dart';
import '../models/user_progress.dart';
import '../services/game_master_engine.dart';
import '../utils/haptic_feedback.dart';
import '../pages/dynamic_debrief_page.dart';

class GameMasterEnhancedChat extends StatefulWidget {
  final Map<String, dynamic> scenarioData;
  final UserProgress? userProgress;
  final Function(UserProgress)? onComplete;

  const GameMasterEnhancedChat({
    Key? key,
    required this.scenarioData,
    this.userProgress,
    this.onComplete,
  }) : super(key: key);

  @override
  State<GameMasterEnhancedChat> createState() => _GameMasterEnhancedChatState();
}

class _GameMasterEnhancedChatState extends State<GameMasterEnhancedChat>
    with TickerProviderStateMixin {
  late ConversationState _conversationState;
  late Map<String, DynamicMessage> _messageTree;
  late AnimationController _pressureMeterController;
  late Animation<double> _pressureMeterAnimation;
  late AnimationController _tacticController;
  late Animation<double> _tacticAnimation;

  String? _currentGameMasterResponse;
  bool _showPressureTimer = false;
  int _pressureTimeRemaining = 0;

  @override
  void initState() {
    super.initState();
    _initializeConversation();
    _setupAnimations();
    _processGameMasterStep();
  }

  void _setupAnimations() {
    _pressureMeterController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _pressureMeterAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pressureMeterController, curve: Curves.easeInOut),
    );

    _tacticController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _tacticAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _tacticController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressureMeterController.dispose();
    _tacticController.dispose();
    super.dispose();
  }

  void _initializeConversation() {
    _messageTree = {};
    final messagesData = widget.scenarioData['messages'] as Map<String, dynamic>;

    for (final entry in messagesData.entries) {
      _messageTree[entry.key] = DynamicMessage.fromJson(entry.value);
    }

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

  void _processGameMasterStep() {
    if (_conversationState.messageHistory.isEmpty) return;

    final currentMessage = _conversationState.messageHistory.last;
    final request = GameMasterRequest(
      type: 'step',
      scenarioId: widget.scenarioData['id'],
      nodeId: currentMessage.id,
      retrieved: {
        'node': {
          'tactics': currentMessage.tactics,
          'manipulationIntensity': currentMessage.manipulationIntensity,
          'text': currentMessage.text,
        }
      },
      capabilities: {
        'allow_tools': ['start_timer', 'advance_node', 'emit_explanation'],
        'timeout_ms': 1500,
      },
    );

    final response = GameMasterEngine.processStep(request);

    setState(() {
      if (response.toolName == 'start_timer') {
        _showPressureTimer = true;
        _pressureTimeRemaining = response.toolInput!['ms'] as int;
        _startPressureTimer();
      } else if (response.replyBlock != null) {
        _currentGameMasterResponse = response.replyBlock!['text'] as String;
        _tacticController.forward();
      }
    });

    _pressureMeterController.animateTo(_conversationState.pressureLevel);
  }

  void _startPressureTimer() {
    if (_pressureTimeRemaining > 0) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted && _pressureTimeRemaining > 0) {
          setState(() {
            _pressureTimeRemaining -= 1000;
          });
          _startPressureTimer();
        }
      });
    }
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

      final newSuspicion = _conversationState.userSuspicion + choice.suspicionIncrease;
      final newResistance = _conversationState.userResistance + choice.resistanceIncrease;

      final nextMessage = _messageTree[choice.nextMessageId];

      if (nextMessage == null) {
        final isSuccess = choice.nextMessageId == 'scam_failed' || choice.nextMessageId == 'scam_avoided';
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

      _conversationState = _conversationState.copyWith(
        messageHistory: [..._conversationState.messageHistory, userMessage, nextMessage],
        currentMessageId: choice.nextMessageId,
        userSuspicion: newSuspicion,
        userResistance: newResistance,
        manipulationPressure: nextMessage.manipulationIntensity,
        currentPhase: nextMessage.phase,
        tacticsUsed: [..._conversationState.tacticsUsed, ...nextMessage.tactics].toSet().toList(),
      );

      _showPressureTimer = false;
      _currentGameMasterResponse = null;
    });

    // Process Game Master response for new message
    Future.delayed(const Duration(milliseconds: 500), () {
      _processGameMasterStep();
    });
  }

  void _endConversation(bool isSuccess) {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => DynamicDebriefPage(
              conversationState: _conversationState,
              scenarioData: widget.scenarioData,
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
        title: Text('${widget.scenarioData['title']} - Game Master Mode'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: Column(
        children: [
          _buildGameMasterHUD(),
          _buildPressureMeter(),
          if (_currentGameMasterResponse != null) _buildGameMasterInsight(),
          Expanded(child: _buildChatInterface()),
          if (!_conversationState.isComplete && _hasCurrentChoices())
            _buildChoicesSection(),
        ],
      ),
    );
  }

  Widget _buildGameMasterHUD() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF303F9F)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.psychology, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          const Text(
            'Game Master Active',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Phase ${_conversationState.currentPhase.index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
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
              Row(
                children: [
                  Text(
                    '${(_conversationState.pressureLevel * 100).round()}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _conversationState.pressureLevel > 0.7 ? Colors.red : Colors.orange,
                    ),
                  ),
                  if (_showPressureTimer) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${(_pressureTimeRemaining / 1000).ceil()}s',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
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

  Widget _buildGameMasterInsight() {
    return AnimatedBuilder(
      animation: _tacticAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _tacticAnimation.value)),
          child: Opacity(
            opacity: _tacticAnimation.value,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4A148C), Color(0xFF6A1B9A)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _currentGameMasterResponse!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildChatInterface() {
    return Container(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _conversationState.messageHistory.length,
        itemBuilder: (context, index) {
          final message = _conversationState.messageHistory[index];
          final isFromScammer = message.isFromScammer;

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
                          : const Color(0xFF6A1B9A),
                      borderRadius: BorderRadius.circular(16),
                      border: isFromScammer && message.tactics.isNotEmpty
                          ? Border.all(color: Colors.orange, width: 2)
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.from,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isFromScammer ? Colors.grey.shade600 : Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          message.text,
                          style: TextStyle(
                            fontSize: 14,
                            color: isFromScammer ? Colors.black87 : Colors.white,
                          ),
                        ),
                        if (isFromScammer && message.tactics.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 4,
                            children: message.tactics.map((tacticId) {
                              final tacticName = ScamTactics.getTacticName(tacticId);
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.orange),
                                ),
                                child: Text(
                                  tacticName,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
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
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        choice.text,
                        style: const TextStyle(fontSize: 14),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    if (choice.isOptimal)
                      const Icon(Icons.shield, size: 16, color: Colors.green),
                    if (choice.suspicionIncrease < 0)
                      const Icon(Icons.warning, size: 16, color: Colors.red),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}