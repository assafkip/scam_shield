/// Unified conversation renderer for PRD-01
/// Single UI component that handles all conversation types

import 'package:flutter/material.dart';
import 'conversation.dart';
import 'pressure_meter.dart';

class UnifiedConversationRenderer extends StatefulWidget {
  final UnifiedConversation conversation;
  final Function(ConversationChoice)? onChoiceSelected;
  final Function(List<int>)? onQuizCompleted;
  final Function()? onConversationCompleted;

  const UnifiedConversationRenderer({
    super.key,
    required this.conversation,
    this.onChoiceSelected,
    this.onQuizCompleted,
    this.onConversationCompleted,
  });

  @override
  State<UnifiedConversationRenderer> createState() => _UnifiedConversationRendererState();
}

class _UnifiedConversationRendererState extends State<UnifiedConversationRenderer> {
  late ConversationState _state;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _state = ConversationState(
      conversationId: widget.conversation.id,
      currentStepId: widget.conversation.steps.isNotEmpty
          ? widget.conversation.steps.first.id
          : 'end',
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.conversation.title),
        backgroundColor: Colors.blue[100],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Exit conversation training',
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CompactPressureMeter(
              pressureLevel: _state.currentPressure,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildContextBanner(),
          _buildPressureMeterStrip(),
          Expanded(
            child: _buildConversationArea(),
          ),
          if (!_state.isCompleted) _buildChoiceArea(),
        ],
      ),
    );
  }

  /// Build context banner with conversation info
  Widget _buildContextBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: Colors.amber[100],
      child: Text(
        'Training scenario: ${widget.conversation.context}',
        style: const TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
        semanticsLabel: 'Training scenario type: ${widget.conversation.context}',
      ),
    );
  }

  /// Build pressure meter strip
  Widget _buildPressureMeterStrip() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[50],
      child: Row(
        children: [
          Text(
            'Pressure Level: ',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          Expanded(
            child: PressureMeter(
              pressureLevel: _state.currentPressure,
              height: 20,
              label: 'Current conversation pressure level',
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Trust: ${_state.trustScorePercentage.toStringAsFixed(0)}%',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  /// Build main conversation message area
  Widget _buildConversationArea() {
    final currentStep = widget.conversation.getStepById(_state.currentStepId);
    if (currentStep == null) {
      return _buildErrorState();
    }

    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      children: [
        ..._buildVisitedMessages(),
        ..._buildCurrentStepMessages(currentStep),
      ],
    );
  }

  /// Build messages from all visited steps
  List<Widget> _buildVisitedMessages() {
    final visitedMessages = <Widget>[];

    for (final stepId in _state.visitedSteps) {
      final step = widget.conversation.getStepById(stepId);
      if (step != null) {
        for (final message in step.messages) {
          visitedMessages.add(_buildMessageBubble(message, isHistorical: true));
        }
      }
    }

    return visitedMessages;
  }

  /// Build messages for current step
  List<Widget> _buildCurrentStepMessages(ConversationStep step) {
    return step.messages
        .map((message) => _buildMessageBubble(message))
        .toList();
  }

  /// Build individual message bubble
  Widget _buildMessageBubble(ConversationMessage message, {bool isHistorical = false}) {
    final isScammer = message.speaker == 'scammer' ||
                     message.speaker == 'bank_security' ||
                     message.speaker != 'system';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Align(
        alignment: isScammer ? Alignment.centerLeft : Alignment.centerRight,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getMessageColor(message.speaker, isHistorical),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getSenderDisplayName(message.speaker),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isHistorical ? Colors.grey[600] : Colors.grey[800],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                message.text,
                style: TextStyle(
                  fontSize: 16,
                  color: isHistorical ? Colors.grey[700] : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Get message bubble color based on sender
  Color _getMessageColor(String speaker, bool isHistorical) {
    if (isHistorical) {
      return Colors.grey[100]!;
    }

    switch (speaker) {
      case 'scammer':
      case 'bank_security':
        return Colors.red[50]!;
      case 'system':
        return Colors.blue[50]!;
      case 'user':
        return Colors.green[50]!;
      default:
        return Colors.grey[50]!;
    }
  }

  /// Get display name for speaker
  String _getSenderDisplayName(String speaker) {
    switch (speaker) {
      case 'scammer':
        return 'Suspicious Contact';
      case 'bank_security':
        return 'Bank Security';
      case 'system':
        return 'System';
      case 'user':
        return 'You';
      default:
        return speaker.replaceAll('_', ' ').toUpperCase();
    }
  }

  /// Build choice selection area
  Widget _buildChoiceArea() {
    final currentStep = widget.conversation.getStepById(_state.currentStepId);
    if (currentStep == null || currentStep.choices.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How do you respond?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            semanticsLabel: 'Choose your response to this message',
          ),
          const SizedBox(height: 12),
          ...currentStep.choices.map((choice) => _buildChoiceButton(choice)),
        ],
      ),
    );
  }

  /// Build individual choice button
  Widget _buildChoiceButton(ConversationChoice choice) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ElevatedButton(
        onPressed: () => _handleChoiceSelection(choice),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(16),
          backgroundColor: choice.safe ? Colors.green[100] : Colors.orange[100],
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          choice.label,
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.left,
        ),
      ),
    );
  }

  /// Handle user choice selection
  void _handleChoiceSelection(ConversationChoice choice) {
    setState(() {
      // Apply choice using the new state method for proper trust/pressure tracking
      _state = _state.applyChoice(choice, _state.currentStepId);

      // Navigate to next step
      if (choice.next == 'debrief') {
        _state = _state.copyWith(isCompleted: true);
        _showDebrief();
      } else {
        final nextStep = widget.conversation.getStepById(choice.next);
        if (nextStep != null) {
          _state = _state.copyWith(currentStepId: choice.next);
          _scrollToBottom();
        } else {
          _state = _state.copyWith(isCompleted: true);
          _showDebrief();
        }
      }
    });

    // Notify parent component
    widget.onChoiceSelected?.call(choice);
  }

  /// Scroll to bottom of conversation
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Show conversation debrief
  void _showDebrief() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildDebriefDialog(),
    );
  }

  /// Build debrief dialog
  Widget _buildDebriefDialog() {
    final quality = widget.conversation.validateQuality();
    final userChoices = _state.userChoices.values.toList();
    final riskyChoices = userChoices.where((choice) => !choice.safe).length;
    final totalChoices = userChoices.length;

    return AlertDialog(
      title: const Text('Conversation Complete'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Training Results',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text('Choices made: $totalChoices'),
            Text('Risky choices: $riskyChoices'),
            const SizedBox(height: 12),

            // Trust Analysis
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trust Analysis',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(_state.trustAnalysis),
                  Text('Final trust level: ${_state.trustScorePercentage.toStringAsFixed(0)}%'),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Pressure Analysis
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pressure Analysis',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(_state.pressureAnalysis),
                  Text('Final pressure level: ${_state.currentPressure.toStringAsFixed(0)}%'),
                  if (_state.pressureTrace.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Pressure trace: ${_state.pressureTrace.map((t) => '${t.pressureDelta > 0 ? '+' : ''}${t.pressureDelta.toStringAsFixed(0)}').join(' → ')}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Scenario Quality (Dev Info)',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Text('Depth: ${quality.depth} (req: ≥8)'),
            Text('Branching: ${quality.branchingPoints} (req: ≥2)'),
            Text('Tactics: ${quality.tacticsCovered.join(', ')}'),
            const SizedBox(height: 16),
            if (widget.conversation.quiz.isNotEmpty)
              ElevatedButton(
                onPressed: _startQuiz,
                child: const Text('Take Quiz'),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close dialog
            Navigator.of(context).pop(); // Return to menu
          },
          child: const Text('Back to Menu'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close dialog
            widget.onConversationCompleted?.call();
          },
          child: const Text('Continue'),
        ),
      ],
    );
  }

  /// Start quiz phase
  void _startQuiz() {
    Navigator.of(context).pop(); // Close debrief
    // TODO: Implement quiz UI
    // For now, just notify completion
    widget.onQuizCompleted?.call([]);
  }

  /// Build error state when step not found
  Widget _buildErrorState() {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.orange,
              ),
              const SizedBox(height: 16),
              const Text(
                'Training Scenario Error',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'This scenario is temporarily unavailable. Please try another one.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Return to Menu'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}