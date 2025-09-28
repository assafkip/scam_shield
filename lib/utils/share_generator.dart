import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import '../models/user_progress.dart';

class ShareGenerator {
  static Future<Uint8List?> generateAchievementCard({
    required UserProgress userProgress,
    required String achievementType,
    required String achievementText,
    int? streakDays,
    int? dailyChallenge,
  }) async {
    try {
      // Create a custom widget for the achievement card
      final widget = _AchievementCard(
        userProgress: userProgress,
        achievementType: achievementType,
        achievementText: achievementText,
        streakDays: streakDays,
        dailyChallenge: dailyChallenge,
      );

      // Convert widget to image
      final repaintBoundary = RenderRepaintBoundary();
      final platformDispatcher = ui.PlatformDispatcher.instance;
      final view = platformDispatcher.views.first;

      // Create render view
      final renderView = RenderView(
        view: view,
        child: RenderPositionedBox(
          alignment: Alignment.center,
          child: repaintBoundary,
        ),
        configuration: const ViewConfiguration(),
      );

      // Build the widget tree
      final pipelineOwner = PipelineOwner();
      final buildOwner = BuildOwner(focusManager: FocusManager());

      renderView.prepareInitialFrame();

      final rootElement = RenderObjectToWidgetAdapter<RenderBox>(
        container: repaintBoundary,
        child: widget,
      ).attachToRenderTree(buildOwner);

      buildOwner.buildScope(rootElement);
      buildOwner.finalizeTree();

      pipelineOwner.flushLayout();
      pipelineOwner.flushCompositingBits();
      pipelineOwner.flushPaint();

      // Convert to image
      final image = await repaintBoundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      return byteData?.buffer.asUint8List();
    } catch (e) {
      print('Error generating achievement card: $e');
      return null;
    }
  }

  static String generateShareText({
    required UserProgress userProgress,
    required String achievementType,
    int? streakDays,
    int? dailyChallenge,
  }) {
    String baseText = "I just leveled up my scam detection skills on ScamShield! 🛡️\n\n";

    switch (achievementType) {
      case 'level_up':
        baseText += "🎉 Reached ${userProgress.currentLevel.title} level!\n";
        baseText += "💪 ${userProgress.totalXP} XP earned\n";
        break;
      case 'daily_complete':
        baseText += "✅ Completed today's daily challenge!\n";
        if (dailyChallenge != null) {
          baseText += "📅 Day #$dailyChallenge streak\n";
        }
        break;
      case 'streak':
        baseText += "🔥 $streakDays day learning streak!\n";
        baseText += "💡 Getting better at spotting scams every day\n";
        break;
      case 'perfect_score':
        baseText += "⭐ Perfect score on a tricky scenario!\n";
        baseText += "🎯 Scam detection skills on point\n";
        break;
    }

    baseText += "\nJoin me in learning to stay safe online! 🚀\n";
    baseText += "#ScamShield #CyberSafety #StayProtected";

    return baseText;
  }
}

class _AchievementCard extends StatelessWidget {
  final UserProgress userProgress;
  final String achievementType;
  final String achievementText;
  final int? streakDays;
  final int? dailyChallenge;

  const _AchievementCard({
    required this.userProgress,
    required this.achievementType,
    required this.achievementText,
    this.streakDays,
    this.dailyChallenge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 600,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2196F3),
            Color(0xFF1976D2),
            Color(0xFF0D47A1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: CustomPaint(
              painter: _BackgroundPatternPainter(),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.shield,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'ScamShield',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Achievement icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getAchievementIcon(),
                    color: Colors.white,
                    size: 64,
                  ),
                ),

                const SizedBox(height: 24),

                // Achievement text
                Text(
                  achievementText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // User level and XP
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Color(userProgress.currentLevel.colorValue),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        userProgress.currentLevel.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${userProgress.totalXP} XP',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                if (streakDays != null && streakDays! > 0) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        color: Colors.orange,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$streakDays Day Streak',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],

                const Spacer(),

                // Stats row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStat(
                      'Scenarios',
                      '${userProgress.completedScenarios}',
                      Icons.check_circle,
                    ),
                    _buildStat(
                      'Mastered',
                      '${userProgress.masteredScenarios}',
                      Icons.star,
                    ),
                    _buildStat(
                      'Level',
                      '${userProgress.currentLevel.index + 1}',
                      Icons.trending_up,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Call to action
                const Text(
                  'Beat my score!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Download ScamShield and level up your\ncyber security skills',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getAchievementIcon() {
    switch (achievementType) {
      case 'level_up':
        return Icons.emoji_events;
      case 'daily_complete':
        return Icons.calendar_today;
      case 'streak':
        return Icons.local_fire_department;
      case 'perfect_score':
        return Icons.star;
      default:
        return Icons.shield;
    }
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white70,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    // Draw hexagonal pattern
    final hexSize = 40.0;
    final hexHeight = hexSize * 0.866; // sqrt(3)/2

    for (double x = -hexSize; x < size.width + hexSize; x += hexSize * 1.5) {
      for (double y = -hexSize; y < size.height + hexSize; y += hexHeight) {
        final offsetY = (x / (hexSize * 1.5)).floor() % 2 == 0 ? y : y + hexHeight / 2;
        _drawHexagon(canvas, Offset(x, offsetY), hexSize / 2, paint);
      }
    }
  }

  void _drawHexagon(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60) * (3.14159 / 180);
      final x = center.dx + radius * (angle == 0 ? 1 : angle == 3.14159 ? -1 : 0);
      final y = center.dy + radius * (angle == 1.5708 ? -1 : angle == 4.71239 ? 1 : 0);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}