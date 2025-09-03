class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final List<String> goals; // e.g., ['stress_relief', 'better_sleep', 'anxiety_management']
  final Map<String, dynamic> preferences;
  final int currentStreak;
  final int totalMeditations;
  final int totalJournalEntries;
  final List<String> achievements;
  final Map<String, int> weeklyGoals;
  final bool isDarkMode;
  final bool notificationsEnabled;
  final String timeZone;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.createdAt,
    required this.lastLoginAt,
    this.goals = const [],
    this.preferences = const {},
    this.currentStreak = 0,
    this.totalMeditations = 0,
    this.totalJournalEntries = 0,
    this.achievements = const [],
    this.weeklyGoals = const {},
    this.isDarkMode = false,
    this.notificationsEnabled = true,
    this.timeZone = 'UTC',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastLoginAt': lastLoginAt.millisecondsSinceEpoch,
      'goals': goals,
      'preferences': preferences,
      'currentStreak': currentStreak,
      'totalMeditations': totalMeditations,
      'totalJournalEntries': totalJournalEntries,
      'achievements': achievements,
      'weeklyGoals': weeklyGoals,
      'isDarkMode': isDarkMode,
      'notificationsEnabled': notificationsEnabled,
      'timeZone': timeZone,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      photoUrl: map['photoUrl'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      lastLoginAt: DateTime.fromMillisecondsSinceEpoch(map['lastLoginAt'] ?? 0),
      goals: List<String>.from(map['goals'] ?? []),
      preferences: Map<String, dynamic>.from(map['preferences'] ?? {}),
      currentStreak: map['currentStreak'] ?? 0,
      totalMeditations: map['totalMeditations'] ?? 0,
      totalJournalEntries: map['totalJournalEntries'] ?? 0,
      achievements: List<String>.from(map['achievements'] ?? []),
      weeklyGoals: Map<String, int>.from(map['weeklyGoals'] ?? {}),
      isDarkMode: map['isDarkMode'] ?? false,
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      timeZone: map['timeZone'] ?? 'UTC',
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    List<String>? goals,
    Map<String, dynamic>? preferences,
    int? currentStreak,
    int? totalMeditations,
    int? totalJournalEntries,
    List<String>? achievements,
    Map<String, int>? weeklyGoals,
    bool? isDarkMode,
    bool? notificationsEnabled,
    String? timeZone,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      goals: goals ?? this.goals,
      preferences: preferences ?? this.preferences,
      currentStreak: currentStreak ?? this.currentStreak,
      totalMeditations: totalMeditations ?? this.totalMeditations,
      totalJournalEntries: totalJournalEntries ?? this.totalJournalEntries,
      achievements: achievements ?? this.achievements,
      weeklyGoals: weeklyGoals ?? this.weeklyGoals,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      timeZone: timeZone ?? this.timeZone,
    );
  }
}
