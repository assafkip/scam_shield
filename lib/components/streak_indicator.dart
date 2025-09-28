import 'package:flutter/material.dart';
import '../models/user_progress.dart';

class StreakIndicator extends StatelessWidget {
  final UserProgress userProgress;
  final bool showDetails;

  const StreakIndicator({
    Key? key,
    required this.userProgress,
    this.showDetails = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (userProgress.currentStreak == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.shade400,
            Colors.orange.shade600,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department,
            color: Colors.white,
            size: showDetails ? 20 : 16,
          ),
          const SizedBox(width: 4),
          Text(
            '${userProgress.currentStreak}',
            style: TextStyle(
              color: Colors.white,
              fontSize: showDetails ? 16 : 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (showDetails) ...[
            const SizedBox(width: 4),
            Text(
              userProgress.currentStreak == 1 ? 'day' : 'days',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class StreakMilestonePopup extends StatefulWidget {
  final int streakDays;
  final UserProgress userProgress;

  const StreakMilestonePopup({
    Key? key,
    required this.streakDays,
    required this.userProgress,
  }) : super(key: key);

  static void show(BuildContext context, int streakDays, UserProgress userProgress) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StreakMilestonePopup(
        streakDays: streakDays,
        userProgress: userProgress,
      ),
    );

    // Auto-dismiss after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  State<StreakMilestonePopup> createState() => _StreakMilestonePopupState();
}

class _StreakMilestonePopupState extends State<StreakMilestonePopup>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fireController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fireAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fireController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _fireAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fireController,
      curve: Curves.easeInOut,
    ));

    _scaleController.forward();
    _fireController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fireController.dispose();
    super.dispose();
  }

  String _getMilestoneMessage() {
    switch (widget.streakDays) {
      case 3:
        return 'Building Momentum!';
      case 7:
        return 'Week Warrior!';
      case 30:
        return 'Monthly Master!';
      default:
        return 'Streak Milestone!';
    }
  }

  String _getMilestoneDescription() {
    switch (widget.streakDays) {
      case 3:
        return 'You\'re getting into the groove! Keep up the great work.';
      case 7:
        return 'A full week of learning! You\'re becoming a scam detection expert.';
      case 30:
        return 'Incredible dedication! You\'re now a true cyber security champion.';
      default:
        return 'Your consistency is paying off! Keep the streak alive.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.orange.shade400,
                  Colors.orange.shade600,
                  Colors.deepOrange.shade700,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated fire icon
                AnimatedBuilder(
                  animation: _fireAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_fireAnimation.value * 0.2),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.local_fire_department,
                          size: 80,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Milestone text
                Text(
                  _getMilestoneMessage(),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                // Streak count
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${widget.streakDays}',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.streakDays == 1 ? 'DAY' : 'DAYS',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Description
                Text(
                  _getMilestoneDescription(),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                // Best streak indicator
                if (widget.userProgress.bestStreak > widget.streakDays)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Personal Best: ${widget.userProgress.bestStreak} days',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '🎉 NEW PERSONAL BEST! 🎉',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Next milestone
                if (widget.streakDays < 30)
                  Text(
                    'Next milestone: ${_getNextMilestone()} days',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _getNextMilestone() {
    if (widget.streakDays < 3) return 3;
    if (widget.streakDays < 7) return 7;
    if (widget.streakDays < 30) return 30;
    return 30; // Max milestone
  }
}