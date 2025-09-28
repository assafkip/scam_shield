import 'package:flutter/material.dart';
import '../models/scenario.dart';
import '../models/conversation.dart';

class PlatformAuthenticChat extends StatelessWidget {
  final Scenario scenario;
  final List<ConversationMessage> messages;
  final List<ConversationChoice> choices;
  final Function(ConversationChoice) onChoiceSelected;

  const PlatformAuthenticChat({
    Key? key,
    required this.scenario,
    required this.messages,
    required this.choices,
    required this.onChoiceSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    try {
      print('=== PlatformAuthenticChat BUILD ===');
      print('Scenario platform: ${scenario.platform}');
      print('Messages count: ${messages.length}');
      print('Choices count: ${choices.length}');

      // Add null safety checks
      if (scenario.platform == null) {
        print('🚨 ERROR: Scenario platform is null');
        return _buildErrorFallback(context, 'Invalid platform');
      }

      switch (scenario.platform) {
        case 'whatsapp':
          print('✅ Building WhatsApp interface');
          return WhatsAppChatInterface(
            scenario: scenario,
            messages: messages,
            choices: choices,
            onChoiceSelected: onChoiceSelected,
          );
        case 'email':
          print('✅ Building Email interface');
          return EmailInterface(
            scenario: scenario,
            messages: messages,
            choices: choices,
            onChoiceSelected: onChoiceSelected,
          );
        case 'sms':
          print('✅ Building SMS interface');
          return SMSInterface(
            scenario: scenario,
            messages: messages,
            choices: choices,
            onChoiceSelected: onChoiceSelected,
          );
        case 'tinder':
          print('✅ Building Tinder interface');
          return TinderInterface(
            scenario: scenario,
            messages: messages,
            choices: choices,
            onChoiceSelected: onChoiceSelected,
          );
        default:
          print('⚠️ Using generic interface for platform: ${scenario.platform}');
          return GenericChatInterface(
            scenario: scenario,
            messages: messages,
            choices: choices,
            onChoiceSelected: onChoiceSelected,
          );
      }
    } catch (e, stackTrace) {
      print('🚨 ERROR in PlatformAuthenticChat build: $e');
      print('🚨 Stack trace: $stackTrace');
      return _buildErrorFallback(context, e.toString());
    }
  }

  Widget _buildErrorFallback(BuildContext context, String error) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Error'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.chat_bubble_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Chat Interface Error',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

class WhatsAppChatInterface extends StatelessWidget {
  final Scenario scenario;
  final List<ConversationMessage> messages;
  final List<ConversationChoice> choices;
  final Function(ConversationChoice) onChoiceSelected;

  const WhatsAppChatInterface({
    Key? key,
    required this.scenario,
    required this.messages,
    required this.choices,
    required this.onChoiceSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    try {
      print('=== WhatsAppChatInterface BUILD ===');
      print('WhatsApp messages: ${messages.length}');
      print('WhatsApp choices: ${choices.length}');

      return Scaffold(
        backgroundColor: const Color(0xFFECE5DD), // WhatsApp background
        appBar: _buildWhatsAppAppBar(),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/whatsapp_bg.png'),
                  repeat: ImageRepeat.repeat,
                  opacity: 0.06,
                ),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return _buildWhatsAppMessage(messages[index]);
                },
              ),
            ),
          ),
          if (choices.isNotEmpty) _buildWhatsAppChoices(),
        ],
      ),
    );
    } catch (e, stackTrace) {
      print('🚨 ERROR in WhatsAppChatInterface: $e');
      print('🚨 Stack trace: $stackTrace');
      return Scaffold(
        appBar: AppBar(
          title: const Text('WhatsApp Error'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('WhatsApp Interface Error'),
              Text('Error: ${e.toString()}'),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }
  }

  PreferredSizeWidget _buildWhatsAppAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF075E54),
      elevation: 0,
      leading: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      leadingWidth: 40,
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey.shade400,
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getScammerName(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Text(
                  'online',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.videocam, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.call, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildWhatsAppMessage(ConversationMessage message) {
    final isUser = !message.isFromScammer;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) const SizedBox(width: 8),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: 300,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isUser ? const Color(0xFFDCF8C6) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (isUser) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.done_all,
                          size: 14,
                          color: Colors.blue.shade400,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildWhatsAppChoices() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFFF0F0F0),
        border: Border(
          top: BorderSide(color: Colors.grey, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Quick Reply',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          ...choices.map((choice) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: ElevatedButton(
              onPressed: () => onChoiceSelected(choice),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF075E54),
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Color(0xFF075E54), width: 1),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              ),
              child: Text(
                choice.buttonText,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          )),
        ],
      ),
    );
  }

  String _getScammerName() {
    switch (scenario.id) {
      case 'rom_001':
        return 'Sean Rad';
      case 'friend_001':
        return 'Sarah Wilson';
      default:
        return messages.isNotEmpty ? messages.first.from : 'Contact';
    }
  }
}

class EmailInterface extends StatelessWidget {
  final Scenario scenario;
  final List<ConversationMessage> messages;
  final List<ConversationChoice> choices;
  final Function(ConversationChoice) onChoiceSelected;

