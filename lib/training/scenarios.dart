
class TrainingScenario {
  final String id;
  final String title;
  final String description;
  final List<ScenarioChoice> choices;
  final List<RecallQuestion> recallQuestions;

  TrainingScenario({
    required this.id,
    required this.title,
    required this.description,
    required this.choices,
    required this.recallQuestions,
  });
}

class ScenarioChoice {
  final String id;
  final String text;
  final ChoiceFeedback feedback;

  ScenarioChoice({
    required this.id,
    required this.text,
    required this.feedback,
  });
}

class ChoiceFeedback {
  final bool isCorrect;
  final String title;
  final String explanation;

  ChoiceFeedback({
    required this.isCorrect,
    required this.title,
    required this.explanation,
  });
}

class RecallQuestion {
  final String id;
  final String question;
  final List<RecallAnswer> answers;
  final String correctAnswerId;

  RecallQuestion({
    required this.id,
    required this.question,
    required this.answers,
    required this.correctAnswerId,
  });
}

class RecallAnswer {
  final String id;
  final String text;

  RecallAnswer({
    required this.id,
    required this.text,
  });
}

final trainingScenarios = [
  TrainingScenario(
    id: 'courier_duty',
    title: 'Courier Duty Scam',
    description: 'You receive an unexpected message about a package delivery.',
    choices: [
      ScenarioChoice(
        id: 'pay_fee',
        text: 'Pay the customs fee to receive the package.',
        feedback: ChoiceFeedback(
          isCorrect: false,
          title: 'Incorrect',
          explanation: 'Legitimate couriers will not ask for payment via a link in a text message.',
        ),
      ),
      ScenarioChoice(
        id: 'ignore',
        text: 'Ignore the message.',
        feedback: ChoiceFeedback(
          isCorrect: true,
          title: 'Correct',
          explanation: 'This is likely a phishing attempt. Do not click on suspicious links.',
        ),
      ),
    ],
    recallQuestions: [
      RecallQuestion(
        id: 'q1',
        question: 'What is a common sign of a courier scam?',
        answers: [
          RecallAnswer(id: 'a1', text: 'A request for payment via a link.'),
          RecallAnswer(id: 'a2', text: 'A tracking number.'),
        ],
        correctAnswerId: 'a1',
      ),
    ],
  ),
  TrainingScenario(
    id: 'bank_kyc',
    title: 'Bank KYC Scam',
    description: 'You receive an email from your bank asking you to update your KYC information.',
    choices: [
      ScenarioChoice(
        id: 'click_link',
        text: 'Click the link in the email to update your information.',
        feedback: ChoiceFeedback(
          isCorrect: false,
          title: 'Incorrect',
          explanation: 'Never click on links in unsolicited emails. Always go to the bank\'s website directly.',
        ),
      ),
      ScenarioChoice(
        id: 'call_bank',
        text: 'Call your bank to verify the request.',
        feedback: ChoiceFeedback(
          isCorrect: true,
          title: 'Correct',
          explanation: 'Always verify requests with your bank through official channels.',
        ),
      ),
    ],
    recallQuestions: [
      RecallQuestion(
        id: 'q1',
        question: 'What is the safest way to respond to a request from your bank?',
        answers: [
          RecallAnswer(id: 'a1', text: 'Click the link in the email.'),
          RecallAnswer(id: 'a2', text: 'Call the bank using the number on their official website.'),
        ],
        correctAnswerId: 'a2',
      ),
    ],
  ),
  TrainingScenario(
    id: 'gift_card',
    title: 'Gift Card Scam',
    description: 'Your boss asks you to buy gift cards for a client and send them the codes.',
    choices: [
      ScenarioChoice(
        id: 'buy_cards',
        text: 'Buy the gift cards and send the codes to your boss.',
        feedback: ChoiceFeedback(
          isCorrect: false,
          title: 'Incorrect',
          explanation: 'Gift cards are a common method for scams because they are hard to trace. Verify the request in person or by phone.',
        ),
      ),
      ScenarioChoice(
        id: 'verify_request',
        text: 'Verify the request with your boss in person or by phone.',
        feedback: ChoiceFeedback(
          isCorrect: true,
          title: 'Correct',
          explanation: 'Always verify unusual requests, especially those involving money or gift cards.',
        ),
      ),
    ],
    recallQuestions: [
      RecallQuestion(
        id: 'q1',
        question: 'Why are gift cards a common method for scams?',
        answers: [
          RecallAnswer(id: 'a1', text: 'They are easy to buy.'),
          RecallAnswer(id: 'a2', text: 'They are hard to trace.'),
        ],
        correctAnswerId: 'a2',
      ),
    ],
  ),
  TrainingScenario(
    id: 'crypto_lure',
    title: 'Crypto Lure Scam',
    description: 'You see an online ad promising guaranteed high returns on a new cryptocurrency.',
    choices: [
      ScenarioChoice(
        id: 'invest',
        text: 'Invest your money for guaranteed high returns.',
        feedback: ChoiceFeedback(
          isCorrect: false,
          title: 'Incorrect',
          explanation: 'Guaranteed high returns are a huge red flag. All investments carry risk.',
        ),
      ),
      ScenarioChoice(
        id: 'research',
        text: 'Research the cryptocurrency and the platform thoroughly before investing.',
        feedback: ChoiceFeedback(
          isCorrect: true,
          title: 'Correct',
          explanation: 'Always do your own research and be skeptical of promises of guaranteed returns.',
        ),
      ),
    ],
    recallQuestions: [
      RecallQuestion(
        id: 'q1',
        question: 'What is a major red flag in investment opportunities?',
        answers: [
          RecallAnswer(id: 'a1', text: 'Guaranteed high returns.'),
          RecallAnswer(id: 'a2', text: 'Use of blockchain technology.'),
        ],
        correctAnswerId: 'a1',
      ),
    ],
  ),
  TrainingScenario(
    id: 'qr_quishing',
    title: 'QR Quishing Scam',
    description: 'You see a QR code in a public place offering a discount on a popular product.',
    choices: [
      ScenarioChoice(
        id: 'scan_code',
        text: 'Scan the QR code to get the discount.',
        feedback: ChoiceFeedback(
          isCorrect: false,
          title: 'Incorrect',
          explanation: 'Malicious QR codes can lead to phishing websites or malware. Be cautious of QR codes in public places.',
        ),
      ),
      ScenarioChoice(
        id: 'ignore_code',
        text: 'Ignore the QR code.',
        feedback: ChoiceFeedback(
          isCorrect: true,
          title: 'Correct',
          explanation: 'It is best to be cautious and not scan QR codes from unknown sources.',
        ),
      ),
    ],
    recallQuestions: [
      RecallQuestion(
        id: 'q1',
        question: 'What is a potential danger of scanning QR codes in public places?',
        answers: [
          RecallAnswer(id: 'a1', text: 'They can lead to phishing websites or malware.'),
          RecallAnswer(id: 'a2', text: 'They can drain your phone battery.'),
        ],
        correctAnswerId: 'a1',
      ),
    ],
  ),
];
