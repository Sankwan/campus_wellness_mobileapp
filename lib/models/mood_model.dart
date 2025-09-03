class MoodModel {
  final String id;
  final String userId;
  final String moodType; // 'happy', 'content', 'neutral', 'sad', 'depressed'
  final String emoji;
  final int moodValue; // 1-5 scale
  final String? note;
  final List<String> tags; // 'work', 'relationships', 'health', etc.
  final DateTime timestamp;
  final Map<String, dynamic> additionalData;

  MoodModel({
    required this.id,
    required this.userId,
    required this.moodType,
    required this.emoji,
    required this.moodValue,
    this.note,
    this.tags = const [],
    required this.timestamp,
    this.additionalData = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'moodType': moodType,
      'emoji': emoji,
      'moodValue': moodValue,
      'note': note,
      'tags': tags,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'additionalData': additionalData,
    };
  }

  factory MoodModel.fromMap(Map<String, dynamic> map) {
    return MoodModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      moodType: map['moodType'] ?? '',
      emoji: map['emoji'] ?? '',
      moodValue: map['moodValue'] ?? 3,
      note: map['note'],
      tags: List<String>.from(map['tags'] ?? []),
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      additionalData: Map<String, dynamic>.from(map['additionalData'] ?? {}),
    );
  }

  MoodModel copyWith({
    String? id,
    String? userId,
    String? moodType,
    String? emoji,
    int? moodValue,
    String? note,
    List<String>? tags,
    DateTime? timestamp,
    Map<String, dynamic>? additionalData,
  }) {
    return MoodModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      moodType: moodType ?? this.moodType,
      emoji: emoji ?? this.emoji,
      moodValue: moodValue ?? this.moodValue,
      note: note ?? this.note,
      tags: tags ?? this.tags,
      timestamp: timestamp ?? this.timestamp,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  // Helper method to get mood color
  String get moodColor {
    switch (moodValue) {
      case 1:
        return '#FF6B6B'; // Red for very sad
      case 2:
        return '#FFA726'; // Orange for sad
      case 3:
        return '#FFEB3B'; // Yellow for neutral
      case 4:
        return '#66BB6A'; // Light green for happy
      case 5:
        return '#4CAF50'; // Green for very happy
      default:
        return '#9E9E9E'; // Gray for unknown
    }
  }

  // Helper method to get mood description
  String get moodDescription {
    switch (moodType.toLowerCase()) {
      case 'happy':
        return 'Feeling great!';
      case 'content':
        return 'Feeling good';
      case 'neutral':
        return 'Feeling okay';
      case 'sad':
        return 'Feeling down';
      case 'depressed':
        return 'Feeling very low';
      default:
        return 'Unknown mood';
    }
  }
}
