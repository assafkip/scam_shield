import 'package:flutter/material.dart';

enum DetectiveChipState {
  neutral,
  happy,
  sad,
  concerned,
}

class DetectiveChip extends StatefulWidget {
  final DetectiveChipState state;
  final VoidCallback? onTap;

  const DetectiveChip({
    Key? key,
    required this.state,
    this.onTap,
  }) : super(key: key);

  @override
  State<DetectiveChip> createState() => _DetectiveChipState();
}

class _DetectiveChipState extends State<DetectiveChip>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _bounceController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.bounceOut,
    ));
  }

  @override
  void didUpdateWidget(DetectiveChip oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.state != widget.state) {
      _scaleController.forward().then((_) {
        _scaleController.reverse();
      });

      if (widget.state == DetectiveChipState.happy) {
        _bounceController.forward().then((_) {
          _bounceController.reverse();
        });
      }
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  String _getEmoji() {
    switch (widget.state) {
      case DetectiveChipState.neutral:
        return '🛡️';
      case DetectiveChipState.happy:
        return '😊🛡️';
      case DetectiveChipState.sad:
        return '😔🛡️';
      case DetectiveChipState.concerned:
        return '🤔🛡️';
    }
  }

  Color _getBackgroundColor() {
    switch (widget.state) {
      case DetectiveChipState.neutral:
        return const Color(0xFF2196F3).withOpacity(0.1);
      case DetectiveChipState.happy:
        return const Color(0xFF00C851).withOpacity(0.1);
      case DetectiveChipState.sad:
        return const Color(0xFFFF4444).withOpacity(0.1);
      case DetectiveChipState.concerned:
        return const Color(0xFFFFD600).withOpacity(0.1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _bounceAnimation]),
      builder: (context, child) {
        double scale = _scaleAnimation.value;
        if (widget.state == DetectiveChipState.happy) {
          scale *= _bounceAnimation.value;
        }

        return Transform.scale(
          scale: scale,
          child: GestureDetector(
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 80,
              width: double.infinity,
              decoration: BoxDecoration(
                color: _getBackgroundColor(),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getEmoji(),
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Detective Chip',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
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