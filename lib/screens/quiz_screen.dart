import 'package:flutter/material.dart';
import 'package:scamshield/models/scenario.dart';
import 'package:scamshield/widgets/badge_dialog.dart';

class QuizScreen extends StatefulWidget {
  final Scenario scenario;

  const QuizScreen({super.key, required this.scenario});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestionIndex = 0;
  int correctAnswers = 0;
  int? selectedAnswer;
  bool showingResult = false;

  void _selectAnswer(int index) {
    if (showingResult) return;
    
    setState(() {
      selectedAnswer = index;
    });

    // Show result after a brief delay
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        showingResult = true;
        if (index == widget.scenario.quiz.items[currentQuestionIndex].correctIndex) {
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
    if (currentQuestionIndex < widget.scenario.quiz.items.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedAnswer = null;
        showingResult = false;
      });
    } else {
      _showBadge();
    }
  }

  void _showBadge() {
    final percentage = correctAnswers / widget.scenario.quiz.items.length;
    BadgeType badgeType;
    
    if (percentage == 1.0) {
      badgeType = BadgeType.star;
    } else if (percentage >= 0.75) {
      badgeType = BadgeType.gold;
    } else if (percentage >= 0.5) {
      badgeType = BadgeType.silver;
    } else {
      badgeType = BadgeType.bronze;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BadgeDialog(
        badgeType: badgeType,
        score: correctAnswers,
        total: widget.scenario.quiz.items.length,
        onDismiss: () {
          Navigator.of(context).pop(); // Close dialog
          Navigator.of(context).pop(); // Return to menu
          Navigator.of(context).pop(); // Return to home
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = widget.scenario.quiz.items[currentQuestionIndex];
    final progress = (currentQuestionIndex + 1) / widget.scenario.quiz.items.length;

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
                        'Quiz ${currentQuestionIndex + 1}/${widget.scenario.quiz.items.length}',
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
}