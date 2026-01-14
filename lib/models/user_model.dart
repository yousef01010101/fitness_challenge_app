class UserModel {
  final String id;
  final String name;
  final String email;
  final String? profileImageUrl; 
  
  // 🕒 بيانات وصفية (Metadata) - مطلوب للتقييم
  final DateTime createdAt;
  final DateTime lastModified;

  // 📊 إحصائيات وسمات (Stats & Attributes) - مطلوب للتقييم
  final int challengesCompleted;
  final int currentStreak; // عدد الأيام المتتالية
  final int totalPoints;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageUrl,
    required this.createdAt,
    required this.lastModified,
    this.challengesCompleted = 0,
    this.currentStreak = 0,
    this.totalPoints = 0,
  });

  // 1️⃣ تحويل البيانات لـ JSON (لإرسالها لـ Firebase لاحقاً)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.toIso8601String(),
      'lastModified': lastModified.toIso8601String(),
      'challengesCompleted': challengesCompleted,
      'currentStreak': currentStreak,
      'totalPoints': totalPoints,
    };
  }

  // 2️⃣ قراءة البيانات من JSON (عند استلامها من Firebase)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? 'Unknown User',
      email: map['email'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      
     
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
      lastModified: map['lastModified'] != null 
          ? DateTime.parse(map['lastModified']) 
          : DateTime.now(),
          
      challengesCompleted: map['challengesCompleted']?.toInt() ?? 0,
      currentStreak: map['currentStreak']?.toInt() ?? 0,
      totalPoints: map['totalPoints']?.toInt() ?? 0,
    );
  }
  

  factory UserModel.empty() {
    return UserModel(
      id: '',
      name: '',
      email: '',
      createdAt: DateTime.now(),
      lastModified: DateTime.now(),
    );
  }
}