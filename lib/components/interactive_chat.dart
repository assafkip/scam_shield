import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/conversation.dart';
import '../models/scenario.dart';
import '../models/user_progress.dart';
import '../state/app_state.dart';
import '../pages/trust_page.dart';
import '../components/xp_bar.dart';
import '../components/platform_authentic_chat.dart';
import '../utils/haptic_feedback.dart';

class InteractiveChat extends StatefulWidget {
  final Scenario scenario;
  final UserProgress? userProgress;
  final Function(UserProgress)? onComplete;

  const InteractiveChat({
    Key? key,
    required this.scenario,
    this.userProgress,
    this.onComplete,
  }) : super(key: key);

  @override
  State<InteractiveChat> createState() => _InteractiveChatState();
}

class _InteractiveChatState extends State<InteractiveChat>
    with TickerProviderStateMixin {
  late ConversationState _conversationState;
  late ScrollController _scrollController;
  late AnimationController _feedbackController;
  late Animation<double> _feedbackAnimation;

  String? _feedbackMessage;
  Color? _feedbackColor;

  @override
  void initState() {
    super.initState();
    print('💬 InteractiveChat initState');
    print('💬 Scenario received: ${widget.scenario?.id}');
    print('💬 User progress received: ${widget.userProgress != null}');

    if (widget.scenario == null) {
      print('🚨 ERROR: Scenario is null!');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
      });
      return;
    }

    _scrollController = ScrollController();
    _feedbackController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _feedbackAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _feedbackController, curve: Curves.easeInOut),
    );

    _initializeConversation();
    print('💬 InteractiveChat initialization complete');
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  void _initializeConversation() {
    // Start with the first scammer message
    final firstMessage = ConversationMessage(
      id: 'msg_1',
      from: _getScammerName(),
      text: _getOpeningMessage(),
      choices: _getOpeningChoices(),
      isFromScammer: true,
    );

    _conversationState = ConversationState(
      messages: [firstMessage],
      currentMessageId: 'msg_1',
    );
  }

  String _getScammerName() {
    switch (widget.scenario.id) {
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
      default:
        return widget.scenario.messages.isNotEmpty
            ? widget.scenario.messages.first.from
            : 'Unknown';
    }
  }

  String _getOpeningMessage() {
    switch (widget.scenario.id) {
      case 'rom_001':
        return "Hi! I'm Sean, CEO of Tinder. I noticed your profile and was impressed!";
      case 'job_001':
        return "Congratulations! You are hired for remote position \$5000/week. Send SSN and bank details to start immediately.";
      case 'gov_001':
        return "FINAL NOTICE: You owe \$2,847 in back taxes. Pay within 24 hours or face arrest warrant.";
      case 'tech_001':
        return "CRITICAL ALERT: Your computer is infected with 247 viruses! Call 1-800-VIRUS now for immediate removal!";
      case 'crypto_001':
        return "🚀 EXCLUSIVE OFFER: Turn \$500 into \$50,000 in 30 days! Bitcoin mining pool guaranteed 10,000% returns!";
      case 'friend_001':
        return "Hey! I'm in trouble and need help urgently. Can you send me \$500? My phone is about to die.";
      default:
        return widget.scenario.messages.isNotEmpty
            ? widget.scenario.messages.first.text
            : "Hello there!";
    }
  }

  List<ConversationChoice> _getOpeningChoices() {
    switch (widget.scenario.id) {
      case 'rom_001':
        return [
          ConversationChoice(
            id: 'rom_1_excited',
            buttonText: "Wow, really? Tell me more!",
            isSafe: false,
            nextScammerResponse: "I feel a real connection. Would love to meet but I'm traveling for business. Can you help with a small loan?",
          ),
          ConversationChoice(
            id: 'rom_1_suspicious',
            buttonText: "This seems suspicious...",
            isSafe: true,
            nextScammerResponse: "I understand your caution. Let me prove I'm real - I can send you insider Tinder stock info if you help me out.",
          ),
          ConversationChoice(
            id: 'rom_1_verify',
            buttonText: "Can you verify your identity?",
            isSafe: true,
            nextScammerResponse: "Of course! But first, I need a small favor. Emergency came up and need \$200 for travel. I'll pay back double!",
          ),
        ];
      case 'job_001':
        return [
          ConversationChoice(
            id: 'job_1_excited',
            buttonText: "Amazing! When do I start?",
            isSafe: false,
            nextScammerResponse: "Start Monday! Just need your SSN, bank routing number, and \$50 setup fee for equipment.",
          ),
          ConversationChoice(
            id: 'job_1_suspicious',
            buttonText: "I never applied for this...",
            isSafe: true,
            nextScammerResponse: "No problem! We selected you from resume database. Very urgent need start Monday! Just send details quick.",
          ),
          ConversationChoice(
            id: 'job_1_verify',
            buttonText: "Can I see the job posting?",
            isSafe: true,
            nextScammerResponse: "Job posting expired, very exclusive position. Need to act fast or position goes to someone else!",
          ),
        ];
      case 'gov_001':
        return [
          ConversationChoice(
            id: 'gov_1_panic',
            buttonText: "Oh no! How do I pay?",
            isSafe: false,
            nextScammerResponse: "Buy iTunes gift cards worth \$2,847 and call 555-0199 immediately to avoid jail time.",
          ),
          ConversationChoice(
            id: 'gov_1_suspicious',
            buttonText: "This doesn't seem right",
            isSafe: true,
            nextScammerResponse: "This is your LAST WARNING. Officers are being dispatched to your address. Pay now or face arrest!",
          ),
          ConversationChoice(
            id: 'gov_1_verify',
            buttonText: "I'll call the IRS directly",
            isSafe: true,
            nextScammerResponse: "NO TIME! Their lines are down. Use only this number: 555-0199 or go to jail tonight!",
          ),
        ];
      case 'crypto_001':
        return [
          ConversationChoice(
            id: 'crypto_1_interested',
            buttonText: "Tell me more about this opportunity!",
            isSafe: false,
            nextScammerResponse: "Only 5 spots left! Send \$500 Bitcoin deposit now to secure your position. My last student made \$100K!",
          ),
          ConversationChoice(
            id: 'crypto_1_suspicious',
            buttonText: "That sounds too good to be true",
            isSafe: true,
            nextScammerResponse: "I know it sounds crazy but crypto is the future! Look at this screenshot of my profits. Just need small deposit to start.",
          ),
          ConversationChoice(
            id: 'crypto_1_proof',
            buttonText: "Can you provide proof of returns?",
            isSafe: true,
            nextScammerResponse: "No time for paperwork! Offer expires in 1 hour. Send deposit or miss out forever! Others are sending money now.",
          ),
        ];
      default:
        return [
          ConversationChoice(
            id: 'default_1',
            buttonText: "Okay, tell me more",
            isSafe: false,
            nextScammerResponse: "Great! I just need you to help me with something small...",
          ),
          ConversationChoice(
            id: 'default_2',
            buttonText: "This seems suspicious",
            isSafe: true,
            nextScammerResponse: "I understand your concern, but this is legitimate. Let me explain...",
          ),
        ];
    }
  }

  void _makeChoice(ConversationChoice choice) {
    setState(() {
      // Add user's choice message
      final userMessage = ConversationMessage(
        id: 'user_${_conversationState.userChoices.length + 1}',
        from: 'You',
        text: choice.buttonText,
        isFromScammer: false,
      );

      // Add scammer's response
      final scammerResponse = ConversationMessage(
        id: 'scammer_${_conversationState.userChoices.length + 1}',
        from: _getScammerName(),
        text: choice.nextScammerResponse ?? "I see...",
        choices: _getFollowUpChoices(_conversationState.userChoices.length + 1),
        isFromScammer: true,
      );

      _conversationState = _conversationState.copyWith(
        messages: [..._conversationState.messages, userMessage, scammerResponse],
        userChoices: [..._conversationState.userChoices, choice],
        isComplete: _conversationState.userChoices.length >= 2, // End after 3 exchanges
      );
    });

    // Show feedback
    _showChoiceFeedback(choice);

    // Auto-scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // Navigate to trust evaluation if conversation is complete
    if (_conversationState.isComplete) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => TrustPage(
                conversationState: _conversationState,
                userProgress: widget.userProgress,
                onComplete: widget.onComplete,
              ),
            ),
          );
        }
      });
    }
  }

  List<ConversationChoice> _getFollowUpChoices(int round) {
    if (round >= 3) return []; // End conversation

    // Generic follow-up choices that work for most scenarios
    return [
      ConversationChoice(
        id: 'followup_${round}_1',
        buttonText: "Okay, what do you need from me?",
        isSafe: false,
        nextScammerResponse: "Perfect! This is exactly what I was hoping to hear. Let's make this happen quickly!",
      ),
      ConversationChoice(
        id: 'followup_${round}_2',
        buttonText: "I need to think about this more",
        isSafe: true,
        nextScammerResponse: "Time is running out! This opportunity won't wait. You need to decide now or lose out forever!",
      ),
      ConversationChoice(
        id: 'followup_${round}_3',
        buttonText: "Can we talk on the phone first?",
        isSafe: true,
        nextScammerResponse: "I'm in meetings all day. Text is faster. Just need a quick favor and we can talk later.",
      ),
    ];
  }

  void _showChoiceFeedback(ConversationChoice choice) {
    setState(() {
      _feedbackMessage = choice.isSafe ? "Good instinct! ✓" : "Careful... ⚠";
      _feedbackColor = choice.isSafe ? const Color(0xFF00C851) : const Color(0xFFFFD600);
    });

    _feedbackController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _feedbackController.reverse();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) {
          try {
            print('=== BUILD METHOD START ===');
            print('Scenario: ${widget.scenario}');
            print('Scenario ID: ${widget.scenario?.id}');
            print('ConversationState: ${_conversationState}');
            print('Messages count: ${_conversationState.messages.length}');

            // Check if scenario exists
            if (widget.scenario == null) {
              print('🚨 CRITICAL ERROR: Scenario is null in build method');
              return _buildErrorScreen('No scenario loaded', 'Please try selecting a scenario again.');
            }

            print('✅ Scenario exists, building PlatformAuthenticChat');

            return PlatformAuthenticChat(
              scenario: widget.scenario,
              messages: _conversationState.messages,
              choices: !_conversationState.isComplete &&
                      _conversationState.messages.isNotEmpty &&
                      _conversationState.messages.last.choices.isNotEmpty
                  ? _conversationState.messages.last.choices
                  : [],
              onChoiceSelected: _makeChoice,
            );

          } catch (e, stackTrace) {
            print('🚨 ERROR in InteractiveChat build: $e');
            print('🚨 Stack trace: $stackTrace');

            return _buildErrorScreen(
              'Something went wrong',
              'Error: ${e.toString()}',
            );
          }
        },
      ),
    );
  }

  Widget _buildErrorScreen(String title, String message) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
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

}