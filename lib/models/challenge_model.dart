enum ChallengeDifficulty { easy, medium, hard }

class ChallengeModel {
  // --- 1. Basic Info (معلومات أساسية) ---
  final String id;
  final String title;        // يقابل Name
  final String description;  // يقابل Description
  final String? imageUrl;    // ✅ يقابل Image (تمت إضافته)

  // --- 2. Attributes (السمات والمهارات) ---
  final String exerciseType; // يقابل Skill (نوع التمرين: ركض، سباحة...)
  final List<String> tags;   // ✅ يقابل Skills (مثال: ["Cardio", "Legs", "Stamina"])
  final int goalValue;       // يقابل Stats (القيمة الرقمية)
  final String unit;         // يقابل Stats (الوحدة)
  final ChallengeDifficulty difficulty; // يقابل Stats (مستوى الصعوبة)
  final List<String> participantIds;


  final DateTime startDate;
  final DateTime createdAt;  
  final DateTime lastModified; 

  ChallengeModel({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.exerciseType,
    this.tags = const [], // قائمة فارغة افتراضياً
    required this.goalValue,
    required this.unit,
    required this.difficulty,
    required this.participantIds,
    required this.startDate,
    required this.createdAt,
    required this.lastModified,
  });

  // --- 4. JSON Serialization (التحويل لـ JSON) ---
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'exerciseType': exerciseType,
      'tags': tags, // حفظ القائمة
      'goalValue': goalValue,
      'unit': unit,
      'difficulty': difficulty.name,
      'participantIds': participantIds,
      'startDate': startDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'lastModified': lastModified.toIso8601String(),
    };
  }

  // --- 5. JSON Deserialization (القراءة من JSON) ---
  factory ChallengeModel.fromMap(Map<String, dynamic> map) {
    return ChallengeModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'],
      exerciseType: map['exerciseType'] ?? 'General',
      tags: List<String>.from(map['tags'] ?? []), // استرجاع القائمة
      goalValue: map['goalValue']?.toInt() ?? 0,
      unit: map['unit'] ?? '',
      difficulty: ChallengeDifficulty.values.firstWhere(
        (e) => e.name == map['difficulty'],
        orElse: () => ChallengeDifficulty.medium,
      ),
      participantIds: List<String>.from(map['participantIds'] ?? []),
      startDate: DateTime.parse(map['startDate']),
      createdAt: DateTime.parse(map['createdAt']),
      lastModified: map['lastModified'] != null 
          ? DateTime.parse(map['lastModified']) 
          : DateTime.parse(map['createdAt']),
    );
  }
}