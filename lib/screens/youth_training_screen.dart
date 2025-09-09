import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scamshield/training/engine.dart';
import 'package:scamshield/content/schema.dart';
import 'package:scamshield/widgets/companion_widget.dart';
import 'package:scamshield/widgets/chat_bubble.dart';
import 'package:scamshield/content/loader.dart';

class YouthTrainingScreen extends StatefulWidget {
  const YouthTrainingScreen({super.key});

  @override
  State<YouthTrainingScreen> createState() => _YouthTrainingScreenState();
}

class _YouthTrainingScreenState extends State<YouthTrainingScreen> {
  late Future<List<Scenario>> _scenariosFuture;
  TrainingEngine? _engine;
  CompanionState _companionState = CompanionState.neutral;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _scenariosFuture = _loadYouthScenarios();
  }

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }

  Future<List<Scenario>> _loadYouthScenarios() async {
    final allScenarios = await ContentLoader.loadScenarios();
    // Filter for youth scenarios (y01-y05)
    return allScenarios.where((scenario) => scenario.id.startsWith('y0')).toList();
  }

  void _startTimer() {
    _cancelTimer();
    _timer = Timer(const Duration(seconds: 3), () {
      setState(() {
        _companionState = CompanionState.concerned;
      });
    });
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _onChoiceMade(String choiceId) {
    _cancelTimer();
    setState(() {
      final chosenOption = _engine!.makeChoice(choiceId);
      _companionState = chosenOption.isSafe ? CompanionState.happy : CompanionState.sad;
    });
  }

  void _onNext() {
    _cancelTimer();
    setState(() {
      _engine!.next();
      if (_engine!.state == TrainingState.scenario) {
        _companionState = CompanionState.neutral;
        _startTimer();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showBadgeDialog(_engine!.getBadgeForCurrentScenario());
        });
      } else if (_engine!.state == TrainingState.completed) {
        _companionState = CompanionState.happy;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showBadgeDialog(_engine!.getBadgeForCurrentScenario());
        });
      }
    });
  }

  void _onAnswer(String questionId, String optionId) {
    final isCorrect = _engine!.answerRecallQuestion(optionId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isCorrect ? 'Correct!' : 'Incorrect'),
        backgroundColor: isCorrect ? Colors.green : Colors.red,
      ),
    );
    _onNext();
  }

  void _showBadgeDialog(BadgeType badgeType) {
    if (badgeType == BadgeType.none) return;

    String badgeAsset;
    String message;

    switch (badgeType) {
      case BadgeType.bronze:
        badgeAsset = 'assets/images/badge_bronze.png';
        message = 'You earned a Bronze Badge! Keep learning.';
        break;
      case BadgeType.silver:
        badgeAsset = 'assets/images/badge_silver.png';
        message = 'You earned a Silver Badge! Well done.';
        break;
      case BadgeType.gold:
        badgeAsset = 'assets/images/badge_gold.png';
        message = 'You earned a Gold Badge! Excellent work.';
        break;
      case BadgeType.star:
        badgeAsset = 'assets/images/badge_star.png';
        message = 'You earned a Star Badge! Perfect score!';
        break;
      case BadgeType.none:
        return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Scenario Completed!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(badgeAsset, width: 100, height: 100),
              const SizedBox(height: 16),
              Text(message),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Next-Gen Scams'),
      ),
      body: FutureBuilder<List<Scenario>>(
        future: _scenariosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading scenarios: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No youth scenarios available.'));
          } else {
            _engine ??= TrainingEngine(scenarios: snapshot.data!);
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CompanionWidget(state: _companionState),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _buildContent(),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildContent() {
    switch (_engine!.state) {
      case TrainingState.scenario:
        return _buildScenario();
      case TrainingState.feedback:
        return _buildFeedback();
      case TrainingState.debrief:
        return _buildDebrief();
      case TrainingState.recall:
        return _buildRecall();
      case TrainingState.completed:
        return _buildCompleted();
    }
  }

  Widget _buildScenario() {
    final scenario = _engine!.getCurrentScenario();
    final currentStep = _engine!.getCurrentStep();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(scenario.title, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        ChatBubble(text: currentStep.text, type: BubbleType.incoming),
        const SizedBox(height: 32),
        if (currentStep.type == StepType.message) ...[
          ElevatedButton(
            onPressed: _onNext,
            child: const Text('Continue'),
          ),
        ] else if (currentStep.type == StepType.choice) ...[
          ...currentStep.choices!.map((choice) {
            return ElevatedButton(
              onPressed: () => _onChoiceMade(choice.id),
              child: ChatBubble(text: choice.text, type: BubbleType.outgoing),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildFeedback() {
    final currentStep = _engine!.getCurrentStep();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(currentStep.text, style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: currentStep.isCorrect! ? Colors.green : Colors.red,
        )),
        const SizedBox(height: 16),
        ChatBubble(text: currentStep.explanation!, type: BubbleType.incoming),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _onNext,
          child: const Text('Continue'),
        ),
      ],
    );
  }

  Widget _buildDebrief() {
    final currentStep = _engine!.getCurrentStep();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Debrief', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        ChatBubble(text: currentStep.text, type: BubbleType.highlight),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _onNext,
          child: const Text('Continue'),
        ),
      ],
    );
  }

  Widget _buildRecall() {
    final question = _engine!.getCurrentRecallQuestion();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Recall Question', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        ChatBubble(text: question.question, type: BubbleType.incoming),
        const SizedBox(height: 32),
        ...question.options.map((option) {
          return ElevatedButton(
            onPressed: () => _onAnswer(question.id, option.id),
            child: ChatBubble(text: option.text, type: BubbleType.outgoing),
          );
        }),
      ],
    );
  }

  Widget _buildCompleted() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Next-Gen Scams Completed!', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        Text('You\'ve completed all youth scenarios and learned to spot modern scams targeting young people.', 
             style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Finish'),
        ),
      ],
    );
  }
}