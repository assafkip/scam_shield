import 'package:flutter/material.dart';

enum BubbleType {
  incoming,
  outgoing,
  highlight,
}

class ChatBubble extends StatelessWidget {
  final String text;
  final BubbleType type;

  const ChatBubble({super.key, required this.text, required this.type});

  Color _getBubbleColor(BubbleType type) {
    switch (type) {
      case BubbleType.incoming:
        return Colors.blue.shade100;
      case BubbleType.outgoing:
        return Colors.green.shade100;
      case BubbleType.highlight:
        return Colors.yellow.shade100;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: _getBubbleColor(type),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
    );
  }
}