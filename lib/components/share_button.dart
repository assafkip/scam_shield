import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/user_progress.dart';
import '../utils/share_generator.dart';

class ShareButton extends StatelessWidget {
  final UserProgress userProgress;
  final String achievementType;
  final String achievementText;
  final int? streakDays;
  final int? dailyChallenge;

  const ShareButton({
    Key? key,
    required this.userProgress,
    required this.achievementType,
    required this.achievementText,
    this.streakDays,
    this.dailyChallenge,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _shareAchievement(context),
      icon: const Icon(Icons.share),
      label: const Text('Share Achievement'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
    );
  }

  Future<void> _shareAchievement(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Generating share card...'),
                ],
              ),
            ),
          ),
        ),
      );

      // Generate share text
      final shareText = ShareGenerator.generateShareText(
        userProgress: userProgress,
        achievementType: achievementType,
        streakDays: streakDays,
        dailyChallenge: dailyChallenge,
      );

      // For web, we'll just copy the text to clipboard
      // In a mobile app, you would use share_plus package
      await Clipboard.setData(ClipboardData(text: shareText));

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Achievement copied to clipboard!'),
              ],
            ),
            backgroundColor: const Color(0xFF00C851),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            action: SnackBarAction(
              label: 'Share More',
              textColor: Colors.white,
              onPressed: () {
                _showShareOptions(context, shareText);
              },
            ),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if it's open
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate share content: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showShareOptions(BuildContext context, String shareText) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Share Your Achievement',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Share text preview
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                shareText,
                style: const TextStyle(fontSize: 14),
              ),
            ),

            const SizedBox(height: 20),

            // Share options
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption(
                  icon: Icons.copy,
                  label: 'Copy',
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: shareText));
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied to clipboard!')),
                    );
                  },
                ),
                _buildShareOption(
                  icon: Icons.link,
                  label: 'Generate Link',
                  onTap: () {
                    final encodedText = Uri.encodeComponent(shareText);
                    final shareUrl = 'https://twitter.com/intent/tweet?text=$encodedText';
                    Clipboard.setData(ClipboardData(text: shareUrl));
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Share link copied!')),
                    );
                  },
                ),
                _buildShareOption(
                  icon: Icons.more_horiz,
                  label: 'More',
                  onTap: () {
                    Navigator.of(context).pop();
                    // In a real app, you would open system share sheet
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Use your device\'s share function to share the copied text!'),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: const Color(0xFF2196F3)),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}