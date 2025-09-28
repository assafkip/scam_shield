import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../models/user_progress.dart';
import '../models/scenario.dart';
import '../components/interactive_chat.dart';
import '../components/dynamic_interactive_chat.dart';
import '../components/game_master_enhanced_chat.dart';
import '../components/tutorial_overlay.dart';
import '../components/xp_bar.dart';
import '../components/streak_indicator.dart';
import '../components/animated_page_route.dart';
import '../components/tutorial_overlay_viral.dart';
import '../components/viral_scenario_card.dart';
import '../utils/haptic_feedback.dart';
import '../utils/responsive_builder.dart';

class ScenarioPickerPage extends StatefulWidget {
  const ScenarioPickerPage({Key? key}) : super(key: key);

  @override
  State<ScenarioPickerPage> createState() => _ScenarioPickerPageState();
}

class _ScenarioPickerPageState extends State<ScenarioPickerPage>
    with TickerProviderStateMixin {
  UserProgress? _userProgress;
  bool _showTutorial = false;

  @override
  void initState() {
    super.initState();
    _loadUserProgress();
  }

  Future<void> _loadUserProgress() async {
    final progress = await UserProgress.load();
    setState(() {
      _userProgress = progress;
      _showTutorial = !progress.hasSeenTutorial;
    });

    // Initialize scenario progress for all scenarios
    final appState = Provider.of<AppState>(context, listen: false);
    final updatedProgress = Map<String, ScenarioProgress>.from(progress.scenarioProgress);

    for (final scenario in appState.scenarios) {
      if (!updatedProgress.containsKey(scenario.id)) {
        updatedProgress[scenario.id] = ScenarioProgress(scenarioId: scenario.id);
      }
    }

    if (updatedProgress.length != progress.scenarioProgress.length) {
      final newProgress = progress.copyWith(scenarioProgress: updatedProgress);
      setState(() {
        _userProgress = newProgress;
      });
      await newProgress.save();
    }
  }

  Future<void> _markTutorialSeen() async {
    if (_userProgress != null) {
      final newProgress = _userProgress!.copyWith(hasSeenTutorial: true);
      setState(() {
        _userProgress = newProgress;
        _showTutorial = false;
      });
      await newProgress.save();
    }
  }

  String _getScenarioPreviewText(Scenario scenario) {
    final firstMessage = scenario.messages.isNotEmpty
        ? scenario.messages.first.text
        : '';

    // Truncate to 40 characters for preview
    if (firstMessage.length > 40) {
      return '${firstMessage.substring(0, 37)}...';
    }
    return firstMessage;
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

  Widget _getScenarioIcon(Scenario scenario) {
    IconData iconData;
    Color iconColor = Colors.grey;

    switch (scenario.platform) {
      case 'whatsapp':
        iconData = Icons.chat;
        iconColor = const Color(0xFF25D366);
        break;
      case 'email':
        iconData = Icons.email;
        iconColor = const Color(0xFF4285F4);
        break;
      case 'sms':
        iconData = Icons.sms;
        iconColor = const Color(0xFF34B7F1);
        break;
      case 'tinder':
        iconData = Icons.favorite;
        iconColor = const Color(0xFFFF4458);
        break;
      default:
        iconData = Icons.message;
    }

    return CircleAvatar(
      radius: 25,
      backgroundColor: iconColor.withOpacity(0.1),
      child: Icon(
        iconData,
        color: iconColor,
        size: 24,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_userProgress == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width,
          maxHeight: MediaQuery.of(context).size.height,
        ),
        child: Stack(
          children: [
            _buildMainContent(),
            if (_showTutorial)
              TutorialOverlayViral(
                onComplete: _markTutorialSeen,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: _buildScenarioGrid(),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ScamShield',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '${_userProgress!.currentLevel.title} • Level ${_userProgress!.currentLevel.index + 1}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        if (_userProgress!.currentStreak > 0) ...[
                          const SizedBox(width: 8),
                          StreakIndicator(
                            userProgress: _userProgress!,
                            showDetails: false,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_userProgress!.totalXP} XP',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          XPBar(userProgress: _userProgress!),
        ],
      ),
    );
  }

  Widget _buildScenarioGrid() {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width > 600 ? 24 : 16,
              vertical: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose Your Next Challenge',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.width < 600 ? 20 : 24,
                  ),
                ),
                const SizedBox(height: 16),
                if (appState.dynamicScenarios.isNotEmpty) ...[
                  _buildSectionHeader('🔥 Realistic Scam Simulations', 'Experience real psychological manipulation'),
                  const SizedBox(height: 12),
                  ...appState.dynamicScenarios.map((dynamicScenario) {
                    return _buildDynamicScenarioCard(dynamicScenario);
                  }).toList(),
                  const SizedBox(height: 40),
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.construction,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'More realistic scam simulations coming soon!',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicScenarioCard(Map<String, dynamic> dynamicScenario) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.1),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showGameMasterOptions(dynamicScenario),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getPlatformIcon(dynamicScenario['platform'] ?? 'sms'),
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dynamicScenario['title'] ?? 'Untitled',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dynamicScenario['description'] ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'NEW',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.psychology, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    const Text(
                      'Advanced Manipulation Detection',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    ...List.generate(
                      dynamicScenario['difficulty'] ?? 1,
                      (index) => const Icon(Icons.star, color: Colors.white, size: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showGameMasterOptions(Map<String, dynamic> dynamicScenario) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              dynamicScenario['title'] ?? 'Dynamic Scenario',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              dynamicScenario['description'] ?? '',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Standard Mode
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _startDynamicScenario(dynamicScenario, false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.play_arrow),
                    const SizedBox(width: 8),
                    const Text(
                      'Standard Mode',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

            // Game Master Mode
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _startDynamicScenario(dynamicScenario, true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A1B9A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.psychology),
                    const SizedBox(width: 8),
                    const Column(
                      children: [
                        Text(
                          'Game Master Mode',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Real-time tactic analysis & pressure tracking',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _startDynamicScenario(Map<String, dynamic> dynamicScenario, bool useGameMaster) {
    try {
      HapticHelper.lightImpact();
      print('🎯 Starting dynamic scenario: ${dynamicScenario['id']} (Game Master: $useGameMaster)');

      Widget chatWidget;
      if (useGameMaster) {
        chatWidget = GameMasterEnhancedChat(
          scenarioData: dynamicScenario,
          userProgress: _userProgress!,
          onComplete: (updatedProgress) async {
            setState(() {
              _userProgress = updatedProgress;
            });
            await updatedProgress.save();
          },
        );
      } else {
        chatWidget = DynamicInteractiveChat(
          scenarioData: dynamicScenario,
          userProgress: _userProgress!,
          onComplete: (updatedProgress) async {
            setState(() {
              _userProgress = updatedProgress;
            });
            await updatedProgress.save();
          },
        );
      }

      Navigator.of(context).push(
        SlidePageRoute(child: chatWidget),
      );
    } catch (e, stackTrace) {
      print('🚨 ERROR starting dynamic scenario: $e');
      print('🚨 Stack trace: $stackTrace');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error starting scenario: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
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

  Widget _buildScenarioCard(Scenario scenario, ScenarioProgress progress) {
    final isNew = !progress.isCompleted;
    final isMastered = progress.isMastered;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        borderRadius: BorderRadius.circular(12),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _startScenario(scenario),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isNew
                    ? const Color(0xFF2196F3)
                    : Colors.grey.shade200,
                width: isNew ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Stack(
                  children: [
                    _getScenarioIcon(scenario),
                    if (isNew)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF4444),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _getSenderName(scenario),
                              style: TextStyle(
                                fontWeight: isNew ? FontWeight.bold : FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          if (isMastered)
                            const Icon(
                              Icons.check_circle,
                              color: Color(0xFF00C851),
                              size: 20,
                            ),
                          if (progress.isCompleted && !isMastered)
                            Icon(
                              Icons.check,
                              color: Colors.grey.shade600,
                              size: 20,
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getScenarioPreviewText(scenario),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildDifficultyStars(scenario.difficulty),
                          const Spacer(),
                          Text(
                            scenario.platform.toUpperCase(),
                            style: TextStyle(
                              color: const Color(0xFF2196F3),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isNew)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      color: Color(0xFF2196F3),
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyStars(int difficulty) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < difficulty ? Icons.star : Icons.star_border,
          color: const Color(0xFFFFD600),
          size: 16,
        );
      }),
    );
  }

  void _startScenario(Scenario scenario) {
    print('🎯 SCENARIO TAP: ${scenario.id}');
    print('🎯 Scenario data exists: ${scenario != null}');
    print('🎯 User progress exists: ${_userProgress != null}');
    print('🎯 Attempting navigation to InteractiveChat');

    HapticHelper.mediumImpact();

    try {
      Navigator.of(context).push(
        SlidePageRoute(
          child: InteractiveChat(
            scenario: scenario,
            userProgress: _userProgress!,
            onComplete: (updatedProgress) async {
              setState(() {
                _userProgress = updatedProgress;
              });
              await updatedProgress.save();
            },
          ),
        ),
      );
      print('🎯 Navigation initiated successfully');
    } catch (e, stackTrace) {
      print('🚨 Navigation error: $e');
      print('🚨 Stack trace: $stackTrace');
    }
  }

}