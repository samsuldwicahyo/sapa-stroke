class CommunicationHistory {
  const CommunicationHistory({
    required this.buttonId,
    required this.title,
    required this.spokenText,
    required this.timestamp,
  });

  final String buttonId;
  final String title;
  final String spokenText;
  final DateTime timestamp;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'buttonId': buttonId,
      'title': title,
      'spokenText': spokenText,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory CommunicationHistory.fromMap(Map<String, dynamic> map) {
    return CommunicationHistory(
      buttonId: map['buttonId'] as String,
      title: map['title'] as String,
      spokenText: map['spokenText'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }
}
