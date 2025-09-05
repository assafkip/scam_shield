
import 'package:flutter/material.dart';
import 'package:scamshield/training/engine.dart';
import 'package:scamshield/training/scenarios.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  late final TrainingEngine _engine;

  @override
  void initState() {
    super.initState();
    _engine = TrainingEngine(scenarios: trainingScenarios);
  }

  void _onChoiceMade(String choiceId) {
    setState(() {
      _engine.makeChoice(choiceId);
    });
  }

  void _onNext() {
    setState(() {
      _engine.next();
    });
  }

  void _onAnswer(String answerId) {
    final isCorrect = _engine.answerRecallQuestion(answerId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isCorrect ? 'Correct!' : 'Incorrect'),
        backgroundColor: isCorrect ? Colors.green : Colors.red,
      ),
    );
    _onNext();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Training'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    switch (_engine.state) {
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
    final scenario = _engine.getCurrentScenario();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(scenario.title, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        Text(scenario.description, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 32),
        ...scenario.choices.map((choice) {
          return ElevatedButton(
            onPressed: () => _onChoiceMade(choice.id),
            child: Text(choice.text),
          );
        }),
      ],
    );
  }

  Widget _buildFeedback() {
    final choice = _engine.lastChoice!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(choice.feedback.title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: choice.feedback.isCorrect ? Colors.green : Colors.red,
        )),
        const SizedBox(height: 16),
        Text(choice.feedback.explanation, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _onNext,
          child: const Text('Continue'),
        ),
      ],
    );
  }

  Widget _buildDebrief() {
    final scenario = _engine.getCurrentScenario();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Debrief', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        Text('Debrief for ${scenario.title} will be here.', style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _onNext,
          child: const Text('Continue'),
        ),
      ],
    );
  }

  Widget _buildRecall() {
    final question = _engine.getCurrentRecallQuestion();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Recall Question', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        Text(question.question, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 32),
        ...question.answers.map((answer) {
          return ElevatedButton(
            onPressed: () => _onAnswer(answer.id),
            child: Text(answer.text),
          );
        }),
      ],
    );
  }

  Widget _buildCompleted() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Training Completed!', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        Text('You have successfully completed the training.', style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Finish'),
        ),
      ],
    );
  }
}
