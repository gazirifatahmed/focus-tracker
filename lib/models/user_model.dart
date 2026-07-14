class AppUser {
  final String uid;
  final String email;
  final DateTime createdAt;
  final int longestStreak;
  final DateTime? lastRelapse;
  final String? currentBadge;

  AppUser({
    required this.uid,
    required this.email,
    required this.createdAt,
    this.longestStreak = 0,
    this.lastRelapse,
    this.currentBadge,
  });

  // ✅ copyWith
  AppUser copyWith({
    String? uid,
    String? email,
    DateTime? createdAt,
    int? longestStreak,
    DateTime? lastRelapse,
    String? currentBadge,
    bool clearLastRelapse = false,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      longestStreak: longestStreak ?? this.longestStreak,
      lastRelapse: clearLastRelapse ? null : (lastRelapse ?? this.lastRelapse),
      currentBadge: currentBadge ?? this.currentBadge,
    );
  }

  // ✅ uid আলাদা parameter — FirestoreService এর সাথে match
  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    return AppUser(
      uid: uid, // ✅ Firestore doc ID থেকে নেওয়া
      email: map['email'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(), // ✅ null safe
      longestStreak: map['longestStreak'] ?? 0,
      lastRelapse: map['lastRelapse'] != null
          ? DateTime.parse(map['lastRelapse'])
          : null,
      currentBadge: map['currentBadge'],
    );
  }

  // ✅ toMap — uid বাদ (doc ID হিসেবে থাকে)
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'createdAt': createdAt.toIso8601String(),
      'longestStreak': longestStreak,
      'lastRelapse': lastRelapse?.toIso8601String(),
      'currentBadge': currentBadge,
    };
  }
}