  const EmailInterface({
    Key? key,
    required this.scenario,
    required this.messages,
    required this.choices,
    required this.onChoiceSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildEmailAppBar(),
      body: Column(
        children: [
          _buildEmailHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...messages.map((message) => _buildEmailMessage(message)),
                  if (choices.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _buildEmailChoices(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildEmailAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF4285F4),
      title: const Text(
        'Gmail',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildEmailHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF4285F4),
                child: Text(
                  _getScammerInitials(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getScammerName(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _getEmailAddress(),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.star_border, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Icon(Icons.reply, color: Colors.grey.shade600),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _getEmailSubject(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Today 2:34 PM',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailMessage(ConversationMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Text(
        message.text,
        style: const TextStyle(
          fontSize: 16,
          height: 1.5,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildEmailChoices() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Response:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...choices.map((choice) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => onChoiceSelected(choice),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF4285F4),
                  side: const BorderSide(color: Color(0xFF4285F4)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  choice.buttonText,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }

  String _getScammerName() {
    switch (scenario.id) {
      case 'job_001':
        return 'HR Department';
      case 'gov_001':
        return 'IRS Collections';
      case 'tech_001':
        return 'Microsoft Security';
      case 'bank_001':
        return 'Chase Bank Security';
      default:
        return messages.isNotEmpty ? messages.first.from : 'Sender';
    }
  }

  String _getScammerInitials() {
    final name = _getScammerName();
    return name.split(' ').map((word) => word[0]).take(2).join().toUpperCase();
  }

  String _getEmailAddress() {
    switch (scenario.id) {
      case 'job_001':
        return 'hr@company-hiring.com';
      case 'gov_001':
        return 'collections@irs-gov.net';
      case 'tech_001':
        return 'security@microsoft-support.org';
      case 'bank_001':
        return 'security@chase-bank.co';
      default:
        return 'noreply@suspicious-domain.com';
    }
  }

  String _getEmailSubject() {
    switch (scenario.id) {
      case 'job_001':
        return 'URGENT: Job Offer - Start Monday!';
      case 'gov_001':
        return 'FINAL NOTICE - Tax Payment Required';
      case 'tech_001':
        return 'Critical Security Alert - Immediate Action Required';
      case 'bank_001':
        return 'Account Security Alert - Verify Now';
      default:
        return 'Important Message';
    }
  }
}

class SMSInterface extends StatelessWidget {
  final Scenario scenario;
  final List<ConversationMessage> messages;
  final List<ConversationChoice> choices;
  final Function(ConversationChoice) onChoiceSelected;

  const SMSInterface({
    Key? key,
    required this.scenario,
    required this.messages,
    required this.choices,
    required this.onChoiceSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildSMSAppBar(),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return _buildSMSMessage(messages[index]);
              },
            ),
          ),
          if (choices.isNotEmpty) _buildSMSChoices(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildSMSAppBar() {
    return AppBar(
      backgroundColor: Colors.black,
      title: Column(
        children: [
          Text(
            _getPhoneNumber(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Text(
            'Text Message',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.call, color: Colors.blue),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.info_outline, color: Colors.blue),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildSMSMessage(ConversationMessage message) {
    final isUser = !message.isFromScammer;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: 300,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? const Color(0xFF007AFF) : const Color(0xFF3C3C43),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                message.text,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSMSChoices() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Quick Reply',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          ...choices.map((choice) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: ElevatedButton(
              onPressed: () => onChoiceSelected(choice),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3C3C43),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              child: Text(
                choice.buttonText,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          )),
        ],
      ),
    );
  }

  String _getPhoneNumber() {
    switch (scenario.id) {
      case 'pkg_001':
        return '+1 (800) 463-3339'; // FedEx-like number
      default:
        return '+1 (555) 123-4567';
    }
  }
}

class TinderInterface extends StatelessWidget {
  final Scenario scenario;
  final List<ConversationMessage> messages;
  final List<ConversationChoice> choices;
  final Function(ConversationChoice) onChoiceSelected;

  const TinderInterface({
    Key? key,
    required this.scenario,
    required this.messages,
    required this.choices,
    required this.onChoiceSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildTinderAppBar(),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return _buildTinderMessage(messages[index]);
              },
            ),
          ),
          if (choices.isNotEmpty) _buildTinderChoices(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildTinderAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFFF4458), Color(0xFFFF6B7A)],
              ),
            ),
            child: const Icon(
              Icons.favorite,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getMatchName(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Text(
                  'Matched 2 hours ago',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.videocam, color: Color(0xFFFF4458)),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.more_horiz, color: Colors.grey),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildTinderMessage(ConversationMessage message) {
    final isUser = !message.isFromScammer;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFFF4458),
              child: Text(
                _getMatchName()[0],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: 280,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? const Color(0xFFFF4458) : Colors.grey.shade200,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  fontSize: 15,
                  color: isUser ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildTinderChoices() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: choices.map((choice) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ElevatedButton(
            onPressed: () => onChoiceSelected(choice),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4458),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(
              choice.buttonText,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        )).toList(),
      ),
    );
  }

  String _getMatchName() {
    switch (scenario.id) {
      case 'rom_001':
        return 'Sean';
      default:
        return 'Match';
    }
  }
}

class GenericChatInterface extends StatelessWidget {
  final Scenario scenario;
  final List<ConversationMessage> messages;
  final List<ConversationChoice> choices;
  final Function(ConversationChoice) onChoiceSelected;

  const GenericChatInterface({
    Key? key,
    required this.scenario,
    required this.messages,
    required this.choices,
    required this.onChoiceSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${scenario.platform.toUpperCase()} Chat'),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return _buildGenericMessage(messages[index]);
              },
            ),
          ),
          if (choices.isNotEmpty) _buildGenericChoices(),
        ],
      ),
    );
  }

  Widget _buildGenericMessage(ConversationMessage message) {
    final isUser = !message.isFromScammer;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: 300,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? const Color(0xFF2196F3) : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  fontSize: 16,
                  color: isUser ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenericChoices() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: choices.map((choice) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ElevatedButton(
            onPressed: () => onChoiceSelected(choice),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: Text(
              choice.buttonText,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        )).toList(),
      ),
    );
  }
}