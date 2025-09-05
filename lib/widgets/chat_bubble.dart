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

  String _getImagePath(BubbleType type) {
    switch (type) {
      case BubbleType.incoming:
        return 'assets/images/bubble_incoming.png';
      case BubbleType.outgoing:
        return 'assets/images/bubble_outgoing.png';
      case BubbleType.highlight:
        return 'assets/images/bubble_highlight.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(_getImagePath(type)),
          centerSlice: Rect.fromLTWH(10, 10, 10, 10), // For 9-patch scaling
          fit: BoxFit.fill,
        ),
      ),
      child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
    );
  }
}