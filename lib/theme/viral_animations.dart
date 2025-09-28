import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class ViralAnimations {
  // Star tap animation with spring physics
  static void starTap(TickerProvider vsync, VoidCallback onPeak) {
    final controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: vsync,
    );

    final scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.8),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.8, end: 1.3)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 1.0)
            .chain(CurveTween(curve: Curves.bounceOut)),
        weight: 40,
      ),
    ]).animate(controller);

    // Haptic feedback at peak
    controller.addListener(() {
      if (controller.value >= 0.6 && controller.value <= 0.65) {
        HapticFeedback.lightImpact();
        onPeak();
      }
    });

    controller.forward();
  }

  // XP burst animation
  static void showXPGain(BuildContext context, int xp, Offset startPosition) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => AnimatedXPBurst(
        xp: xp,
        startPosition: startPosition,
        onComplete: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }

  // Level up celebration
  static void showLevelUp(BuildContext context, String newLevel) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => LevelUpCelebration(
        newLevel: newLevel,
        onComplete: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }

  // Confetti animation
  static void showConfetti(BuildContext context, {int particleCount = 100}) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => ConfettiAnimation(
        particleCount: particleCount,
        onComplete: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }
}

class AnimatedXPBurst extends StatefulWidget {
  final int xp;
  final Offset startPosition;
  final VoidCallback onComplete;

  const AnimatedXPBurst({
    Key? key,
    required this.xp,
    required this.startPosition,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<AnimatedXPBurst> createState() => _AnimatedXPBurstState();
}

class _AnimatedXPBurstState extends State<AnimatedXPBurst>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _positionAnimation = Tween<Offset>(
      begin: widget.startPosition,
      end: Offset(widget.startPosition.dx, widget.startPosition.dy - 100),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuart,
    ));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.5,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
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
          left: _positionAnimation.value.dx - 40,
          top: _positionAnimation.value.dy - 20,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF00C851),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00C851).withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '+${widget.xp} XP',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class LevelUpCelebration extends StatefulWidget {
  final String newLevel;
  final VoidCallback onComplete;

  const LevelUpCelebration({
    Key? key,
    required this.newLevel,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<LevelUpCelebration> createState() => _LevelUpCelebrationState();
}

class _LevelUpCelebrationState extends State<LevelUpCelebration>
    with TickerProviderStateMixin {
  late AnimationController _flashController;
  late AnimationController _badgeController;
  late AnimationController _textController;

  late Animation<double> _flashAnimation;
  late Animation<double> _badgeScaleAnimation;
  late Animation<double> _textOpacityAnimation;

  @override
  void initState() {
    super.initState();

    _flashController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _badgeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _flashAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_flashController);

    _badgeScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 2.0),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 2.0, end: 1.0)
            .chain(CurveTween(curve: Curves.bounceOut)),
        weight: 50,
      ),
    ]).animate(_badgeController);

    _textOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    ));

    _startAnimation();
  }

  void _startAnimation() async {
    // Flash effect
    await _flashController.forward();
    await _flashController.reverse();

    // Badge animation with confetti
    _badgeController.forward();
    ViralAnimations.showConfetti(context, particleCount: 200);

    // Text animation
    await Future.delayed(const Duration(milliseconds: 300));
    _textController.forward();

    // Auto dismiss
    await Future.delayed(const Duration(milliseconds: 2000));
    widget.onComplete();
  }

  @override
  void dispose() {
    _flashController.dispose();
    _badgeController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            // Flash overlay
            AnimatedBuilder(
              animation: _flashAnimation,
              builder: (context, child) {
                return Container(
                  color: Colors.white.withOpacity(_flashAnimation.value * 0.8),
                );
              },
            ),

            // Level up content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Badge
                  AnimatedBuilder(
                    animation: _badgeScaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _badgeScaleAnimation.value,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.amber.withOpacity(0.5),
                                blurRadius: 20,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.emoji_events,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Text
                  AnimatedBuilder(
                    animation: _textOpacityAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _textOpacityAnimation.value,
                        child: Column(
                          children: [
                            const Text(
                              'LEVEL UP!',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFFD700),
                                shadows: [
                                  Shadow(
                                    color: Colors.black26,
                                    offset: Offset(2, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'You\'re now a ${widget.newLevel}!',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ConfettiAnimation extends StatefulWidget {
  final int particleCount;
  final VoidCallback onComplete;

  const ConfettiAnimation({
    Key? key,
    required this.particleCount,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<ConfettiAnimation> createState() => _ConfettiAnimationState();
}

class _ConfettiAnimationState extends State<ConfettiAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<ConfettiParticle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _generateParticles();
    _controller.forward().then((_) => widget.onComplete());
  }

  void _generateParticles() {
    final random = math.Random();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    _particles = List.generate(widget.particleCount, (index) {
      return ConfettiParticle(
        startX: random.nextDouble() * screenWidth,
        startY: -20,
        endY: screenHeight + 20,
        color: _getRandomColor(random),
        size: random.nextDouble() * 8 + 4,
        rotation: random.nextDouble() * 2 * math.pi,
        drift: (random.nextDouble() - 0.5) * 100,
      );
    });
  }

  Color _getRandomColor(math.Random random) {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.pink,
    ];
    return colors[random.nextInt(colors.length)];
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
        return CustomPaint(
          painter: ConfettiPainter(_particles, _controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class ConfettiParticle {
  final double startX;
  final double startY;
  final double endY;
  final Color color;
  final double size;
  final double rotation;
  final double drift;

  ConfettiParticle({
    required this.startX,
    required this.startY,
    required this.endY,
    required this.color,
    required this.size,
    required this.rotation,
    required this.drift,
  });
}

class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double progress;

  ConfettiPainter(this.particles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(1.0 - progress)
        ..style = PaintingStyle.fill;

      final y = particle.startY + (particle.endY - particle.startY) * progress;
      final x = particle.startX + particle.drift * progress;
      final currentRotation = particle.rotation * progress * 4;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(currentRotation);

      // Draw confetti piece as rotated rectangle
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: particle.size,
            height: particle.size * 0.6,
          ),
          const Radius.circular(2),
        ),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}