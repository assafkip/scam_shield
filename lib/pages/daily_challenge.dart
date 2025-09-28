import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/scenario.dart';
import '../models/user_progress.dart';
import '../state/app_state.dart';
import '../components/interactive_chat.dart';

class DailyChallenge extends StatefulWidget {
  final UserProgress userProgress;
  final Function(UserProgress) onComplete;

  const DailyChallenge({
    Key? key,
    required this.userProgress,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<DailyChallenge> createState() => _DailyChallengeState();
}

class _DailyChallengeState extends State<DailyChallenge> {
  Scenario? _dailyScenario;
  Duration _timeUntilReset = Duration.zero;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    print('🔥 Daily Challenge initState');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDailyChallenge();
    });
    _startTimer();
  }

  void _loadDailyChallenge() {
    try {
      print('🔥 Loading daily challenge...');
      final appState = Provider.of<AppState>(context, listen: false);
      final scenarios = appState.scenarios;

      if (scenarios.isEmpty) {
        print('🚨 ERROR: No scenarios available for daily challenge');
        return;
      }

      final now = DateTime.now();
      final seed = now.year * 10000 + now.month * 100 + now.day;
      final dailyIndex = seed % scenarios.length;

      print('🔥 Daily challenge: scenario ${dailyIndex} of ${scenarios.length}');
      print('🔥 Selected scenario: ${scenarios[dailyIndex].id}');

      setState(() {
        _dailyScenario = scenarios[dailyIndex];
        _isCompleted = _isDailyChallengeCompleted();
      });

      print('🔥 Daily challenge loaded successfully');
    } catch (e, stackTrace) {
      print('🚨 ERROR loading daily challenge: $e');
      print('🚨 Stack trace: $stackTrace');
    }
  }

  bool _isDailyChallengeCompleted() {
    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month}-${today.day}';
    return widget.userProgress.dailyChallenges.containsKey(todayKey) &&
           widget.userProgress.dailyChallenges[todayKey] == true;
  }

  void _startTimer() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    setState(() {
      _timeUntilReset = tomorrow.difference(now);
    });

    // Update timer every second
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _startTimer();
      }
    });
  }

  String _formatTimeRemaining() {
    final hours = _timeUntilReset.inHours;
    final minutes = _timeUntilReset.inMinutes % 60;
    final seconds = _timeUntilReset.inSeconds % 60;

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _startDailyChallenge() {
    if (_dailyScenario == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => InteractiveChat(
          scenario: _dailyScenario!,
          userProgress: widget.userProgress,
          onComplete: (updatedProgress) {
            // Mark daily challenge as completed
            final today = DateTime.now();
            final todayKey = '${today.year}-${today.month}-${today.day}';

            final newDailyChallenges = Map<String, bool>.from(updatedProgress.dailyChallenges);
            newDailyChallenges[todayKey] = true;

            final finalProgress = updatedProgress.copyWith(
              dailyChallenges: newDailyChallenges,
              totalXP: updatedProgress.totalXP + 100, // Bonus XP for daily
            );

            // Save the progress immediately
            finalProgress.save();

            widget.onComplete(finalProgress);
            setState(() {
              _isCompleted = true;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    try {
      print('🔥 Daily Challenge build method');

      if (_dailyScenario == null) {
        print('🔥 Scenario is null, showing loading');
        return Scaffold(
          appBar: AppBar(
            title: const Text('Daily Challenge'),
            backgroundColor: const Color(0xFFFF6B35),
            foregroundColor: Colors.white,
          ),
          body: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading daily challenge...'),
              ],
            ),
          ),
        );
      }

      print('🔥 Building daily challenge UI for scenario: ${_dailyScenario!.id}');
    } catch (e, stackTrace) {
      print('🚨 ERROR in Daily Challenge build: $e');
      print('🚨 Stack trace: $stackTrace');
      return Scaffold(
        appBar: AppBar(
          title: const Text('Daily Challenge Error'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Daily Challenge Error',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Error: ${e.toString()}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Challenge'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.calendar_today,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Daily Challenge',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _isCompleted ? 'Completed!' : 'Ready to play',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Next challenge in:',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          _formatTimeRemaining(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
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
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: _getPlatformColor(_dailyScenario!.platform).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getPlatformIcon(_dailyScenario!.platform),
                          color: _getPlatformColor(_dailyScenario!.platform),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Today\'s Challenge',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getSenderName(_dailyScenario!),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _dailyScenario!.platform.toUpperCase(),
                              style: TextStyle(
                                color: _getPlatformColor(_dailyScenario!.platform),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_isCompleted)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00C851),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'DONE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _getPreviewText(_dailyScenario!),
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.orange, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        'Double XP Reward',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      ...List.generate(_dailyScenario!.difficulty, (index) =>
                        const Icon(Icons.star, color: Color(0xFFFFD600), size: 16)
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isCompleted ? null : _startDailyChallenge,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isCompleted ? Colors.grey : const Color(0xFFFF6B35),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: _isCompleted ? 0 : 4,
              ),
              child: Text(
                _isCompleted ? 'Challenge Completed' : 'Start Daily Challenge',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSenderName(Scenario scenario) {
    switch (scenario.id) {
      case 'rom_001':
        return 'Sean Rad';
      case 'job_001':
        return 'HR Manager';
      case 'gov_001':
        return 'IRS ALERT';
      case 'tech_001':
        return 'Microsoft Security';
      case 'crypto_001':
        return 'Crypto Expert';
      case 'friend_001':
        return 'Sarah';
      case 'pkg_001':
        return 'FedEx';
      case 'bank_001':
        return 'Chase Security';
      case 'rental_001':
        return 'NYC Landlord';
      case 'charity_001':
        return 'Disaster Relief';
      default:
        return scenario.messages.isNotEmpty
            ? scenario.messages.first.from
            : 'Unknown';
    }
  }

  String _getPreviewText(Scenario scenario) {
    final firstMessage = scenario.messages.isNotEmpty
        ? scenario.messages.first.text
        : '';
    if (firstMessage.length > 100) {
      return '${firstMessage.substring(0, 97)}...';
    }
    return firstMessage;
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform) {
      case 'whatsapp':
        return Icons.chat;
      case 'email':
        return Icons.email;
      case 'sms':
        return Icons.sms;
      case 'tinder':
        return Icons.favorite;
      default:
        return Icons.message;
    }
  }

  Color _getPlatformColor(String platform) {
    switch (platform) {
      case 'whatsapp':
        return const Color(0xFF25D366);
      case 'email':
        return const Color(0xFF4285F4);
      case 'sms':
        return const Color(0xFF34B7F1);
      case 'tinder':
        return const Color(0xFFFF4458);
      default:
        return Colors.grey;
    }
  }
}