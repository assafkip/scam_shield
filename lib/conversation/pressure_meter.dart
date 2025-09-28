/// Pressure meter UI component for PRD-02
/// Shows real-time pressure level with animations and accessibility

import 'package:flutter/material.dart';

class PressureMeter extends StatefulWidget {
  final double pressureLevel; // 0.0 to 100.0
  final bool animate;
  final double height;
  final String? label;

  const PressureMeter({
    super.key,
    required this.pressureLevel,
    this.animate = true,
    this.height = 24.0,
    this.label,
  });

  @override
  State<PressureMeter> createState() => _PressureMeterState();
}

class _PressureMeterState extends State<PressureMeter>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  double _previousLevel = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _previousLevel = widget.pressureLevel;
    _animation = Tween<double>(
      begin: _previousLevel,
      end: widget.pressureLevel,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(PressureMeter oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.pressureLevel != widget.pressureLevel && widget.animate) {
      _previousLevel = oldWidget.pressureLevel;
      _animation = Tween<double>(
        begin: _previousLevel,
        end: widget.pressureLevel,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));

      _animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getPressureColor(double level) {
    if (level <= 20) {
      return Colors.green;
    } else if (level <= 50) {
      return Colors.yellow[700]!;
    } else if (level <= 80) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  String _getPressureDescription(double level) {
    if (level <= 20) {
      return 'Low pressure';
    } else if (level <= 50) {
      return 'Moderate pressure';
    } else if (level <= 80) {
      return 'High pressure';
    } else {
      return 'Extreme pressure';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.label ?? 'Pressure meter',
      value: '${widget.pressureLevel.toStringAsFixed(0)} percent. ${_getPressureDescription(widget.pressureLevel)}',
      child: Container(
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.height / 2),
          border: Border.all(
            color: Colors.grey[400]!,
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.height / 2),
          child: Stack(
            children: [
              // Background
              Container(
                width: double.infinity,
                height: widget.height,
                color: Colors.grey[100],
              ),

              // Pressure fill with animation
              widget.animate
                  ? AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return _buildPressureFill(_animation.value);
                      },
                    )
                  : _buildPressureFill(widget.pressureLevel),

              // Pressure level text overlay
              if (widget.height >= 24)
                Center(
                  child: Text(
                    '${widget.pressureLevel.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: (widget.height * 0.5).clamp(10, 14),
                      fontWeight: FontWeight.bold,
                      color: widget.pressureLevel > 50 ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPressureFill(double level) {
    return FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: (level / 100.0).clamp(0.0, 1.0),
      child: Container(
        height: widget.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _getPressureColor(level).withOpacity(0.8),
              _getPressureColor(level),
            ],
            stops: const [0.0, 1.0],
          ),
        ),
      ),
    );
  }
}

/// Compact pressure meter for app bar usage
class CompactPressureMeter extends StatelessWidget {
  final double pressureLevel;
  final bool showLabel;

  const CompactPressureMeter({
    super.key,
    required this.pressureLevel,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel)
          Text(
            'Pressure: ',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        SizedBox(
          width: 60,
          child: PressureMeter(
            pressureLevel: pressureLevel,
            height: 16,
            label: 'Current pressure level',
          ),
        ),
      ],
    );
  }
}

/// Thermometer-style pressure meter alternative
class ThermometerPressureMeter extends StatefulWidget {
  final double pressureLevel;
  final double height;
  final double width;

  const ThermometerPressureMeter({
    super.key,
    required this.pressureLevel,
    this.height = 120.0,
    this.width = 30.0,
  });

  @override
  State<ThermometerPressureMeter> createState() => _ThermometerPressureMeterState();
}

class _ThermometerPressureMeterState extends State<ThermometerPressureMeter>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fillAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fillAnimation = Tween<double>(
      begin: 0.0,
      end: widget.pressureLevel,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void didUpdateWidget(ThermometerPressureMeter oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.pressureLevel != widget.pressureLevel) {
      _fillAnimation = Tween<double>(
        begin: oldWidget.pressureLevel,
        end: widget.pressureLevel,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
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
    return Semantics(
      label: 'Pressure thermometer',
      value: '${widget.pressureLevel.toStringAsFixed(0)} percent pressure',
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: CustomPaint(
          painter: _ThermometerPainter(
            pressureLevel: widget.pressureLevel,
            animation: _fillAnimation,
          ),
        ),
      ),
    );
  }
}

class _ThermometerPainter extends CustomPainter {
  final double pressureLevel;
  final Animation<double> animation;

  _ThermometerPainter({
    required this.pressureLevel,
    required this.animation,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final bulbRadius = size.width * 0.3;
    final tubeWidth = size.width * 0.6;
    final tubeHeight = size.height - bulbRadius * 2;

    // Draw thermometer outline
    final outlinePaint = Paint()
      ..color = Colors.grey[400]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Thermometer bulb (bottom)
    canvas.drawCircle(
      Offset(size.width / 2, size.height - bulbRadius),
      bulbRadius,
      outlinePaint,
    );

    // Thermometer tube
    final tubeRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        (size.width - tubeWidth) / 2,
        0,
        tubeWidth,
        tubeHeight,
      ),
      Radius.circular(tubeWidth / 2),
    );
    canvas.drawRRect(tubeRect, outlinePaint);

    // Fill based on animation
    final currentLevel = animation.value;
    final fillHeight = (currentLevel / 100.0) * (tubeHeight + bulbRadius);

    final fillPaint = Paint()
      ..color = _getFillColor(currentLevel)
      ..style = PaintingStyle.fill;

    // Fill bulb
    canvas.drawCircle(
      Offset(size.width / 2, size.height - bulbRadius),
      bulbRadius - 2,
      fillPaint,
    );

    // Fill tube
    if (fillHeight > bulbRadius) {
      final fillRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          (size.width - tubeWidth) / 2 + 2,
          size.height - fillHeight,
          tubeWidth - 4,
          fillHeight - bulbRadius,
        ),
        Radius.circular((tubeWidth - 4) / 2),
      );
      canvas.drawRRect(fillRect, fillPaint);
    }
  }

  Color _getFillColor(double level) {
    if (level <= 20) {
      return Colors.blue;
    } else if (level <= 40) {
      return Colors.green;
    } else if (level <= 60) {
      return Colors.yellow[700]!;
    } else if (level <= 80) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}