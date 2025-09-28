import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/viral_animations.dart';
import '../utils/haptic_feedback.dart';

enum CelebrationType {
  correctAnswer,
  incorrectAnswer,
  levelUp,
  streak,
  perfectScore,
  firstTime,
}

class CelebrationService {
  static void show(CelebrationType type, BuildContext context, {
    int? xp,
    String? levelName,
    int? streakDays,
    Offset? position,
  }) {
    switch (type) {
      case CelebrationType.correctAnswer:
        _showCorrectAnswer(context, xp ?? 100, position);
        break;
      case CelebrationType.incorrectAnswer:
        _showIncorrectAnswer(context, position);
        break;
      case CelebrationType.levelUp:
        _showLevelUp(context, levelName ?? 'Detective');
        break;
      case CelebrationType.streak:
        _showStreak(context, streakDays ?? 1);
        break;
      case CelebrationType.perfectScore:
        _showPerfectScore(context, position);
        break;
      case CelebrationType.firstTime:
        _showFirstTime(context);
        break;
    }
  }

  static void _showCorrectAnswer(BuildContext context, int xp, Offset? position) {
    // Haptic feedback
    HapticHelper.mediumImpact();

    // Show checkmark animation
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => CorrectAnswerAnimation(
        xp: xp,
        position: position ?? const Offset(200, 300),
        onComplete: () => entry.remove(),
      ),
    );

    overlay.insert(entry);

    // Show XP burst
    if (position != null) {
      ViralAnimations.showXPGain(context, xp, position);
    }

    // Subtle confetti
    Future.delayed(const Duration(milliseconds: 200), () {
      ViralAnimations.showConfetti(context, particleCount: 30);
    });
  }

  static void _showIncorrectAnswer(BuildContext context, Offset? position) {
    // Gentle haptic feedback
    HapticHelper.lightImpact();

    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => IncorrectAnswerAnimation(
        position: position ?? const Offset(200, 300),
        onComplete: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }

  static void _showLevelUp(BuildContext context, String levelName) {
    // Strong haptic feedback
    HapticHelper.heavyImpact();

    // Full screen celebration
    ViralAnimations.showLevelUp(context, levelName);

    // Major confetti
    Future.delayed(const Duration(milliseconds: 500), () {
      ViralAnimations.showConfetti(context, particleCount: 200);
    });
  }

  static void _showStreak(BuildContext context, int streakDays) {
    // Medium haptic feedback
    HapticHelper.mediumImpact();

    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => StreakAnimation(
        streakDays: streakDays,
        onComplete: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }

  static void _showPerfectScore(BuildContext context, Offset? position) {
    // Strong haptic feedback
    HapticHelper.heavyImpact();

    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => PerfectScoreAnimation(
        position: position ?? const Offset(200, 300),
        onComplete: () => entry.remove(),
      ),
    );

    overlay.insert(entry);

    // Golden confetti
    Future.delayed(const Duration(milliseconds: 300), () {
      ViralAnimations.showConfetti(context, particleCount: 100);
    });
  }

  static void _showFirstTime(BuildContext context) {
    // Welcome celebration
    HapticHelper.mediumImpact();

    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => FirstTimeAnimation(
        onComplete: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }
}

class CorrectAnswerAnimation extends StatefulWidget {
  final int xp;
  final Offset position;
  final VoidCallback onComplete;

  const CorrectAnswerAnimation({
    Key? key,
    required this.xp,
    required this.position,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<CorrectAnswerAnimation> createState() => _CorrectAnswerAnimationState();
}

class _CorrectAnswerAnimationState extends State<CorrectAnswerAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.3),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 1.0),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.8),
        weight: 30,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0),
        weight: 20,
      ),
    ]).animate(_controller);

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: widget.position.dx - 40,
          top: widget.position.dy - 40,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFF00C851),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class IncorrectAnswerAnimation extends StatefulWidget {
  final Offset position;
  final VoidCallback onComplete;

  const IncorrectAnswerAnimation({
    Key? key,
    required this.position,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<IncorrectAnswerAnimation> createState() => _IncorrectAnswerAnimationState();
}

class _IncorrectAnswerAnimationState extends State<IncorrectAnswerAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shakeAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticInOut,
    ));

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0),
        weight: 20,
      ),
    ]).animate(_controller);

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final shake = (_shakeAnimation.value * 10).round() % 2 == 0 ? -5.0 : 5.0;

        return Positioned(
          left: widget.position.dx - 40 + shake,
          top: widget.position.dy - 40,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B35),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: const Icon(
                Icons.lightbulb_outline,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        );
      },
    );
  }
}

class StreakAnimation extends StatefulWidget {
  final int streakDays;
  final VoidCallback onComplete;

  const StreakAnimation({
    Key? key,
    required this.streakDays,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<StreakAnimation> createState() => _StreakAnimationState();
}

class _StreakAnimationState extends State<StreakAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fireAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _fireAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Center(
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.orange.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.rotate(
                    angle: _fireAnimation.value * 0.2,
                    child: const Icon(
                      Icons.local_fire_department,
                      color: Colors.orange,
                      size: 60,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.streakDays} DAY${widget.streakDays == 1 ? '' : 'S'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          offset: Offset(1, 1),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class PerfectScoreAnimation extends StatefulWidget {
  final Offset position;
  final VoidCallback onComplete;

  const PerfectScoreAnimation({
    Key? key,
    required this.position,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<PerfectScoreAnimation> createState() => _PerfectScoreAnimationState();
}

class _PerfectScoreAnimationState extends State<PerfectScoreAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.5),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.5, end: 1.0),
        weight: 60,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: widget.position.dx - 50,
          top: widget.position.dy - 50,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: const RadialGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.6),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.star,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class FirstTimeAnimation extends StatefulWidget {
  final VoidCallback onComplete;

  const FirstTimeAnimation({
    Key? key,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<FirstTimeAnimation> createState() => _FirstTimeAnimationState();
}

class _FirstTimeAnimationState extends State<FirstTimeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _controller,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                  CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
                ),
                child: Container(
                  margin: const EdgeInsets.all(40),
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
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
                      const Icon(
                        Icons.celebration,
                        size: 60,
                        color: Color(0xFF2196F3),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Welcome to ScamShield!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'You\'re about to become a scam detection expert!',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}