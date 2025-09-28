import 'package:flutter/material.dart';
import '../data/shieldup_scenarios.dart';
import '../services/trust_calibration_engine.dart';
import 'research_trust_training_page.dart';

/// New scenario picker that uses research-backed content with 50/50 legitimate/scam mix
class ResearchScenarioPicker extends StatefulWidget {
  @override
  _ResearchScenarioPickerState createState() => _ResearchScenarioPickerState();
}

class _ResearchScenarioPickerState extends State<ResearchScenarioPicker> {
  List<ShieldUpScenario> scenarios = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadScenarios();
  }

  void _loadScenarios() {
    setState(() {
      // Get balanced mix of scenarios (50% scams, 50% legitimate)
      scenarios = ShieldUpScenario.getBalancedMix(count: 10);
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Research-Based Training')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final scamCount = scenarios.where((s) => s.isScam).length;
    final legitimateCount = scenarios.where((s) => !s.isScam).length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Trust Calibration Training'),
        backgroundColor: Colors.blue[800],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(scamCount, legitimateCount),
            SizedBox(height: 24),
            _buildInstructions(),
            SizedBox(height: 24),
            _buildScenarioList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(int scamCount, int legitimateCount) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[800]!, Colors.blue[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Research-Based Training',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Real victim experiences + legitimate communications',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              _buildStatChip('🚨 $scamCount Scams', Colors.red[300]!),
              SizedBox(width: 12),
              _buildStatChip('✅ $legitimateCount Legitimate', Colors.green[300]!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.orange[700]),
              SizedBox(width: 8),
              Text(
                'Not Everything Is A Scam!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'This training teaches you to calibrate your trust levels correctly:',
            style: TextStyle(fontSize: 16, color: Colors.orange[800]),
          ),
          SizedBox(height: 8),
          Text(
            '• You\'ll lose points for being too suspicious of legitimate content\n'
            '• You\'ll lose points for being too trusting of scam content\n'
            '• The goal is perfect trust calibration',
            style: TextStyle(fontSize: 14, color: Colors.orange[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildScenarioList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mixed Training Scenarios',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'Scenarios are randomly mixed - don\'t assume patterns!',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        SizedBox(height: 16),
        ...scenarios.asMap().entries.map((entry) {
          int index = entry.key;
          ShieldUpScenario scenario = entry.value;
          return _buildScenarioCard(scenario, index + 1);
        }).toList(),
      ],
    );
  }

  Widget _buildScenarioCard(ShieldUpScenario scenario, int number) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _startScenario(scenario),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          '$number',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            scenario.title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              _buildPlatformChip(scenario.platform),
                              SizedBox(width: 8),
                              Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                              SizedBox(width: 4),
                              Text(
                                '${scenario.conversation.length} messages',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  '\"${scenario.victimTestimony}\"',
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[700],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                Text(
                  'Source: ${scenario.researchSource}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlatformChip(String platform) {
    Color chipColor;
    IconData icon;

    switch (platform.toLowerCase()) {
      case 'whatsapp':
        chipColor = Colors.green;
        icon = Icons.chat;
        break;
      case 'telegram':
        chipColor = Colors.blue;
        icon = Icons.telegram;
        break;
      case 'email':
        chipColor = Colors.red;
        icon = Icons.email;
        break;
      case 'sms':
        chipColor = Colors.orange;
        icon = Icons.sms;
        break;
      case 'phone':
      case 'phone/sms':
        chipColor = Colors.purple;
        icon = Icons.phone;
        break;
      default:
        chipColor = Colors.grey;
        icon = Icons.device_unknown;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: chipColor),
          SizedBox(width: 4),
          Text(
            platform,
            style: TextStyle(
              fontSize: 12,
              color: chipColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _startScenario(ShieldUpScenario scenario) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResearchTrustTrainingPage(scenario: scenario),
      ),
    );
  }
}