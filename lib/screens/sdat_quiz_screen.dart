import 'package:flutter/material.dart';
import 'package:scamshield/content/loader.dart';
import 'package:scamshield/quiz/sdat.dart';
import 'package:scamshield/content/schema.dart'; // Import schema for QuizItem

class SdatQuizScreen extends StatefulWidget {
  const SdatQuizScreen({super.key});

  @override
  State<SdatQuizScreen> createState() => _SdatQuizScreenState();
}

class _SdatQuizScreenState extends State<SdatQuizScreen> {
  late Future<SdatQuiz> _sdatQuizFuture;
  final Map<String, String> _userAnswers = {};
  int _currentQuestionIndex = 0;
  bool _quizCompleted = false;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _sdatQuizFuture = _loadSdatQuiz();
  }

  Future<SdatQuiz> _loadSdatQuiz() async {
    final allScenarios = await ContentLoader.loadScenarios();
    return SdatQuiz(allScenarios: allScenarios);
  }

  void _onOptionSelected(String questionId, String optionId) {
    setState(() {
      _userAnswers[questionId] = optionId;
    });
  }

  void _nextQuestion(SdatQuiz sdatQuiz) {
    setState(() {
      if (_currentQuestionIndex < sdatQuiz.quizItems.length - 1) {
        _currentQuestionIndex++;
      } else {
        _quizCompleted = true;
        _score = sdatQuiz.scoreQuiz(_userAnswers);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quick Test (10)')),
      body: FutureBuilder<SdatQuiz>(
        future: _sdatQuizFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading quiz: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.quizItems.isEmpty) {
            return const Center(child: Text('No quiz items available.'));
          } else {
            final sdatQuiz = snapshot.data!;
            if (_quizCompleted) {
              return _buildQuizSummary(sdatQuiz);
            } else {
              final currentQuestion = sdatQuiz.quizItems[_currentQuestionIndex];
              return _buildQuestion(currentQuestion, sdatQuiz);
            }
          }
        },
      ),
    );
  }

  Widget _buildQuestion(QuizItem question, SdatQuiz sdatQuiz) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            question.question,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ...question.options.map((option) {
            return RadioListTile<String>(
              title: Text(option.text),
              value: option.id,
              selected: _userAnswers[question.id] == option.id,
              // ignore: deprecated_member_use
              onChanged: (value) {
                if (value != null) {
                  _onOptionSelected(question.id, value);
                }
              },
            );
          }), // Added comma here
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _userAnswers.containsKey(question.id)
                ? () => _nextQuestion(sdatQuiz)
                : null,
            child: Text(
              _currentQuestionIndex < sdatQuiz.quizItems.length - 1
                  ? 'Next Question'
                  : 'Submit Quiz',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizSummary(SdatQuiz sdatQuiz) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Quiz Completed!',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Text(
            'Your score: $_score / ${sdatQuiz.quizItems.length}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            sdatQuiz.getSummary(_score),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }
}
