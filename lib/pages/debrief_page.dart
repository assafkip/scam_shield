import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../models/scenario.dart';
import '../models/badge.dart';
import '../models/conversation.dart';
import '../models/user_progress.dart';
import '../components/achievement_popup.dart';
import '../components/interactive_chat.dart';
import '../components/xp_bar.dart';
import '../components/streak_indicator.dart';
import '../pages/scenario_picker.dart';

class DebriefPage extends StatefulWidget {
  final int userTrustLevel;
  final bool wasCorrect;
  final ConversationState? conversationState;
  final UserProgress? userProgress;
  final Function(UserProgress)? onComplete;

  const DebriefPage({
    Key? key,
    required this.userTrustLevel,
    required this.wasCorrect,
    this.conversationState,
    this.userProgress,
    this.onComplete,
  }) : super(key: key);

  @override
  State<DebriefPage> createState() => _DebriefPageState();
}

class _DebriefPageState extends State<DebriefPage> {
  ScenarioBadge? _awardedBadge;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndAwardBadge();
    });
  }

  void _checkAndAwardBadge() {
    final appState = Provider.of<AppState>(context, listen: false);
    final badge = appState.awardBadge(widget.userTrustLevel, widget.wasCorrect);

    if (badge != null) {
      setState(() {
        _awardedBadge = badge;
      });

      // Show achievement popup after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          AchievementPopup.show(context, badge);
        }
      });
    }

    // Award XP and update user progress
    if (widget.userProgress != null && widget.onComplete != null) {
      final xpGained = widget.wasCorrect ? 100 : 25;
      final currentLevel = widget.userProgress!.currentLevel;
      final oldStreak = widget.userProgress!.currentStreak;
      final oldMilestone = widget.userProgress!.streakMilestone;

      // Update streak and XP
      var updatedProgress = widget.userProgress!.updateStreak();
      updatedProgress = updatedProgress.copyWith(
        totalXP: updatedProgress.totalXP + xpGained,
      );

      final newLevel = updatedProgress.currentLevel;
      final leveledUp = newLevel != currentLevel;
      final newMilestone = updatedProgress.streakMilestone;
      final hitMilestone = newMilestone > oldMilestone && newMilestone > 0;

      // Save progress immediately
      updatedProgress.save();
      widget.onComplete!(updatedProgress);

      // Show streak milestone popup first if applicable
      if (hitMilestone) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            StreakMilestonePopup.show(
              context,
              updatedProgress.currentStreak,
              updatedProgress,
            );
          }
        });
      }

      // Show XP gain popup
      Future.delayed(Duration(milliseconds: hitMilestone ? 2500 : 1000), () {
        if (mounted) {
          XPGainPopup.show(
            context,
            xpGained,
            levelUp: leveledUp ? newLevel : null,
            userProgress: updatedProgress,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scenario Debrief'),
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
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          final scenario = appState.current;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildResultCard(scenario),
                const SizedBox(height: 16),
                if (widget.conversationState != null)
                  _buildConversationAnalysis(),
                if (widget.conversationState != null)
                  const SizedBox(height: 16),
                _buildTacticsCard(scenario),
                const SizedBox(height: 16),
                _buildTrustLevelComparison(scenario),
                const SizedBox(height: 16),
                _buildExplanationCard(scenario),
                const SizedBox(height: 24),
                _buildNavigationButtons(context, appState),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultCard(Scenario scenario) {
    final isScam = scenario.isScam;
    final title = isScam ? "Why This Was a Scam" : "Why This Was Legitimate";
    final color = widget.wasCorrect ? Colors.green : Colors.red;
    final resultText = widget.wasCorrect
        ? "✅ Correct Assessment!"
        : "❌ Missed the Signs";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                widget.wasCorrect ? Icons.check_circle : Icons.cancel,
                color: color,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  resultText,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationAnalysis() {
    if (widget.conversationState == null) return const SizedBox.shrink();

    final choices = widget.conversationState!.userChoices;
    final safeChoices = choices.where((c) => c.isSafe).length;
    final riskyChoices = choices.length - safeChoices;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Conversation Choices',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Safe Responses: $safeChoices',
                      style: TextStyle(
                        color: safeChoices > riskyChoices ? const Color(0xFF00C851) : Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Risky Responses: $riskyChoices',
                      style: TextStyle(
                        color: riskyChoices > safeChoices ? const Color(0xFFFF4444) : Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              CircularProgressIndicator(
                value: choices.isNotEmpty ? safeChoices / choices.length : 0.0,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(
                  safeChoices > riskyChoices ? const Color(0xFF00C851) : const Color(0xFFFF4444),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...choices.asMap().entries.map((entry) {
            final index = entry.key;
            final choice = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: choice.isSafe
                    ? const Color(0xFF00C851).withOpacity(0.1)
                    : const Color(0xFFFF4444).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: choice.isSafe
                      ? const Color(0xFF00C851).withOpacity(0.3)
                      : const Color(0xFFFF4444).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    choice.isSafe ? '✓' : '⚠',
                    style: TextStyle(
                      fontSize: 16,
                      color: choice.isSafe ? const Color(0xFF00C851) : const Color(0xFFFF4444),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${index + 1}. "${choice.buttonText}"',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTacticsCard(Scenario scenario) {
    final isScam = scenario.isScam;
    final tactics = isScam ? scenario.redFlags : _getLegitimateFactors(scenario);
    final icon = isScam ? "🚩" : "✅";
    final title = isScam ? "Red Flags Identified" : "Trust Factors Present";
    final color = isScam ? Colors.red.shade50 : Colors.green.shade50;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...tactics.map((tactic) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getTacticDescription(tactic),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildTrustLevelComparison(Scenario scenario) {
    final optimalLevel = scenario.isScam ? 15 : 85; // Low trust for scams, high for legitimate
    final difference = (widget.userTrustLevel - optimalLevel).abs();

    Color comparisonColor;
    String assessment;
    if (difference <= 15) {
      comparisonColor = Colors.green;
      assessment = "Excellent judgment!";
    } else if (difference <= 30) {
      comparisonColor = Colors.orange;
      assessment = "Good instincts, minor adjustment needed";
    } else {
      comparisonColor = Colors.red;
      assessment = "Review the warning signs";
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Trust Level Analysis",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Optimal Level:", style: TextStyle(fontSize: 14, color: Colors.grey)),
                  Text("$optimalLevel%", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text("Your Level:", style: TextStyle(fontSize: 14, color: Colors.grey)),
                  Text("${widget.userTrustLevel}%", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: comparisonColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: comparisonColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  difference <= 15 ? Icons.star : difference <= 30 ? Icons.thumb_up : Icons.info,
                  color: comparisonColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    assessment,
                    style: TextStyle(
                      color: comparisonColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExplanationCard(Scenario scenario) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Educational Insight",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            scenario.explanation,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context, AppState appState) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // Return to scenario picker
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => const ScenarioPickerPage(),
                ),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Continue Learning',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              final appState = Provider.of<AppState>(context, listen: false);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => InteractiveChat(
                    scenario: appState.current,
                    userProgress: widget.userProgress,
                    onComplete: widget.onComplete,
                  ),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Review Chat',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  List<String> _getLegitimateFactors(Scenario scenario) {
    // For legitimate scenarios, generate trust factors based on common legitimacy indicators
    List<String> factors = [];

    if (scenario.platform == "email" && scenario.redFlags.isEmpty) {
      factors.add("verified sender");
    }
    if (!scenario.redFlags.contains("urgency") && !scenario.redFlags.contains("urgent tone")) {
      factors.add("no pressure tactics");
    }
    if (!scenario.redFlags.contains("suspicious link") && !scenario.redFlags.contains("unexpected prize")) {
      factors.add("reasonable request");
    }

    // Default factors if none detected
    if (factors.isEmpty) {
      factors.addAll(["verified sender", "reasonable request", "no pressure tactics"]);
    }

    return factors;
  }

  String _getTacticDescription(String tactic) {
    switch (tactic.toLowerCase()) {
      case "urgent tone":
      case "urgency":
        return "Created false time pressure";
      case "mismatched domain":
        return "Sender domain doesn't match claimed organization";
      case "unexpected prize":
        return "Unrealistic promises without prior entry";
      case "suspicious link":
        return "Shortened or suspicious URLs";
      case "verified sender":
        return "Communication from authenticated source";
      case "reasonable request":
        return "Request aligns with normal business practices";
      case "no pressure tactics":
        return "No artificial urgency or threats";
      default:
        return tactic.replaceAll('_', ' ').toUpperCase();
    }
  }
}