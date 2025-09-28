import 'package:flutter/material.dart';
import '../models/user_progress.dart';

class XPBar extends StatefulWidget {
  final UserProgress userProgress;
  final bool showDetails;

  const XPBar({
    Key? key,
    required this.userProgress,
    this.showDetails = true,
  }) : super(key: key);

  @override
  State<XPBar> createState() => _XPBarState();
}

class _XPBarState extends State<XPBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.userProgress.levelProgress,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    // Start animation after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void didUpdateWidget(XPBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userProgress.totalXP != widget.userProgress.totalXP) {
      // Animate to new progress value
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: widget.userProgress.levelProgress,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ));
      _animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentLevel = widget.userProgress.currentLevel;
    final nextLevelXP = widget.userProgress.xpToNextLevel;
    final progressInLevel = widget.userProgress.totalXP - currentLevel.requiredXP;
    final levelRange = nextLevelXP - currentLevel.requiredXP;

    return Column(
      children: [
        if (widget.showDetails) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                currentLevel.title,
                style: TextStyle(
                  color: Color(currentLevel.colorValue),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                '$progressInLevel / $levelRange XP',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        Container(
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Colors.white.withOpacity(0.2),
          ),
          child: AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: _progressAnimation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        gradient: LinearGradient(
                          colors: [
                            Color(currentLevel.colorValue),
                            Color(currentLevel.colorValue).withOpacity(0.7),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(currentLevel.colorValue).withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        if (widget.showDetails) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Level ${currentLevel.index + 1}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              if (currentLevel.index + 1 < UserLevel.values.length)
                Text(
                  'Next: ${UserLevel.values[currentLevel.index + 1].title}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                )
              else
                const Text(
                  'Max Level!',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class XPGainPopup extends StatefulWidget {
  final int xpGained;
  final UserLevel? levelUp;
  final UserProgress? userProgress;

  const XPGainPopup({
    Key? key,
    required this.xpGained,
    this.levelUp,
    this.userProgress,
  }) : super(key: key);

  static void show(BuildContext context, int xpGained, {UserLevel? levelUp, UserProgress? userProgress}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => XPGainPopup(
        xpGained: xpGained,
        levelUp: levelUp,
        userProgress: userProgress,
      ),
    );

    // Auto-dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  State<XPGainPopup> createState() => _XPGainPopupState();
}

class _XPGainPopupState extends State<XPGainPopup>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_fadeController);

    _fadeController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              margin: const EdgeInsets.all(32),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
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
                  if (widget.levelUp != null) ...[
                    Icon(
                      Icons.emoji_events,
                      size: 60,
                      color: Color(widget.levelUp!.colorValue),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'LEVEL UP!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'You\'re now a ${widget.levelUp!.title}!',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(widget.levelUp!.colorValue),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ] else ...[
                    const Icon(
                      Icons.star,
                      size: 48,
                      color: Color(0xFFFFD600),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text(
                    '+${widget.xpGained} XP',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2196F3),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Great job detecting that scenario!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}