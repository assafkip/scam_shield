import 'package:flutter/material.dart';
import 'dart:math' as math;

class TutorialOverlayViral extends StatefulWidget {
  final VoidCallback onComplete;

  const TutorialOverlayViral({
    Key? key,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<TutorialOverlayViral> createState() => _TutorialOverlayViralState();
}

class _TutorialOverlayViralState extends State<TutorialOverlayViral>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _gestureController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _gestureAnimation;

  int _currentStep = 0;
  bool _isSkipped = false;

  final List<TutorialStepViral> _steps = [
    TutorialStepViral(
      title: "Real Scam Messages",
      description: "See actual messages scammers send to trick people just like you",
      icon: Icons.chat_bubble,
      gesture: TutorialGesture.chatBubble,
      duration: 4000,
    ),
    TutorialStepViral(
      title: "Choose Your Response",
      description: "Tap your reply - see how different choices affect the scammer",
      icon: Icons.touch_app,
      gesture: TutorialGesture.swipeChoices,
      duration: 4000,
    ),
    TutorialStepViral(
      title: "Rate Your Suspicion",
      description: "Trust your gut! Tap stars to show how suspicious you feel",
      icon: Icons.star,
      gesture: TutorialGesture.tapStars,
      duration: 4000,
    ),
    TutorialStepViral(
      title: "Level Up & Learn",
      description: "Earn XP, collect badges, and become a scam detection expert!",
      icon: Icons.emoji_events,
      gesture: TutorialGesture.celebration,
      duration: 4000,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _gestureController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _gestureAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _gestureController,
      curve: Curves.easeInOut,
    ));

    _startAnimation();
  }

