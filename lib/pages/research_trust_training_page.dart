import 'package:flutter/material.dart';
import 'dart:async';
import '../data/shieldup_scenarios.dart';
import '../services/trust_calibration_engine.dart';

/// Trust calibration training page using research-backed scenarios
class ResearchTrustTrainingPage extends StatefulWidget {
  final ShieldUpScenario scenario;

  const ResearchTrustTrainingPage({Key? key, required this.scenario}) : super(key: key);

  @override
  _ResearchTrustTrainingPageState createState() => _ResearchTrustTrainingPageState();
}

class _ResearchTrustTrainingPageState extends State<ResearchTrustTrainingPage>
    with TickerProviderStateMixin {
  int currentMessageIndex = 0;
  double userTrustLevel = 50.0;
  bool showTrustSlider = false;
  bool showResults = false;
  TrustCalibrationResult? calibrationResult;

  DateTime? startTime;
  DateTime? decisionTime;

  late AnimationController _messageAnimationController;
  late AnimationController _sliderAnimationController;

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now();

    _messageAnimationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );

    _sliderAnimationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _showNextMessage();
  }

  @override
  void dispose() {
    _messageAnimationController.dispose();
    _sliderAnimationController.dispose();
    super.dispose();
  }

  void _showNextMessage() {
    _messageAnimationController.forward().then((_) {
      Timer(Duration(milliseconds: 1500), () {
        if (currentMessageIndex < widget.scenario.conversation.length - 1) {
          setState(() {
            currentMessageIndex++;
          });
          _messageAnimationController.reset();
          _showNextMessage();
        } else {
          _showTrustSlider();
        }
      });
    });
  }

  void _showTrustSlider() {
    setState(() {
      showTrustSlider = true;
    });
    _sliderAnimationController.forward();
  }

  void _submitTrustRating() {
    decisionTime = DateTime.now();
    int timeToDecision = decisionTime!.difference(startTime!).inSeconds;

    // Calculate trust calibration result
    calibrationResult = TrustCalibrationEngine.evaluateResponse(
      userTrustLevel: userTrustLevel,
      scenario: widget.scenario,
      timeToDecision: timeToDecision,
    );

    setState(() {
      showResults = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showResults) {
      return _buildResultsPage();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.scenario.title),
        backgroundColor: Colors.blue[800],
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildPlatformHeader(),
                  SizedBox(height: 16),
                  _buildConversation(),
                  if (showTrustSlider) ...[
                    SizedBox(height: 32),
                    _buildTrustSlider(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    double progress = showTrustSlider ? 1.0 : (currentMessageIndex + 1) / widget.scenario.conversation.length;

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Message ${currentMessageIndex + 1}/${widget.scenario.conversation.length}'),
              Text('Research-Based Training'),
            ],
          ),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(_getPlatformIcon(), color: Colors.blue[700], size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.scenario.platform,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
                Text(
                  'Source: ${widget.scenario.researchSource}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPlatformIcon() {
    switch (widget.scenario.platform.toLowerCase()) {
      case 'whatsapp': return Icons.chat;
      case 'telegram': return Icons.telegram;
      case 'email': return Icons.email;
      case 'sms': return Icons.sms;
      case 'phone':
      case 'phone/sms': return Icons.phone;
      default: return Icons.message;
    }
  }

  Widget _buildConversation() {
    return Column(
      children: widget.scenario.conversation.asMap().entries.map((entry) {
        int index = entry.key;
        ShieldUpMessage message = entry.value;

        if (index <= currentMessageIndex) {
          return AnimatedBuilder(
            animation: _messageAnimationController,
            builder: (context, child) {
              if (index == currentMessageIndex) {
                return FadeTransition(
                  opacity: _messageAnimationController,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset(0, 0.5),
                      end: Offset.zero,
                    ).animate(_messageAnimationController),
                    child: _buildMessageBubble(message),
                  ),
                );
              }
              return _buildMessageBubble(message);
            },
          );
        }
        return SizedBox.shrink();
      }).toList(),
    );
  }

  Widget _buildMessageBubble(ShieldUpMessage message) {
    bool isFromScammer = message.isFromScammer;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: isFromScammer ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isFromScammer ? Colors.grey[200] : Colors.blue[100],
                borderRadius: BorderRadius.circular(16),
                border: isFromScammer && message.manipulationTactics.isNotEmpty
                    ? Border.all(color: Colors.red[300]!, width: 2)
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.from,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    message.text,
                    style: TextStyle(fontSize: 16),
                  ),
                  if (message.manipulationTactics.isNotEmpty) ...[
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: message.manipulationTactics.map((tactic) {
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            tactic,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.red[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustSlider() {
    return AnimatedBuilder(
      animation: _sliderAnimationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _sliderAnimationController,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0, 1),
              end: Offset.zero,
            ).animate(_sliderAnimationController),
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'How much do you trust this communication?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Rate your trust level from 0 (completely suspicious) to 100 (completely trustworthy)',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  Row(
                    children: [
                      Text('0', style: TextStyle(fontWeight: FontWeight.bold)),
                      Expanded(
                        child: Slider(
                          value: userTrustLevel,
                          min: 0,
                          max: 100,
                          divisions: 20,
                          label: userTrustLevel.round().toString(),
                          onChanged: (value) {
                            setState(() {
                              userTrustLevel = value;
                            });
                          },
                        ),
                      ),
                      Text('100', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getTrustLevelColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Trust Level: ${userTrustLevel.round()}% - ${_getTrustLevelLabel()}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getTrustLevelColor(),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitTrustRating,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Submit Trust Rating',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
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

  Color _getTrustLevelColor() {
    if (userTrustLevel < 25) return Colors.red;
    if (userTrustLevel < 50) return Colors.orange;
    if (userTrustLevel < 75) return Colors.yellow[700]!;
    return Colors.green;
  }

  String _getTrustLevelLabel() {
    if (userTrustLevel < 25) return 'Very Suspicious';
    if (userTrustLevel < 50) return 'Suspicious';
    if (userTrustLevel < 75) return 'Neutral';
    return 'Trusting';
  }

  Widget _buildResultsPage() {
    final result = calibrationResult!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Trust Calibration Results'),
        backgroundColor: Colors.blue[800],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildScoreCard(result),
            SizedBox(height: 24),
            _buildAnalysisCard(result),
            SizedBox(height: 24),
            _buildVictimTestimony(),
            SizedBox(height: 24),
            _buildImprovementTips(result),
            SizedBox(height: 32),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard(TrustCalibrationResult result) {
    Color scoreColor = result.points > 50 ? Colors.green :
                      result.points > 0 ? Colors.orange : Colors.red;

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scoreColor.withOpacity(0.1), scoreColor.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scoreColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            '${result.points}',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: scoreColor,
            ),
          ),
          Text(
            'Trust Calibration Score',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: scoreColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              result.accuracy.replaceAll('_', ' ').toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: scoreColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisCard(TrustCalibrationResult result) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Analysis',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text(
              result.feedback,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  widget.scenario.isScam ? Icons.warning : Icons.verified,
                  color: widget.scenario.isScam ? Colors.red : Colors.green,
                ),
                SizedBox(width: 8),
                Text(
                  widget.scenario.isScam ? 'This was a SCAM' : 'This was LEGITIMATE',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: widget.scenario.isScam ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Optimal trust level: ${widget.scenario.optimalTrustLevel.round()}%',
              style: TextStyle(color: Colors.grey[600]),
            ),
            Text(
              'Your trust level: ${userTrustLevel.round()}%',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVictimTestimony() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: Colors.blue[600]),
                SizedBox(width: 8),
                Text(
                  'Real Experience',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              '\"${widget.scenario.victimTestimony}\"',
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImprovementTips(TrustCalibrationResult result) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Improvement Tips',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            ...result.improvementTips.map((tip) {
              return Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lightbulb, color: Colors.amber, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tip,
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Continue Training',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Back to Home',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}