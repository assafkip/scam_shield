import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../state/app_state.dart';
import '../components/detective_chip.dart';
import '../components/xp_bar.dart';
import '../models/conversation.dart';
import '../models/user_progress.dart';
import '../utils/haptic_feedback.dart';
import '../utils/responsive_builder.dart';
import '../services/celebration_service.dart';
import '../theme/viral_animations.dart';
import 'debrief_page.dart';

class TrustPage extends StatefulWidget {
  final ConversationState? conversationState;
  final UserProgress? userProgress;
  final Function(UserProgress)? onComplete;

  const TrustPage({
    super.key,
    this.conversationState,
    this.userProgress,
    this.onComplete,
  });

  @override
  State<TrustPage> createState() => _TrustPageState();
}

class _TrustPageState extends State<TrustPage> with TickerProviderStateMixin {
  int _starRating = 3;
  DetectiveChipState _mascotState = DetectiveChipState.neutral;
  Timer? _inactivityTimer;
  Timer? _resetTimer;
  DateTime _lastInteraction = DateTime.now();

  @override
  void initState() {
    super.initState();
    _startInactivityTimer();
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    _resetTimer?.cancel();
    super.dispose();
  }

  void _startInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _mascotState = DetectiveChipState.concerned;
        });
      }
    });
  }

  void _onUserInteraction() {
    _lastInteraction = DateTime.now();
    _startInactivityTimer();

    if (_mascotState == DetectiveChipState.concerned) {
      setState(() {
        _mascotState = DetectiveChipState.neutral;
      });
    }
  }

  void _onSubmitEvaluation(AppState appState) {
    final wasCorrect = (appState.current.isScam && _starRating <= 2) ||
                      (!appState.current.isScam && _starRating >= 4);

    setState(() {
      _mascotState = wasCorrect ? DetectiveChipState.happy : DetectiveChipState.sad;
    });

    _resetTimer?.cancel();
    _resetTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _mascotState = DetectiveChipState.neutral;
        });
      }
    });

    final delta = appState.score((_starRating * 20).round()); // Convert stars to percentage

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DebriefPage(
          userTrustLevel: (_starRating * 20).round(),
          wasCorrect: wasCorrect,
          conversationState: widget.conversationState,
          userProgress: widget.userProgress,
          onComplete: widget.onComplete,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trust Evaluation'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF2196F3), // Primary blue
                Color(0xFF1976D2), // Darker blue
              ],
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Consumer<AppState>(
          builder: (context, appState, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'Scenario: ${appState.current.id}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Platform: ${appState.current.platform}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Hint: ${appState.current.hint}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Column(
                  children: [
                    Text(
                      'Based on this conversation, how suspicious are you?',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    if (widget.conversationState != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Remember when they said:',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            ...widget.conversationState!.messages
                                .where((msg) => msg.isFromScammer)
                                .take(2)
                                .map((msg) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    '"${msg.text.length > 60 ? msg.text.substring(0, 60) + '...' : msg.text}"',
                                    style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                                  ),
                                )),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'How trustworthy is this?',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return GestureDetector(
                      onTap: () {
                        HapticHelper.lightImpact();
                        _onUserInteraction();

                        // Star tap animation
                        ViralAnimations.starTap(this, () {
                          // Celebration on peak animation
                          if (index + 1 == 5) {
                            CelebrationService.show(
                              CelebrationType.perfectScore,
                              context,
                              position: Offset(
                                MediaQuery.of(context).size.width / 2,
                                300,
                              ),
                            );
                          }
                        });

                        setState(() {
                          _starRating = index + 1;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          index < _starRating ? Icons.star : Icons.star_border,
                          size: 48,
                          color: _getStarColor(index + 1),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                Text(
                  _getStarDescription(_starRating),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: _getStarColor(_starRating),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '⭐ Definitely Scam',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFFF4444),
                      ),
                    ),
                    Text(
                      '⭐⭐⭐⭐⭐ Completely Safe',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF00C851),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                DetectiveChip(
                  state: _mascotState,
                  onTap: _onUserInteraction,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                HapticHelper.mediumImpact();
                _onSubmitEvaluation(appState);
              },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Submit Evaluation',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Color _getStarColor(int rating) {
    switch (rating) {
      case 1:
        return const Color(0xFFFF4444); // Red - definitely scam
      case 2:
        return const Color(0xFFFF8C00); // Orange - probably scam
      case 3:
        return const Color(0xFFFFD600); // Yellow - uncertain
      case 4:
        return const Color(0xFF8BC34A); // Light green - probably safe
      case 5:
        return const Color(0xFF00C851); // Green - definitely safe
      default:
        return Colors.grey;
    }
  }

  String _getStarDescription(int rating) {
    switch (rating) {
      case 1:
        return 'Definitely a Scam!';
      case 2:
        return 'Probably a Scam';
      case 3:
        return 'Uncertain';
      case 4:
        return 'Probably Safe';
      case 5:
        return 'Completely Safe';
      default:
        return 'Tap stars to rate';
    }
  }
}