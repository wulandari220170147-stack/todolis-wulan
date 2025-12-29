class TaskModel {
  int? id;
  String title;
  String? description;
  int categoryId;
  int userId;
  String priority;
  String? deadline;
  int isCompleted;
  String? createdAt;

  TaskModel({
    this.id,
    required this.title,
    this.description,
    required this.categoryId,
    required this.userId,
    this.priority = 'Rendah',
    this.deadline,
    this.isCompleted = 0,
    this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'category_id': categoryId,
        'user_id': userId,
        'priority': priority,
        'deadline': deadline,
        'is_completed': isCompleted,
        'created_at': createdAt,
      };

  factory TaskModel.fromMap(Map<String, dynamic> m) => TaskModel(
        id: m['id'],
        title: m['title'],
        description: m['description'],
        categoryId: m['category_id'],
        userId: m['user_id'],
        priority: m['priority'] ?? 'Rendah',
        deadline: m['deadline'],
        isCompleted: m['is_completed'] ?? 0,
        createdAt: m['created_at'],
      );

  bool get isOverdue {
    if (deadline == null) return false;
    final deadlineDate = DateTime.parse(deadline!);
    final now = DateTime.now();
    return deadlineDate.isBefore(DateTime(now.year, now.month, now.day)) &&
        isCompleted == 0;
  }
}