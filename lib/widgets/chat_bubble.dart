import 'package:flutter/material.dart';

enum BubbleType { incoming, outgoing, highlight }

class ChatBubble extends StatelessWidget {
  final String text;
  final BubbleType type;

  const ChatBubble({super.key, required this.text, required this.type});

  String _getBubbleImage(BubbleType type) {
    switch (type) {
      case BubbleType.incoming:
        return 'assets/images/bubble_incoming.png';
      case BubbleType.outgoing:
        return 'assets/images/bubble_outgoing.png';
      case BubbleType.highlight:
        return 'assets/images/bubble_highlight.png';
    }
  }

  Color _getTextColor(BubbleType type) {
    switch (type) {
      case BubbleType.incoming:
        return Colors.black87;
      case BubbleType.outgoing:
        return Colors.white;
      case BubbleType.highlight:
        return Colors.black87;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Stack(
        children: [
          // Background bubble image
          Image.asset(
            _getBubbleImage(type),
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Fallback to original design if image not found
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: type == BubbleType.incoming 
                      ? Colors.blue.shade100 
                      : type == BubbleType.outgoing
                      ? Colors.green.shade100
                      : Colors.yellow.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: _getTextColor(type),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            },
          ),
          // Text overlay
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Center(
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: _getTextColor(type),
                    fontWeight: FontWeight.w500,
                    shadows: type == BubbleType.outgoing ? [
                      const Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 2,
                        color: Colors.black26,
                      ),
                    ] : null,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
