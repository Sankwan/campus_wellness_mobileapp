class JournalModel {
  final String id;
  final String userId;
  final String title;
  final String content;
  final String? prompt; // Optional prompt that inspired the entry
  final List<String> emotions; // Tags for emotions felt during writing
  final List<String> tags; // General tags like 'gratitude', 'reflection', etc.
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isPrivate;
  final int moodRating; // 1-5 mood rating at time of writing
  final String? imageUrl; // Optional image attachment
  final Map<String, dynamic> metadata; // Additional data like word count, etc.

  JournalModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    this.prompt,
    this.emotions = const [],
    this.tags = const [],
    required this.createdAt,
    this.updatedAt,
    this.isPrivate = true,
    this.moodRating = 3,
    this.imageUrl,
    this.metadata = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'content': content,
      'prompt': prompt,
      'emotions': emotions,
      'tags': tags,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'isPrivate': isPrivate,
      'moodRating': moodRating,
      'imageUrl': imageUrl,
      'metadata': metadata,
    };
  }

  factory JournalModel.fromMap(Map<String, dynamic> map) {
    return JournalModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      prompt: map['prompt'],
      emotions: List<String>.from(map['emotions'] ?? []),
      tags: List<String>.from(map['tags'] ?? []),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt']) 
          : null,
      isPrivate: map['isPrivate'] ?? true,
      moodRating: map['moodRating'] ?? 3,
      imageUrl: map['imageUrl'],
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  JournalModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    String? prompt,
    List<String>? emotions,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPrivate,
    int? moodRating,
    String? imageUrl,
    Map<String, dynamic>? metadata,
  }) {
    return JournalModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      prompt: prompt ?? this.prompt,
      emotions: emotions ?? this.emotions,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPrivate: isPrivate ?? this.isPrivate,
      moodRating: moodRating ?? this.moodRating,
      imageUrl: imageUrl ?? this.imageUrl,
      metadata: metadata ?? this.metadata,
    );
  }

  // Helper methods
  int get wordCount => content.split(' ').where((word) => word.isNotEmpty).length;
  
  Duration get readingTime {
    const wordsPerMinute = 200;
    final minutes = (wordCount / wordsPerMinute).ceil();
    return Duration(minutes: minutes);
  }

  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final entryDate = DateTime(createdAt.year, createdAt.month, createdAt.day);

    if (entryDate == today) {
      return 'Today';
    } else if (entryDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  String get preview {
    if (content.length <= 100) return content;
    return '${content.substring(0, 100)}...';
  }
}

// Journal prompts for inspiration
class JournalPrompts {
  static const List<Map<String, String>> dailyPrompts = [
    {
      'category': 'Gratitude',
      'prompt': 'What are three things you\'re grateful for today?',
    },
    {
      'category': 'Reflection',
      'prompt': 'How did you grow or learn something new today?',
    },
    {
      'category': 'Mindfulness',
      'prompt': 'Describe a moment today when you felt fully present.',
    },
    {
      'category': 'Goals',
      'prompt': 'What small step can you take tomorrow toward a goal that matters to you?',
    },
    {
      'category': 'Relationships',
      'prompt': 'How did you connect with someone meaningful today?',
    },
    {
      'category': 'Self-care',
      'prompt': 'What did you do today to take care of yourself?',
    },
    {
      'category': 'Challenges',
      'prompt': 'What challenge did you face today, and how did you handle it?',
    },
    {
      'category': 'Joy',
      'prompt': 'What brought you joy or made you smile today?',
    },
    {
      'category': 'Future',
      'prompt': 'What are you looking forward to in the near future?',
    },
    {
      'category': 'Values',
      'prompt': 'How did your actions today align with your core values?',
    },
  ];

  static String getRandomPrompt() {
    final random = DateTime.now().millisecondsSinceEpoch % dailyPrompts.length;
    return dailyPrompts[random]['prompt']!;
  }

  static Map<String, String> getRandomPromptWithCategory() {
    final random = DateTime.now().millisecondsSinceEpoch % dailyPrompts.length;
    return dailyPrompts[random];
  }
}
