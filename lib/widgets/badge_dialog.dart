import 'package:flutter/material.dart';
import 'package:scamshield/models/scenario.dart';

class BadgeDialog extends StatefulWidget {
  final BadgeType badgeType;
  final int score;
  final int total;
  final VoidCallback onDismiss;

  const BadgeDialog({
    super.key,
    required this.badgeType,
    required this.score,
    required this.total,
    required this.onDismiss,
  });

  @override
  State<BadgeDialog> createState() => _BadgeDialogState();
}

class _BadgeDialogState extends State<BadgeDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Badge animation
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Transform.rotate(
                    angle: _rotationAnimation.value * 0.1,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getBadgeColor(),
                        boxShadow: [
                          BoxShadow(
                            color: _getBadgeColor().withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        _getBadgeIcon(),
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Title
            Text(
              _getBadgeTitle(),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: _getBadgeColor(),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Score
            Text(
              'Score: ${widget.score}/${widget.total}',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Message
            Text(
              _getBadgeMessage(),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Continue button
            FilledButton(
              onPressed: widget.onDismiss,
              style: FilledButton.styleFrom(
                backgroundColor: _getBadgeColor(),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBadgeColor() {
    switch (widget.badgeType) {
      case BadgeType.bronze:
        return const Color(0xFFCD7F32);
      case BadgeType.silver:
        return const Color(0xFFC0C0C0);
      case BadgeType.gold:
        return const Color(0xFFFFD700);
      case BadgeType.star:
        return const Color(0xFF9C27B0);
    }
  }

  IconData _getBadgeIcon() {
    switch (widget.badgeType) {
      case BadgeType.bronze:
        return Icons.emoji_events;
      case BadgeType.silver:
        return Icons.emoji_events;
      case BadgeType.gold:
        return Icons.emoji_events;
      case BadgeType.star:
        return Icons.star;
    }
  }

  String _getBadgeTitle() {
    switch (widget.badgeType) {
      case BadgeType.bronze:
        return 'Bronze Badge!';
      case BadgeType.silver:
        return 'Silver Badge!';
      case BadgeType.gold:
        return 'Gold Badge!';
      case BadgeType.star:
        return 'Perfect Score!';
    }
  }

  String _getBadgeMessage() {
    switch (widget.badgeType) {
      case BadgeType.bronze:
        return 'Good start! Keep practicing to improve your scam detection skills.';
      case BadgeType.silver:
        return 'Well done! You\'re getting better at spotting scams.';
      case BadgeType.gold:
        return 'Excellent work! You have strong scam detection skills.';
      case BadgeType.star:
        return 'Outstanding! You\'re a scam detection expert!';
    }
  }
}