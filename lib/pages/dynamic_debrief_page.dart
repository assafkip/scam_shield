import 'package:flutter/material.dart';
import '../models/dynamic_conversation.dart';
import '../models/user_progress.dart';
import '../components/badge_widget.dart';
import '../pages/scenario_picker.dart';

class DynamicDebriefPage extends StatefulWidget {
  final ConversationState conversationState;
  final Map<String, dynamic> scenarioData;
  final UserProgress? userProgress;
  final Function(UserProgress)? onComplete;

  const DynamicDebriefPage({
    Key? key,
    required this.conversationState,
    required this.scenarioData,
    this.userProgress,
    this.onComplete,
  }) : super(key: key);

  @override
  State<DynamicDebriefPage> createState() => _DynamicDebriefPageState();
}

class _DynamicDebriefPageState extends State<DynamicDebriefPage>
    with TickerProviderStateMixin {
  late AnimationController _resultController;
  late Animation<double> _resultAnimation;
  late AnimationController _tacticsController;
  late Animation<double> _tacticsAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
    _awardXPAndBadges();
  }

  void _setupAnimations() {
    _resultController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _resultAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _resultController, curve: Curves.elasticOut),
    );

    _tacticsController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _tacticsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _tacticsController, curve: Curves.easeOut),
    );
  }

  void _startAnimations() {
    _resultController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _tacticsController.forward();
      }
    });
  }

  void _awardXPAndBadges() {
    if (widget.userProgress == null || widget.onComplete == null) return;

    final isSuccess = !widget.conversationState.userFellForScam;
    final resistanceLevel = widget.conversationState.resistanceLevel;
    final suspicionLevel = widget.conversationState.suspicionLevel;

    // Calculate XP based on performance
    int xpGained = 50; // Base XP
    if (isSuccess) {
      xpGained += 100; // Success bonus
      if (resistanceLevel > 0.8) xpGained += 50; // High resistance bonus
      if (suspicionLevel > 0.7) xpGained += 50; // High suspicion bonus
    } else {
      xpGained = 25; // Minimal XP for falling for scam
    }

    final updatedProgress = widget.userProgress!.updateStreak().copyWith(
      totalXP: widget.userProgress!.totalXP + xpGained,
    );

    updatedProgress.save();
    widget.onComplete!(updatedProgress);
  }

  @override
  void dispose() {
    _resultController.dispose();
    _tacticsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simulation Complete'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildResultCard(),
            const SizedBox(height: 20),
            _buildPerformanceMetrics(),
            const SizedBox(height: 20),
            _buildTacticsAnalysis(),
            const SizedBox(height: 20),
            _buildConversationFlow(),
            const SizedBox(height: 20),
            _buildEducationalInsights(),
            const SizedBox(height: 24),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final isSuccess = !widget.conversationState.userFellForScam;

    return AnimatedBuilder(
      animation: _resultAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _resultAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isSuccess
                    ? [const Color(0xFF00C851), const Color(0xFF007E33)]
                    : [const Color(0xFFFF4444), const Color(0xFFCC0000)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: (isSuccess ? Colors.green : Colors.red).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  isSuccess ? Icons.shield_outlined : Icons.warning_outlined,
                  size: 64,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                Text(
                  isSuccess ? 'Scam Avoided! 🛡️' : 'Scam Successful 😔',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  isSuccess
                      ? 'You successfully recognized the manipulation tactics and protected yourself!'
                      : 'The scammer achieved their goal. Let\'s learn what happened.',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPerformanceMetrics() {
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
            'Your Performance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildMetricRow(
            'Suspicion Level',
            widget.conversationState.suspicionLevel,
            Colors.orange,
            'How suspicious you became during the conversation',
          ),
          const SizedBox(height: 12),
          _buildMetricRow(
            'Resistance Level',
            widget.conversationState.resistanceLevel,
            Colors.green,
            'How well you resisted manipulation attempts',
          ),
          const SizedBox(height: 12),
          _buildMetricRow(
            'Manipulation Pressure',
            widget.conversationState.pressureLevel,
            Colors.red,
            'The intensity of manipulation tactics used against you',
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, double value, Color color, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            Text(
              '${(value * 100).round()}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: value,
          backgroundColor: Colors.grey.shade300,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildTacticsAnalysis() {
    return AnimatedBuilder(
      animation: _tacticsAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _tacticsAnimation.value,
          child: Container(
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
                  'Manipulation Tactics Identified',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                if (widget.conversationState.tacticsUsed.isEmpty)
                  const Text(
                    'No manipulation tactics were used in this conversation.',
                    style: TextStyle(color: Colors.grey),
                  )
                else
                  ...widget.conversationState.tacticsUsed.map((tactic) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.warning, color: Colors.orange, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                ScamTactics.getTacticName(tactic),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            ScamTactics.getTacticDescription(tactic),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildConversationFlow() {
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
            'Conversation Analysis',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Messages exchanged: ${widget.conversationState.messageHistory.length}',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            'Scam phase reached: ${_getPhaseDescription(widget.conversationState.currentPhase)}',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          const Text(
            'Key Decision Points:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          ...widget.conversationState.messageHistory
              .where((msg) => !msg.isFromScammer && msg.text.isNotEmpty)
              .take(3)
              .map((msg) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '"${msg.text}"',
                style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildEducationalInsights() {
    final redFlags = widget.scenarioData['redFlags'] as List<dynamic>? ?? [];

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
            'Key Learning Points',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.scenarioData['explanation'] ?? 'This scenario demonstrates common scam tactics.',
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Red Flags to Remember:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          ...redFlags.map((flag) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.flag, color: Colors.red, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      flag.toString(),
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

  Widget _buildNavigationButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
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
              'Continue Training',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              // Share results functionality
              _shareResults();
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Share Your Results',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  String _getPhaseDescription(ScamPhase phase) {
    switch (phase) {
      case ScamPhase.introduction:
        return 'Initial Contact';
      case ScamPhase.trustBuilding:
        return 'Trust Building';
      case ScamPhase.crisisIntro:
        return 'Crisis Introduction';
      case ScamPhase.moneyRequest:
        return 'Money Request';
      case ScamPhase.pressure:
        return 'High Pressure';
      case ScamPhase.conclusion:
        return 'Conclusion';
    }
  }

  void _shareResults() {
    final isSuccess = !widget.conversationState.userFellForScam;
    final message = isSuccess
        ? 'I just successfully avoided a scam simulation in ScamShield! 🛡️ Test your scam detection skills at scamshield-production.netlify.app'
        : 'I just completed a scam simulation in ScamShield and learned valuable lessons! 📚 Test your scam detection skills at scamshield-production.netlify.app';

    // TODO: Implement actual sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share functionality: $message'),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}