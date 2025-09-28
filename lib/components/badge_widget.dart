import 'package:flutter/material.dart';
import '../models/badge.dart';

class BadgeWidget extends StatelessWidget {
  final ScenarioBadge? badge;
  final bool isEarned;
  final double size;
  final bool showTitle;

  const BadgeWidget({
    Key? key,
    this.badge,
    this.isEarned = false,
    this.size = 60,
    this.showTitle = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final badgeType = badge?.type ?? BadgeType.bronze;
    final emoji = badge?.emoji ?? _getEmojiForType(badgeType);
    final title = badge?.title ?? _getTitleForType(badgeType);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isEarned
                ? _getBackgroundColor(badgeType)
                : Colors.grey.shade200,
            border: Border.all(
              color: isEarned
                  ? _getBorderColor(badgeType)
                  : Colors.grey.shade400,
              width: 2,
            ),
            boxShadow: isEarned ? [
              BoxShadow(
                color: _getBorderColor(badgeType).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Center(
            child: Text(
              emoji,
              style: TextStyle(
                fontSize: size * 0.4,
                color: isEarned ? null : Colors.grey.shade400,
              ),
            ),
          ),
        ),
        if (showTitle) ...[
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isEarned ? Colors.black87 : Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  String _getEmojiForType(BadgeType type) {
    switch (type) {
      case BadgeType.bronze:
        return '🥉';
      case BadgeType.silver:
        return '🥈';
      case BadgeType.gold:
        return '🥇';
      case BadgeType.star:
        return '⭐';
    }
  }

  String _getTitleForType(BadgeType type) {
    switch (type) {
      case BadgeType.bronze:
        return 'Bronze';
      case BadgeType.silver:
        return 'Silver';
      case BadgeType.gold:
        return 'Gold';
      case BadgeType.star:
        return 'Star';
    }
  }

  Color _getBackgroundColor(BadgeType type) {
    switch (type) {
      case BadgeType.bronze:
        return const Color(0xFFCD7F32).withOpacity(0.1);
      case BadgeType.silver:
        return const Color(0xFFC0C0C0).withOpacity(0.1);
      case BadgeType.gold:
        return const Color(0xFFFFD700).withOpacity(0.1);
      case BadgeType.star:
        return const Color(0xFFFFD600).withOpacity(0.1);
    }
  }

  Color _getBorderColor(BadgeType type) {
    switch (type) {
      case BadgeType.bronze:
        return const Color(0xFFCD7F32);
      case BadgeType.silver:
        return const Color(0xFFC0C0C0);
      case BadgeType.gold:
        return const Color(0xFFFFD700);
      case BadgeType.star:
        return const Color(0xFFFFD600);
    }
  }
}

class BadgeGrid extends StatelessWidget {
  final List<ScenarioBadge> earnedBadges;
  final List<String> allScenarioIds;

  const BadgeGrid({
    Key? key,
    required this.earnedBadges,
    required this.allScenarioIds,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: allScenarioIds.map((scenarioId) {
        final earnedBadge = earnedBadges
            .where((badge) => badge.scenarioId == scenarioId)
            .firstOrNull;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BadgeWidget(
              badge: earnedBadge,
              isEarned: earnedBadge != null,
              size: 50,
            ),
            const SizedBox(height: 4),
            Text(
              scenarioId,
              style: TextStyle(
                fontSize: 10,
                color: earnedBadge != null ? Colors.black87 : Colors.grey.shade500,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class BadgeProgressIndicator extends StatelessWidget {
  final List<ScenarioBadge> earnedBadges;
  final int totalScenarios;

  const BadgeProgressIndicator({
    Key? key,
    required this.earnedBadges,
    required this.totalScenarios,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final completedCount = earnedBadges.length;
    final masteredCount = earnedBadges
        .where((badge) => badge.type == BadgeType.gold || badge.type == BadgeType.star)
        .length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progress',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$completedCount of $totalScenarios scenarios completed',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            '$masteredCount scenarios mastered (Gold/Star)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF00C851),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: completedCount / totalScenarios,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}