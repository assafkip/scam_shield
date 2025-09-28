import 'package:flutter/material.dart';
import 'dart:ui';
import '../models/scenario.dart';
import '../models/user_progress.dart';

class ViralScenarioCard extends StatefulWidget {
  final Scenario scenario;
  final ScenarioProgress progress;
  final VoidCallback onTap;

  const ViralScenarioCard({
    Key? key,
    required this.scenario,
    required this.progress,
    required this.onTap,
  }) : super(key: key);

  @override
  State<ViralScenarioCard> createState() => _ViralScenarioCardState();
}

class _ViralScenarioCardState extends State<ViralScenarioCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;

  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOut,
    ));

    _shadowAnimation = Tween<double>(
      begin: 4.0,
      end: 12.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _onHoverStart() {
    setState(() => _isHovered = true);
    _hoverController.forward();
  }

  void _onHoverEnd() {
    setState(() => _isHovered = false);
    _hoverController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return AnimatedBuilder(
      animation: _hoverController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: MouseRegion(
            onEnter: (_) => _onHoverStart(),
            onExit: (_) => _onHoverEnd(),
            child: GestureDetector(
              onTap: widget.onTap,
              child: Container(
                height: 120,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: _shadowAnimation.value,
                      offset: Offset(0, _shadowAnimation.value / 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      // Background: Platform-specific styling
                      _buildPlatformBackground(),

                      // Gradient overlay for readability
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),

                      // Content
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Top row: Platform icon and status
                            Row(
                              children: [
                                _buildPlatformIcon(),
                                const Spacer(),
                                _buildStatusIndicator(),
                              ],
                            ),

                            // Bottom: Preview text and difficulty
                            _buildBottomContent(isMobile),
                          ],
                        ),
                      ),

                      // Hover effect overlay
                      if (_isHovered)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),

                      // New indicator pulsing dot
                      if (!widget.progress.isCompleted)
                        Positioned(
                          top: 12,
                          right: 12,
                          child: _buildNewIndicator(),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlatformBackground() {
    Color primaryColor;
    Color secondaryColor;

    switch (widget.scenario.platform) {
      case 'whatsapp':
        primaryColor = const Color(0xFF25D366);
        secondaryColor = const Color(0xFF128C7E);
        break;
      case 'email':
        primaryColor = const Color(0xFF4285F4);
        secondaryColor = const Color(0xFF1A73E8);
        break;
      case 'sms':
        primaryColor = const Color(0xFF34B7F1);
        secondaryColor = const Color(0xFF1DA1F2);
        break;
      case 'tinder':
        primaryColor = const Color(0xFFFF4458);
        secondaryColor = const Color(0xFFE91E63);
        break;
      default:
        primaryColor = Colors.grey.shade600;
        secondaryColor = Colors.grey.shade800;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryColor, secondaryColor],
        ),
      ),
      child: Stack(
        children: [
          // Platform-specific pattern
          _buildPlatformPattern(),

          // Subtle animated background
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(_isHovered ? 0.1 : 0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformPattern() {
    switch (widget.scenario.platform) {
      case 'whatsapp':
        return _buildWhatsAppPattern();
      case 'email':
        return _buildEmailPattern();
      case 'sms':
        return _buildSMSPattern();
      case 'tinder':
        return _buildTinderPattern();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildWhatsAppPattern() {
    return Positioned.fill(
      child: CustomPaint(
        painter: WhatsAppPatternPainter(),
      ),
    );
  }

  Widget _buildEmailPattern() {
    return Positioned.fill(
      child: CustomPaint(
        painter: EmailPatternPainter(),
      ),
    );
  }

  Widget _buildSMSPattern() {
    return Positioned.fill(
      child: CustomPaint(
        painter: SMSPatternPainter(),
      ),
    );
  }

  Widget _buildTinderPattern() {
    return Positioned.fill(
      child: CustomPaint(
        painter: TinderPatternPainter(),
      ),
    );
  }

  Widget _buildPlatformIcon() {
    IconData iconData;
    Color iconColor = Colors.white;

    switch (widget.scenario.platform) {
      case 'whatsapp':
        iconData = Icons.chat;
        break;
      case 'email':
        iconData = Icons.email;
        break;
      case 'sms':
        iconData = Icons.sms;
        break;
      case 'tinder':
        iconData = Icons.favorite;
        break;
      default:
        iconData = Icons.message;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 20,
      ),
    );
  }

  Widget _buildStatusIndicator() {
    if (widget.progress.isMastered) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFFD700),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.star,
              color: Colors.white,
              size: 14,
            ),
            SizedBox(width: 4),
            Text(
              'MASTER',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    } else if (widget.progress.isCompleted) {
      return const Icon(
        Icons.check_circle,
        color: Color(0xFF00C851),
        size: 20,
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildBottomContent(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sender name
        Text(
          _getSenderName(),
          style: TextStyle(
            color: Colors.white,
            fontSize: isMobile ? 16 : 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),

        // Preview text (one line only)
        Text(
          _getPreviewText(),
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: isMobile ? 14 : 12,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 4),

        // Bottom row: Difficulty and platform
        Row(
          children: [
            _buildDifficultyStars(),
            const Spacer(),
            Text(
              widget.scenario.platform.toUpperCase(),
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDifficultyStars() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Padding(
          padding: const EdgeInsets.only(right: 2),
          child: Icon(
            index < widget.scenario.difficulty ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 12,
          ),
        );
      }),
    );
  }

  Widget _buildNewIndicator() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1500),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 1.0 + (value * 0.3),
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: const Color(0xFFFF4444),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF4444).withOpacity(0.5),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getSenderName() {
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
        return 'Sarah Wilson';
      case 'pkg_001':
        return 'FedEx Delivery';
      case 'bank_001':
        return 'Chase Security';
      case 'rental_001':
        return 'NYC Landlord';
      case 'charity_001':
        return 'Disaster Relief';
      default:
        return widget.scenario.messages.isNotEmpty
            ? widget.scenario.messages.first.from
            : 'Unknown';
    }
  }

  String _getPreviewText() {
    final firstMessage = widget.scenario.messages.isNotEmpty
        ? widget.scenario.messages.first.text
        : '';

    // Truncate to 30 characters for visual appeal
    if (firstMessage.length > 30) {
      return '${firstMessage.substring(0, 27)}...';
    }
    return firstMessage;
  }
}

// Platform-specific pattern painters
class WhatsAppPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    // Draw chat bubble pattern
    for (double x = 0; x < size.width; x += 40) {
      for (double y = 0; y < size.height; y += 30) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, 25, 15),
            const Radius.circular(8),
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class EmailPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw envelope pattern
    for (double x = 0; x < size.width; x += 50) {
      for (double y = 0; y < size.height; y += 40) {
        final rect = Rect.fromLTWH(x, y, 30, 20);
        canvas.drawRect(rect, paint);
        // Draw envelope flap
        final path = Path()
          ..moveTo(x, y)
          ..lineTo(x + 15, y + 10)
          ..lineTo(x + 30, y);
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SMSPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    // Draw message bubble pattern
    for (double x = 0; x < size.width; x += 45) {
      for (double y = 0; y < size.height; y += 35) {
        final path = Path()
          ..addRRect(RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, 30, 20),
            const Radius.circular(10),
          ))
          ..moveTo(x + 5, y + 20)
          ..lineTo(x, y + 25)
          ..lineTo(x + 10, y + 20);
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TinderPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    // Draw heart pattern
    for (double x = 0; x < size.width; x += 40) {
      for (double y = 0; y < size.height; y += 35) {
        _drawHeart(canvas, Offset(x + 10, y + 10), 8, paint);
      }
    }
  }

  void _drawHeart(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    path.moveTo(center.dx, center.dy + size * 0.3);

    path.cubicTo(
      center.dx - size * 0.5, center.dy - size * 0.3,
      center.dx - size, center.dy + size * 0.2,
      center.dx, center.dy + size * 0.8,
    );

    path.cubicTo(
      center.dx + size, center.dy + size * 0.2,
      center.dx + size * 0.5, center.dy - size * 0.3,
      center.dx, center.dy + size * 0.3,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}