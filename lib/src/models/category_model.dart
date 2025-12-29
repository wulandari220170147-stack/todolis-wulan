class CategoryModel {
  int? id;
  String name;
  String? description;
  int? userId;

  CategoryModel({
    this.id,
    required this.name,
    this.description,
    this.userId,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'user_id': userId,
      };

  factory CategoryModel.fromMap(Map<String, dynamic> m) => CategoryModel(
        id: m['id'],
        name: m['name'],
        description: m['description'],
        userId: m['user_id'],
      );
}