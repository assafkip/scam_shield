class Message {
  final String from;
  final String text;
  final int t;

  Message({
    required this.from,
    required this.text,
    required this.t,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      from: json['from'] as String,
      text: json['text'] as String,
      t: json['t'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'from': from,
      'text': text,
      't': t,
    };
  }
}