  void _startAnimation() async {
    await _mainController.forward();
    _pulseController.repeat(reverse: true);
    _gestureController.repeat();

    // Auto-advance each step
    for (int i = 0; i < _steps.length; i++) {
      if (_isSkipped) break;

      await Future.delayed(Duration(milliseconds: _steps[i].duration));
      if (!_isSkipped && mounted) {
        _nextStep();
      }
    }
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
      });
      _mainController.reset();
      _mainController.forward();
    } else {
      _complete();
    }
  }

  void _skipTutorial() {
    setState(() {
      _isSkipped = true;
    });
    _complete();
  }

  void _complete() {
    _mainController.reverse().then((_) {
      widget.onComplete();
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _gestureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final step = _steps[_currentStep];

    return Material(
      color: Colors.black.withOpacity(0.9),
      child: SafeArea(
        child: Stack(
          children: [
            // Skip button - always visible and touchable
            Positioned(
              top: 20,
              right: 20,
              child: GestureDetector(
                onTap: _skipTutorial,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),

            // Main content
            Center(
              child: AnimatedBuilder(
                animation: _mainController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        margin: EdgeInsets.all(isMobile ? 24 : 48),
                        padding: EdgeInsets.all(isMobile ? 24 : 32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Gesture demonstration
                            _buildGestureArea(step, isMobile),

                            SizedBox(height: isMobile ? 32 : 40),

                            // Content
                            _buildContent(step, isMobile),

                            SizedBox(height: isMobile ? 24 : 32),

                            // Progress and navigation
                            _buildBottomSection(isMobile),
                          ],
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
    );
  }

  Widget _buildGestureArea(TutorialStepViral step, bool isMobile) {
    return Container(
      height: isMobile ? 120 : 160,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _gestureController,
        builder: (context, child) {
          return _buildGestureAnimation(step.gesture, isMobile);
        },
      ),
    );
  }

  Widget _buildGestureAnimation(TutorialGesture gesture, bool isMobile) {
    switch (gesture) {
      case TutorialGesture.chatBubble:
        return _buildChatBubbleAnimation(isMobile);
      case TutorialGesture.swipeChoices:
        return _buildSwipeChoicesAnimation(isMobile);
      case TutorialGesture.tapStars:
        return _buildTapStarsAnimation(isMobile);
      case TutorialGesture.celebration:
        return _buildCelebrationAnimation(isMobile);
    }
  }

  Widget _buildChatBubbleAnimation(bool isMobile) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Animated chat bubble
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                padding: EdgeInsets.all(isMobile ? 16 : 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF25D366), // WhatsApp green
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF25D366).withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Text(
                  "Hi! I'm the CEO of WhatsApp...",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 16 : 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          },
        ),

        // Pulsing outline
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.6),
                  width: 3,
                ),
              ),
              padding: EdgeInsets.all((_pulseAnimation.value - 1) * 20 + 20),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSwipeChoicesAnimation(bool isMobile) {
    return Stack(
      children: [
        // Choice buttons
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildChoiceButton("Wow, that's amazing!", isMobile, false),
            const SizedBox(height: 12),
            _buildChoiceButton("This seems suspicious...", isMobile, true),
          ],
        ),

        // Animated hand pointing
        AnimatedBuilder(
          animation: _gestureAnimation,
          builder: (context, child) {
            final offset = math.sin(_gestureAnimation.value * 2 * math.pi) * 10;
            return Positioned(
              right: 20 + offset,
              top: 20,
              child: Transform.rotate(
                angle: -0.3,
                child: const Icon(
                  Icons.touch_app,
                  color: Colors.blue,
                  size: 32,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildChoiceButton(String text, bool isMobile, bool isCorrect) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 12 : 10),
      decoration: BoxDecoration(
        color: isCorrect ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        border: Border.all(
          color: isCorrect ? Colors.green : Colors.red,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: isMobile ? 16 : 14,
          color: isCorrect ? Colors.green.shade700 : Colors.red.shade700,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTapStarsAnimation(bool isMobile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return AnimatedBuilder(
          animation: _gestureAnimation,
          builder: (context, child) {
            final delay = index * 0.2;
            final animationValue = math.max(0, (_gestureAnimation.value - delay) / (1 - delay));
            final filled = animationValue > 0.5;

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 4 : 2),
              child: Transform.scale(
                scale: filled ? 1.2 : 1.0,
                child: Icon(
                  filled ? Icons.star : Icons.star_border,
                  color: filled ? Colors.amber : Colors.grey,
                  size: isMobile ? 36 : 32,
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildCelebrationAnimation(bool isMobile) {
    return AnimatedBuilder(
      animation: _gestureAnimation,
      builder: (context, child) {
        final scale = 1.0 + math.sin(_gestureAnimation.value * 2 * math.pi) * 0.2;
        return Transform.scale(
          scale: scale,
          child: Container(
            padding: EdgeInsets.all(isMobile ? 24 : 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              Icons.emoji_events,
              size: isMobile ? 48 : 40,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(TutorialStepViral step, bool isMobile) {
    return Column(
      children: [
        Text(
          step.title,
          style: TextStyle(
            fontSize: isMobile ? 24 : 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isMobile ? 16 : 12),
        Text(
          step.description,
          style: TextStyle(
            fontSize: isMobile ? 18 : 16,
            color: Colors.black54,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBottomSection(bool isMobile) {
    return Column(
      children: [
        // Progress indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _steps.length,
            (index) => Container(
              width: isMobile ? 12 : 10,
              height: isMobile ? 12 : 10,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: index <= _currentStep
                    ? const Color(0xFF2196F3)
                    : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),

        SizedBox(height: isMobile ? 24 : 20),

        // Navigation buttons
        Row(
          children: [
            TextButton(
              onPressed: _skipTutorial,
              child: Text(
                'Skip Tutorial',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: isMobile ? 16 : 14,
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _currentStep < _steps.length - 1 ? _nextStep : _complete,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 32 : 24,
                  vertical: isMobile ? 16 : 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                _currentStep < _steps.length - 1 ? 'Next' : 'Start Learning!',
                style: TextStyle(
                  fontSize: isMobile ? 18 : 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class TutorialStepViral {
  final String title;
  final String description;
  final IconData icon;
  final TutorialGesture gesture;
  final int duration;

  TutorialStepViral({
    required this.title,
    required this.description,
    required this.icon,
    required this.gesture,
    required this.duration,
  });
}

enum TutorialGesture {
  chatBubble,
  swipeChoices,
  tapStars,
  celebration,
}