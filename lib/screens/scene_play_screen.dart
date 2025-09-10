import 'package:flutter/material.dart';
import 'package:scamshield/models/scenario.dart';
import 'package:scamshield/widgets/chat_bubble.dart';
import 'package:scamshield/widgets/companion_widget.dart';
import 'package:scamshield/widgets/reply_chip.dart';
import 'package:scamshield/screens/debrief_screen.dart';

class ScenePlayScreen extends StatefulWidget {
  final Scenario scenario;

  const ScenePlayScreen({super.key, required this.scenario});

  @override
  State<ScenePlayScreen> createState() => _ScenePlayScreenState();
}

class _ScenePlayScreenState extends State<ScenePlayScreen>
    with TickerProviderStateMixin {
  int currentStepIndex = 0;
  CompanionState companionState = CompanionState.neutral;
  List<String> chatHistory = [];
  String? feedbackMessage;
  bool showingFeedback = false;
  late AnimationController _companionController;
  late AnimationController _feedbackController;

  @override
  void initState() {
    super.initState();
    _companionController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _feedbackController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // Add initial message
    chatHistory.add(widget.scenario.steps[currentStepIndex].text);
    
    // Start idle timer
    _startIdleTimer();
  }

  @override
  void dispose() {
    _companionController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  void _startIdleTimer() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && companionState == CompanionState.neutral) {
        setState(() {
          companionState = CompanionState.concerned;
        });
        _companionController.forward().then((_) => _companionController.reverse());
      }
    });
  }

  void _onChoiceSelected(Choice choice) {
    setState(() {
      // Add user choice to chat
      chatHistory.add('You: ${choice.label}');
      
      // Update companion state
      companionState = choice.safe ? CompanionState.happy : CompanionState.sad;
      
      // Show feedback
      feedbackMessage = widget.scenario.steps[currentStepIndex].feedback;
      showingFeedback = true;
    });

    // Animate companion reaction
    _companionController.forward().then((_) => _companionController.reverse());
    
    // Show feedback animation
    _feedbackController.forward();

    // Auto-advance after showing feedback
    Future.delayed(const Duration(seconds: 2), () {
      if (choice.next == 'debrief') {
        _goToDebrief(choice.safe);
      } else {
        _nextStep();
      }
    });
  }

  void _nextStep() {
    if (currentStepIndex < widget.scenario.steps.length - 1) {
      setState(() {
        currentStepIndex++;
        chatHistory.add(widget.scenario.steps[currentStepIndex].text);
        companionState = CompanionState.neutral;
        showingFeedback = false;
        feedbackMessage = null;
      });
      _feedbackController.reset();
      _startIdleTimer();
    } else {
      _goToDebrief(true);
    }
  }

  void _goToDebrief(bool lastChoiceWasSafe) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DebriefScreen(
          scenario: widget.scenario,
          lastChoiceWasSafe: lastChoiceWasSafe,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = widget.scenario.steps[currentStepIndex];
    final progress = (currentStepIndex + 1) / widget.scenario.steps.length;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar with progress
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back),
                        ),
                        Expanded(
                          child: Text(
                            widget.scenario.title,
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 48), // Balance the back button
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),

              // Companion
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: AnimatedBuilder(
                  animation: _companionController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_companionController.value * 0.1),
                      child: CompanionWidget(state: companionState),
                    );
                  },
                ),
              ),

              // Chat area
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: chatHistory.length,
                  itemBuilder: (context, index) {
                    final message = chatHistory[index];
                    final isUser = message.startsWith('You:');
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ChatBubble(
                        message: isUser ? message.substring(5) : message,
                        isUser: isUser,
                      ),
                    );
                  },
                ),
              ),

              // Feedback area
              if (showingFeedback && feedbackMessage != null)
                AnimatedBuilder(
                  animation: _feedbackController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 50 * (1 - _feedbackController.value)),
                      child: Opacity(
                        opacity: _feedbackController.value,
                        child: Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            feedbackMessage!,
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  },
                ),

              // Reply choices
              if (!showingFeedback)
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: currentStep.choices.map((choice) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ReplyChip(
                          text: choice.label,
                          onTap: () => _onChoiceSelected(choice),
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}