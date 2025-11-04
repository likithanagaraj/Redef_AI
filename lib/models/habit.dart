
class Habit {
  final String id;
  final String name;
  final String? description;
  final String? type;
  final String? parentId;
  final String userId;
  final DateTime createdAt;
  bool status;
  int streak;

  Habit({
    required this.id,
    required this.name,
    required this.userId,
    required this.createdAt,
    this.description,
    this.type,
    this.parentId,
    this.status = false,
    this.streak =0
  });

  // Copy with method for immutability
  Habit copyWith({
    String? id,
    String? name,
    String? description,
    String? type,
    String? parentId,
    String? userId,
    DateTime? createdAt,
    bool? status,
    int? streak
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      parentId: parentId ?? this.parentId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      streak: streak ?? this.streak,
    );
  }

  // Factory constructor for JSON parsing
  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'No Name',
      description: json['description'] as String?,
      type: json['type'] as String?,
      parentId: json['parent_id'] as String?,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      status: false, // Default status, will be updated from logs
      streak: json['streak'] as int? ?? 0, // optional — no error if absent
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'parent_id': parentId,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() => 'Habit(id: $id, name: $name, status: $status,streak: $streak)';
}

class HabitLog {
  final String id;
  final String habitId;
  final DateTime date;
  final bool status;
  final String userId;
  final DateTime createdAt;

  HabitLog({
    required this.id,
    required this.habitId,
    required this.date,
    required this.status,
    required this.userId,
    required this.createdAt,
  });

  factory HabitLog.fromJson(Map<String, dynamic> json) {
    return HabitLog(
      id: json['id'] as String,
      habitId: json['habit_id'] as String,
      date: DateTime.parse(json['date'] as String),
      status: json['status'] as bool? ?? false,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'habit_id': habitId,
      'date': date.toIso8601String().split('T').first,
      'status': status,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}