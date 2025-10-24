class JournalEntry {
  final DateTime date;
  final int mood;
  final String note;

  JournalEntry({
    required this.date,
    required this.mood,
    required this.note,
  });

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      date: DateTime.parse(json['date'] ?? ''),
      mood: json['mood']?.toInt() ?? 3,
      note: json['note']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String().split('T')[0],
      'mood': mood,
      'note': note,
    };
  }
}
