import 'package:flutter/material.dart';

class InteractiveResearchScenario extends StatefulWidget {
  final Map<String, dynamic> scenario;

  const InteractiveResearchScenario({super.key, required this.scenario});

  @override
  State<InteractiveResearchScenario> createState() => _InteractiveResearchScenarioState();
}

class _InteractiveResearchScenarioState extends State<InteractiveResearchScenario> {
  double trustLevel = 50;
  List<Widget> conversation = [];
  String currentNodeId = 'start';
  bool isCompleted = false;
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();
    // FIX: Delay any state changes to avoid build conflicts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeConversation();
    });
  }

  void _initializeConversation() {
    if (widget.scenario != null &&
        widget.scenario['conversation'] != null &&
        widget.scenario['conversation'].isNotEmpty) {
      setState(() {
        isInitialized = true;
        _showCurrentNode();
      });
    }
  }

  void _showCurrentNode() {
    final nodes = widget.scenario['conversation'] as List;
    final currentNode = nodes.firstWhere(
      (node) => node['id'] == currentNodeId,
      orElse: () => null,
    );

    if (currentNode == null) {
      _showEndConversation('Unknown error');
      return;
    }

    // Check if this is an end node
    if (currentNode['isEnd'] == true) {
      _showEndConversation(currentNode['text']);
      return;
    }

    // Add the current message
    _addMessage(currentNode);

    // If there are options following this node, show them
    final nextNodeIndex = nodes.indexWhere((node) => node['id'] == currentNodeId) + 1;
    if (nextNodeIndex < nodes.length) {
      final nextNode = nodes[nextNodeIndex];
      if (nextNode['sender'] == 'user_options') {
        _addOptionsMessage(nextNode);
      }
    }
  }

  void _addMessage(Map<String, dynamic> message) {
    setState(() {
      conversation.add(
        Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getMessageColor(message['sender']),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getSenderName(message['sender']),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                message['text'],
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _addOptionsMessage(Map<String, dynamic> optionsNode) {
    setState(() {
      conversation.add(
        Container(
          margin: const EdgeInsets.all(8),
          child: Column(
            children: [
              const Text(
                'How do you respond?',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              ...optionsNode['options'].map<Widget>((option) {
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ElevatedButton(
                    onPressed: isCompleted ? null : () => _handleUserChoice(option),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Colors.blue[100],
                    ),
                    child: Text(
                      option['text'],
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      );
    });
  }

  Color _getMessageColor(String sender) {
    switch (sender) {
      case 'scammer':
        return Colors.red[50]!;
      case 'bank':
      case 'apple':
      case 'fedex':
        return Colors.blue[50]!;
      case 'system':
        return Colors.orange[50]!;
      default:
        return Colors.grey[50]!;
    }
  }

  String _getSenderName(String sender) {
    switch (sender) {
      case 'scammer':
        return 'Scammer';
      case 'bank':
        return 'Bank Alert';
      case 'apple':
        return 'Apple Security';
      case 'fedex':
        return 'FedEx';
      case 'system':
        return 'System';
      default:
        return sender.toUpperCase();
    }
  }

  void _handleUserChoice(Map<String, dynamic> choice) {
    if (isCompleted) return;

    // Add user's choice to conversation
    setState(() {
      conversation.add(
        Container(
          alignment: Alignment.centerRight,
          margin: const EdgeInsets.all(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[300]!),
            ),
            child: Text(
              'You: ${choice['text']}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    });

    // Move to next node
    final nextId = choice['nextId'];
    if (nextId != null) {
      currentNodeId = nextId;
      // Wait a moment then show next node
      Future.delayed(const Duration(milliseconds: 500), () {
        _showCurrentNode();
      });
    }

    // Show trust evaluation after any choice
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!isCompleted) {
        _showTrustEvaluation();
      }
    });
  }

  void _showEndConversation(String endText) {
    setState(() {
      conversation.add(
        Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber[300]!, width: 2),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.flag,
                size: 32,
                color: Colors.amber,
              ),
              const SizedBox(height: 8),
              Text(
                endText,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    });
  }

  void _showTrustEvaluation() {
    if (isCompleted) return;

    setState(() {
      isCompleted = true;
    });

    final isScam = widget.scenario['isScam'] as bool;
    final optimalTrust = widget.scenario['optimalTrust'] as int;
    final trustDifference = (trustLevel - optimalTrust).abs();

    String resultText;
    Color resultColor;
    String scoreText;

    if (isScam && trustLevel > 60) {
      resultText = '❌ You TRUSTED a SCAM!';
      resultColor = Colors.red;
      scoreText = 'Score: -50 points';
    } else if (!isScam && trustLevel < 30) {
      resultText = '⚠️ You REJECTED a LEGITIMATE message!';
      resultColor = Colors.orange;
      scoreText = 'Score: -30 points\nBeing too paranoid can cause you to miss important legitimate messages!';
    } else if (trustDifference < 15) {
      resultText = '✅ Excellent Trust Calibration!';
      resultColor = Colors.green;
      scoreText = 'Score: +100 points';
    } else {
      resultText = '📊 Moderate Calibration';
      resultColor = Colors.blue;
      scoreText = 'Score: +50 points';
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Trust Calibration Results'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Trust Level: ${trustLevel.toInt()}%',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                'Optimal Trust: $optimalTrust%',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                resultText,
                style: TextStyle(
                  color: resultColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                scoreText,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Victim Testimony:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '"${widget.scenario['victimStory']}"',
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isScam ? Colors.red[100] : Colors.green[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'ACTUAL CLASSIFICATION: ${isScam ? 'SCAM' : 'LEGITIMATE'}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isScam ? Colors.red[800] : Colors.green[800],
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to scenarios list
            },
            child: const Text('Back to Scenarios'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              setState(() {
                // Reset for retry
                conversation.clear();
                currentNodeId = 'start';
                isCompleted = false;
                trustLevel = 50;
                _showCurrentNode();
              });
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.scenario['title'] ?? 'Loading...'),
          backgroundColor: Colors.blue[100],
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.scenario['title']),
        backgroundColor: Colors.blue[100],
      ),
      body: Column(
        children: [
          // Instructions banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.amber[100],
            child: const Text(
              'Read the conversation and adjust your trust level. How much do you trust this message?',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          // Conversation area
          Expanded(
            child: ListView(
              children: conversation,
            ),
          ),
          // Trust slider
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Trust Level: ${trustLevel.toInt()}%',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Slider(
                  value: trustLevel,
                  min: 0,
                  max: 100,
                  divisions: 20,
                  activeColor: _getSliderColor(),
                  onChanged: isCompleted ? null : (value) => setState(() => trustLevel = value),
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('🚨 SCAM', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                    Text('✅ LEGITIMATE', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getSliderColor() {
    if (trustLevel < 25) return Colors.red;
    if (trustLevel < 50) return Colors.orange;
    if (trustLevel < 75) return Colors.yellow;
    return Colors.green;
  }
}