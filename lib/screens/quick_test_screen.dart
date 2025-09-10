import 'package:flutter/material.dart';
import 'package:scamshield/models/scenario.dart';
import 'package:scamshield/services/content_loader.dart';

class QuickTestScreen extends StatefulWidget {
  const QuickTestScreen({super.key});

  @override
  State<QuickTestScreen> createState() => _QuickTestScreenState();
}

class _QuickTestScreenState extends State<QuickTestScreen> {
  List<QuizItem> testItems = [];
  int currentQuestionIndex = 0;
  int correctAnswers = 0;
  int? selectedAnswer;
  bool showingResult = false;
  bool testCompleted = false;

  @override
  void initState() {
    super.initState();
    _loadTestItems();
  }

  void _loadTestItems() {
    setState(() {
      testItems = ContentLoader.getQuickTestItems();
    });
  }

  void _selectAnswer(int index) {
    if (showingResult) return;
    
    setState(() {
      selectedAnswer = index;
    });

    // Show result after a brief delay
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        showingResult = true;
        if (index == testItems[currentQuestionIndex].correctIndex) {
          correctAnswers++;
        }
      });

      // Auto-advance after showing result
      Future.delayed(const Duration(seconds: 2), () {
        _nextQuestion();
      });
    });
  }

  void _nextQuestion() {
    if (currentQuestionIndex < testItems.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedAnswer = null;
        showingResult = false;
      });
    } else {
      setState(() {
        testCompleted = true;
      });
    }
  }

  String _getSummaryMessage() {
    final percentage = correctAnswers / testItems.length;
    if (percentage >= 0.8) {
      return "Excellent! You're great at spotting scams.";
    } else if (percentage >= 0.6) {
      return "Good job! You're getting better at identifying scams.";
    } else {
      return "Keep practicing! Scam detection takes time to master.";
    }
  }

  List<String> _getTips() {
    return [
      "Always verify requests through official channels",
      "Be suspicious of urgent or high-pressure tactics",
      "Never give personal information to unsolicited contacts",
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (testItems.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quick Test')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (testCompleted) {
      return _buildResultsScreen();
    }

    final currentQuestion = testItems[currentQuestionIndex];
    final progress = (currentQuestionIndex + 1) / testItems.length;

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
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    Expanded(
                      child: Text(
                        'Quick Test ${currentQuestionIndex + 1}/10',
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),

                const SizedBox(height: 16),

                // Progress bar
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),

                const SizedBox(height: 32),

                // Question
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      currentQuestion.question,
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Answer options
                Expanded(
                  child: ListView.builder(
                    itemCount: currentQuestion.options.length,
                    itemBuilder: (context, index) {
                      final isSelected = selectedAnswer == index;
                      final isCorrect = index == currentQuestion.correctIndex;
                      
                      Color? backgroundColor;
                      Color? borderColor;
                      
                      if (showingResult) {
                        if (isCorrect) {
                          backgroundColor = Colors.green.withOpacity(0.1);
                          borderColor = Colors.green;
                        } else if (isSelected && !isCorrect) {
                          backgroundColor = Colors.red.withOpacity(0.1);
                          borderColor = Colors.red;
                        }
                      } else if (isSelected) {
                        backgroundColor = Theme.of(context).colorScheme.primaryContainer;
                        borderColor = Theme.of(context).colorScheme.primary;
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Card(
                          color: backgroundColor,
                          child: InkWell(
                            onTap: () => _selectAnswer(index),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: borderColor != null
                                    ? Border.all(color: borderColor, width: 2)
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: borderColor ?? 
                                            Theme.of(context).colorScheme.outline,
                                        width: 2,
                                      ),
                                      color: isSelected ? borderColor : null,
                                    ),
                                    child: showingResult && isCorrect
                                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                                        : showingResult && isSelected && !isCorrect
                                            ? const Icon(Icons.close, size: 16, color: Colors.white)
                                            : null,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      currentQuestion.options[index],
                                      style: Theme.of(context).textTheme.bodyLarge,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsScreen() {
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
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                
                // Score display
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.quiz,
                          size: 64,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Test Complete!',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '$correctAnswers/10',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getSummaryMessage(),
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Tips
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quick Tips:',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ..._getTips().map((tip) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                size: 20,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  tip,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Action buttons
                FilledButton(
                  onPressed: () {
                    setState(() {
                      currentQuestionIndex = 0;
                      correctAnswers = 0;
                      selectedAnswer = null;
                      showingResult = false;
                      testCompleted = false;
                    });
                    _loadTestItems();
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Take Test Again'),
                ),

                const SizedBox(height: 12),

                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Back to Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}