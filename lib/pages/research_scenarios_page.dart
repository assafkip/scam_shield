import 'package:flutter/material.dart';
import 'interactive_research_scenario.dart';

class ResearchScenariosPage extends StatefulWidget {
  const ResearchScenariosPage({super.key});

  @override
  State<ResearchScenariosPage> createState() => _ResearchScenariosPageState();
}

class _ResearchScenariosPageState extends State<ResearchScenariosPage> {
  List<Map<String, dynamic>> researchScenarios = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // FIX: Use addPostFrameCallback to avoid build conflicts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadScenarios();
    });
  }

  Future<void> _loadScenarios() async {
    // Load scenarios here with COMPLETE conversations
    setState(() {
      researchScenarios = [
        {
          'title': 'Chase Bank Fraud Alert',
          'platform': 'SMS',
          'isScam': false, // LEGITIMATE
          'optimalTrust': 65,
          'firstMessage': 'Chase Fraud Alert: Did you attempt \$487.23 at Walmart? Reply YES or NO',
          'victimStory': 'I rejected this thinking it was fake and missed actual fraud on my account',
          'conversation': [
            {
              'id': 'start',
              'sender': 'bank',
              'text': 'Chase Fraud Alert: Did you attempt a \$487.23 transaction at Walmart in Ohio? Reply YES or NO'
            },
            {
              'id': 'options_1',
              'sender': 'user_options',
              'options': [
                {'text': 'NO', 'nextId': 'no_response'},
                {'text': 'YES', 'nextId': 'yes_response'},
                {'text': 'This seems fake', 'nextId': 'verify_response'},
              ]
            },
            {
              'id': 'no_response',
              'sender': 'bank',
              'text': 'Your card has been temporarily blocked for safety. Please call 1-800-935-9935 or visit a branch to restore access.'
            },
            {
              'id': 'options_2',
              'sender': 'user_options',
              'options': [
                {'text': 'OK, I\'ll call the number', 'nextId': 'end_safe'},
                {'text': 'Can you handle via text?', 'nextId': 'no_text_response'},
              ]
            },
            {
              'id': 'yes_response',
              'sender': 'bank',
              'text': 'Thank you for confirming. Your transaction has been approved and no further action is needed.'
            },
            {
              'id': 'options_3',
              'sender': 'user_options',
              'options': [
                {'text': 'Great, thanks', 'nextId': 'end_confirmed'},
              ]
            },
            {
              'id': 'verify_response',
              'sender': 'bank',
              'text': 'For security, always verify alerts by calling the number on your card or visiting your bank directly.'
            },
            {
              'id': 'options_4',
              'sender': 'user_options',
              'options': [
                {'text': 'Good advice, I\'ll do that', 'nextId': 'end_smart'},
              ]
            },
            {
              'id': 'no_text_response',
              'sender': 'bank',
              'text': 'We cannot process account changes via SMS. Please call 1-800-935-9935 for assistance.'
            },
            {
              'id': 'options_5',
              'sender': 'user_options',
              'options': [
                {'text': 'Understood', 'nextId': 'end_safe'},
              ]
            },
            {
              'id': 'end_safe',
              'sender': 'system',
              'text': 'CONVERSATION ENDED: This was a LEGITIMATE fraud alert. You handled it correctly by using official channels.',
              'isEnd': true,
              'endType': 'legitimate_handled_well'
            },
            {
              'id': 'end_confirmed',
              'sender': 'system',
              'text': 'CONVERSATION ENDED: This was LEGITIMATE. Your transaction was properly verified.',
              'isEnd': true,
              'endType': 'legitimate_confirmed'
            },
            {
              'id': 'end_smart',
              'sender': 'system',
              'text': 'CONVERSATION ENDED: Excellent! This was LEGITIMATE but you wisely chose to verify through official channels.',
              'isEnd': true,
              'endType': 'legitimate_verified'
            },
          ],
        },
        {
          'title': 'Military Romance Scam',
          'platform': 'WhatsApp',
          'isScam': true, // SCAM
          'optimalTrust': 10,
          'firstMessage': 'Hey beautiful, I\'m James, deployed overseas and need help...',
          'victimStory': 'Lost \$15,000 to someone claiming to be deployed military needing emergency funds',
          'conversation': [
            {
              'id': 'start',
              'sender': 'scammer',
              'text': 'Hey beautiful, I\'m Sergeant James deployed overseas. I need urgent help with something important.'
            },
            {
              'id': 'options_1',
              'sender': 'user_options',
              'options': [
                {'text': 'How can I help?', 'nextId': 'help_response'},
                {'text': 'I don\'t know you', 'nextId': 'suspicious_response'},
                {'text': 'Prove you\'re military', 'nextId': 'prove_response'},
              ]
            },
            {
              'id': 'help_response',
              'sender': 'scammer',
              'text': 'I need iTunes gift cards to call my sick daughter. Military phones don\'t work here and it\'s the only way.'
            },
            {
              'id': 'options_2',
              'sender': 'user_options',
              'options': [
                {'text': 'How much do you need?', 'nextId': 'amount_response'},
                {'text': 'That sounds suspicious', 'nextId': 'suspicious_response'},
                {'text': 'Why iTunes cards?', 'nextId': 'why_itunes'},
              ]
            },
            {
              'id': 'suspicious_response',
              'sender': 'scammer',
              'text': 'Please, I\'m fighting for our freedom! Don\'t you support our troops? I really need this help.'
            },
            {
              'id': 'options_3',
              'sender': 'user_options',
              'options': [
                {'text': 'I support troops but this is fishy', 'nextId': 'end_scam_avoided'},
                {'text': 'OK, I\'ll help', 'nextId': 'amount_response'},
              ]
            },
            {
              'id': 'prove_response',
              'sender': 'scammer',
              'text': 'I can\'t share details for security reasons. Just trust me, I need \$500 urgently for my daughter\'s medicine.'
            },
            {
              'id': 'options_4',
              'sender': 'user_options',
              'options': [
                {'text': 'No proof, no help', 'nextId': 'end_scam_avoided'},
                {'text': 'OK, I believe you', 'nextId': 'amount_response'},
              ]
            },
            {
              'id': 'why_itunes',
              'sender': 'scammer',
              'text': 'iTunes cards can be converted to cash quickly. It\'s the fastest way to get money here.'
            },
            {
              'id': 'options_5',
              'sender': 'user_options',
              'options': [
                {'text': 'That makes no sense', 'nextId': 'end_scam_avoided'},
                {'text': 'OK, how many cards?', 'nextId': 'amount_response'},
              ]
            },
            {
              'id': 'amount_response',
              'sender': 'scammer',
              'text': 'I need \$500 in iTunes cards. You\'re my angel! I\'ll pay you back double when I return next month.'
            },
            {
              'id': 'options_6',
              'sender': 'user_options',
              'options': [
                {'text': 'I\'ll get the cards now', 'nextId': 'end_scam_success'},
                {'text': 'This is definitely a scam', 'nextId': 'end_scam_avoided'},
              ]
            },
            {
              'id': 'end_scam_success',
              'sender': 'system',
              'text': 'CONVERSATION ENDED: This was a SCAM and you fell for it. Military personnel never ask for iTunes cards.',
              'isEnd': true,
              'endType': 'user_scammed'
            },
            {
              'id': 'end_scam_avoided',
              'sender': 'system',
              'text': 'CONVERSATION ENDED: You correctly identified this SCAM. Real military personnel never request gift cards.',
              'isEnd': true,
              'endType': 'scam_avoided'
            },
          ],
        },
        {
          'title': 'IRS Tax Scam',
          'platform': 'SMS',
          'isScam': true, // SCAM
          'optimalTrust': 5,
          'firstMessage': 'URGENT: IRS FINAL NOTICE. Pay \$2,847 in taxes or face arrest. Call now!',
          'victimStory': 'Paid \$3,000 in gift cards because I was terrified of being arrested',
          'conversation': [
            {
              'id': 'start',
              'sender': 'scammer',
              'text': 'URGENT: IRS FINAL NOTICE. You owe \$2,847 in back taxes. Pay immediately or face arrest warrant within 24 hours.'
            },
            {
              'id': 'options_1',
              'sender': 'user_options',
              'options': [
                {'text': 'How do I pay?', 'nextId': 'payment_response'},
                {'text': 'IRS doesn\'t text', 'nextId': 'dispute_response'},
                {'text': 'I need to verify this', 'nextId': 'verify_response'},
              ]
            },
            {
              'id': 'payment_response',
              'sender': 'scammer',
              'text': 'Buy \$2,847 in iTunes gift cards immediately and read me the codes. This is the only way to stop the arrest warrant.'
            },
            {
              'id': 'options_2',
              'sender': 'user_options',
              'options': [
                {'text': 'I\'ll get the cards now', 'nextId': 'end_scam_success'},
                {'text': 'Why iTunes cards?', 'nextId': 'why_cards'},
                {'text': 'This is clearly a scam', 'nextId': 'end_scam_avoided'},
              ]
            },
            {
              'id': 'dispute_response',
              'sender': 'scammer',
              'text': 'This is a new emergency system for urgent cases. Police are already dispatched to your location!'
            },
            {
              'id': 'options_3',
              'sender': 'user_options',
              'options': [
                {'text': 'OK, I\'ll pay now!', 'nextId': 'payment_response'},
                {'text': 'I\'m calling the real IRS', 'nextId': 'end_scam_avoided'},
              ]
            },
            {
              'id': 'verify_response',
              'sender': 'scammer',
              'text': 'No time for verification! Pay now or go to jail. Your choice! The warrant is being processed as we speak.'
            },
            {
              'id': 'options_4',
              'sender': 'user_options',
              'options': [
                {'text': 'Fine, I\'ll pay', 'nextId': 'payment_response'},
                {'text': 'I\'m hanging up', 'nextId': 'end_scam_avoided'},
              ]
            },
            {
              'id': 'why_cards',
              'sender': 'scammer',
              'text': 'Gift cards are the fastest payment method for emergency tax situations. It goes directly to the Treasury.'
            },
            {
              'id': 'options_5',
              'sender': 'user_options',
              'options': [
                {'text': 'That doesn\'t sound right', 'nextId': 'end_scam_avoided'},
                {'text': 'OK, buying cards now', 'nextId': 'end_scam_success'},
              ]
            },
            {
              'id': 'end_scam_success',
              'sender': 'system',
              'text': 'CONVERSATION ENDED: This was a SCAM and you fell for it. The IRS never demands immediate payment via gift cards.',
              'isEnd': true,
              'endType': 'user_scammed'
            },
            {
              'id': 'end_scam_avoided',
              'sender': 'system',
              'text': 'CONVERSATION ENDED: You correctly identified this SCAM. The IRS never contacts people via SMS or demands gift cards.',
              'isEnd': true,
              'endType': 'scam_avoided'
            },
          ],
        },
        // Adding 6 more complete scenarios with proper endings...
        {
          'title': 'Bank of America Security Alert',
          'platform': 'Email',
          'isScam': false, // LEGITIMATE
          'optimalTrust': 70,
          'firstMessage': 'Security Alert: We detected unusual activity on your account ending in 4829',
          'victimStory': 'I ignored this and later found out someone had actually accessed my account',
          'conversation': [
            {
              'id': 'start',
              'sender': 'bank',
              'text': 'Security Alert: We detected unusual sign-in activity on your account ending in 4829 from Russia. Please review immediately.'
            },
            {
              'id': 'options_1',
              'sender': 'user_options',
              'options': [
                {'text': 'Check my account', 'nextId': 'check_response'},
                {'text': 'This is phishing', 'nextId': 'phishing_response'},
                {'text': 'Call bank directly', 'nextId': 'call_response'},
              ]
            },
            {
              'id': 'check_response',
              'sender': 'bank',
              'text': 'Please log in to your account at bankofamerica.com or call 1-800-432-1000. Reference case #BA-2024-789456.'
            },
            {
              'id': 'options_2',
              'sender': 'user_options',
              'options': [
                {'text': 'I\'ll log in directly', 'nextId': 'end_safe'},
              ]
            },
            {
              'id': 'phishing_response',
              'sender': 'bank',
              'text': 'We understand your caution. Please call the number on your debit card to verify this alert.'
            },
            {
              'id': 'options_3',
              'sender': 'user_options',
              'options': [
                {'text': 'Good idea, calling now', 'nextId': 'end_verified'},
              ]
            },
            {
              'id': 'call_response',
              'sender': 'bank',
              'text': 'Excellent security practice. Please have your account number ready when you call 1-800-432-1000.'
            },
            {
              'id': 'options_4',
              'sender': 'user_options',
              'options': [
                {'text': 'Will do, thanks', 'nextId': 'end_verified'},
              ]
            },
            {
              'id': 'end_safe',
              'sender': 'system',
              'text': 'CONVERSATION ENDED: This was LEGITIMATE. You handled it correctly by going directly to the official website.',
              'isEnd': true,
              'endType': 'legitimate_handled_well'
            },
            {
              'id': 'end_verified',
              'sender': 'system',
              'text': 'CONVERSATION ENDED: Perfect! This was LEGITIMATE and you verified it through official channels.',
              'isEnd': true,
              'endType': 'legitimate_verified'
            },
          ],
        },
      ];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Research-Based Scenarios'),
          backgroundColor: Colors.blue[100],
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Research-Based Scenarios'),
        backgroundColor: Colors.blue[100],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.yellow[100],
            child: const Text(
              'NOT ALL ARE SCAMS! Learn to identify both threats AND legitimate messages.',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: researchScenarios.length,
              itemBuilder: (context, index) {
                final scenario = researchScenarios[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  color: index % 2 == 0 ? Colors.white : Colors.grey[50],
                  child: ListTile(
                    title: Text(
                      scenario['title'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${scenario['platform']} • "${scenario['firstMessage'].toString().substring(0, scenario['firstMessage'].toString().length > 30 ? 30 : scenario['firstMessage'].toString().length)}..."'),
                        const SizedBox(height: 4),
                        Text(
                          'Victim: ${scenario['victimStory']}',
                          style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.red),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: scenario['isScam'] ? Colors.red[100] : Colors.green[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            scenario['isScam'] ? 'SCAM' : 'LEGITIMATE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: scenario['isScam'] ? Colors.red[800] : Colors.green[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => InteractiveResearchScenario(
                            scenario: scenario,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}