class MeditationModel {
  final String id;
  final String title;
  final String description;
  final String category; // 'breathing', 'mindfulness', 'sleep', 'stress', etc.
  final int duration; // Duration in minutes
  final String? audioUrl; // URL to audio file
  final String? imageUrl; // Background image
  final String instructor; // Instructor name
  final List<String> tags;
  final int difficulty; // 1-3 (beginner, intermediate, advanced)
  final String script; // Text script for the meditation
  final bool isPremium;
  final int popularity; // Number of times completed
  final double averageRating;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;

  MeditationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.duration,
    this.audioUrl,
    this.imageUrl,
    required this.instructor,
    this.tags = const [],
    this.difficulty = 1,
    required this.script,
    this.isPremium = false,
    this.popularity = 0,
    this.averageRating = 0.0,
    required this.createdAt,
    this.metadata = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'duration': duration,
      'audioUrl': audioUrl,
      'imageUrl': imageUrl,
      'instructor': instructor,
      'tags': tags,
      'difficulty': difficulty,
      'script': script,
      'isPremium': isPremium,
      'popularity': popularity,
      'averageRating': averageRating,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'metadata': metadata,
    };
  }

  factory MeditationModel.fromMap(Map<String, dynamic> map) {
    return MeditationModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      duration: map['duration'] ?? 0,
      audioUrl: map['audioUrl'],
      imageUrl: map['imageUrl'],
      instructor: map['instructor'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      difficulty: map['difficulty'] ?? 1,
      script: map['script'] ?? '',
      isPremium: map['isPremium'] ?? false,
      popularity: map['popularity'] ?? 0,
      averageRating: (map['averageRating'] ?? 0.0).toDouble(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  MeditationModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    int? duration,
    String? audioUrl,
    String? imageUrl,
    String? instructor,
    List<String>? tags,
    int? difficulty,
    String? script,
    bool? isPremium,
    int? popularity,
    double? averageRating,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return MeditationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      duration: duration ?? this.duration,
      audioUrl: audioUrl ?? this.audioUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      instructor: instructor ?? this.instructor,
      tags: tags ?? this.tags,
      difficulty: difficulty ?? this.difficulty,
      script: script ?? this.script,
      isPremium: isPremium ?? this.isPremium,
      popularity: popularity ?? this.popularity,
      averageRating: averageRating ?? this.averageRating,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }

  String get formattedDuration {
    if (duration < 60) {
      return '${duration}m';
    } else {
      final hours = duration ~/ 60;
      final minutes = duration % 60;
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    }
  }

  String get difficultyLabel {
    switch (difficulty) {
      case 1:
        return 'Beginner';
      case 2:
        return 'Intermediate';
      case 3:
        return 'Advanced';
      default:
        return 'Unknown';
    }
  }
}

class MeditationSession {
  final String id;
  final String userId;
  final String meditationId;
  final DateTime startTime;
  final DateTime? endTime;
  final int plannedDuration; // in minutes
  final int actualDuration; // in minutes
  final bool completed;
  final double? rating; // User rating 1-5
  final String? feedback;
  final Map<String, dynamic> sessionData;

  MeditationSession({
    required this.id,
    required this.userId,
    required this.meditationId,
    required this.startTime,
    this.endTime,
    required this.plannedDuration,
    this.actualDuration = 0,
    this.completed = false,
    this.rating,
    this.feedback,
    this.sessionData = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'meditationId': meditationId,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime?.millisecondsSinceEpoch,
      'plannedDuration': plannedDuration,
      'actualDuration': actualDuration,
      'completed': completed,
      'rating': rating,
      'feedback': feedback,
      'sessionData': sessionData,
    };
  }

  factory MeditationSession.fromMap(Map<String, dynamic> map) {
    return MeditationSession(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      meditationId: map['meditationId'] ?? '',
      startTime: DateTime.fromMillisecondsSinceEpoch(map['startTime'] ?? 0),
      endTime: map['endTime'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['endTime']) 
          : null,
      plannedDuration: map['plannedDuration'] ?? 0,
      actualDuration: map['actualDuration'] ?? 0,
      completed: map['completed'] ?? false,
      rating: map['rating']?.toDouble(),
      feedback: map['feedback'],
      sessionData: Map<String, dynamic>.from(map['sessionData'] ?? {}),
    );
  }

  MeditationSession copyWith({
    String? id,
    String? userId,
    String? meditationId,
    DateTime? startTime,
    DateTime? endTime,
    int? plannedDuration,
    int? actualDuration,
    bool? completed,
    double? rating,
    String? feedback,
    Map<String, dynamic>? sessionData,
  }) {
    return MeditationSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      meditationId: meditationId ?? this.meditationId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      plannedDuration: plannedDuration ?? this.plannedDuration,
      actualDuration: actualDuration ?? this.actualDuration,
      completed: completed ?? this.completed,
      rating: rating ?? this.rating,
      feedback: feedback ?? this.feedback,
      sessionData: sessionData ?? this.sessionData,
    );
  }
  
  bool get isCompleted => completed;
}

// Enhanced meditation content model for YouTube integration
class MeditationContent {
  final String id;
  final String title;
  final String description;
  final String category;
  final int duration; // Duration in minutes
  final MeditationType type;
  final String instructor;
  final String? youtubeId; // YouTube video ID
  final String? thumbnailUrl;
  final String? audioUrl; // Alternative audio URL
  final String difficulty;
  final double rating;
  final List<String> tags;
  final bool isPremium;
  final DateTime? createdAt;

  MeditationContent({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.duration,
    required this.type,
    required this.instructor,
    this.youtubeId,
    this.thumbnailUrl,
    this.audioUrl,
    required this.difficulty,
    required this.rating,
    this.tags = const [],
    this.isPremium = false,
    this.createdAt,
  });
  
  String get youtubeUrl => youtubeId != null ? 'https://www.youtube.com/watch?v=$youtubeId' : '';
  
  String get embedUrl => youtubeId != null ? 'https://www.youtube.com/embed/$youtubeId' : '';
}

enum MeditationType {
  guided,
  silent,
  sleep,
  breathing,
  music,
}
