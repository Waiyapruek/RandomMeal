class Meal {
  final String name;
  final String? detail;
  final String? imageUrl; // Added for the card
  final String category;

  const Meal({
    required this.name,
    this.detail,
    this.imageUrl,
    required this.category,
  });

  // Convert Firestore data to Meal object
  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      name: json['name'] as String? ?? 'Unknown',
      detail: json['detail'] as String?,
      imageUrl: json['imageUrl'] as String?,
      category: json['category'] as String? ?? 'Uncategorized',
    );
  }

  // Convert Meal object to Firestore data
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'detail': detail,
      'imageUrl': imageUrl,
      'category': category,
    };
  }
}

// Update our Preset model to include meals
class Preset {
  final String id;
  final String title;
  final List<Meal> meals;
  final String description;
  final String category;
  final String? imageUrl;

  const Preset({
    required this.id,
    required this.title,
    required this.meals,
    required this.description,
    required this.category,
    this.imageUrl,
  });

  // Convert Firestore data to Preset object
  factory Preset.fromJson(String id, Map<String, dynamic> json) {
    return Preset(
      id: id,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      imageUrl: json['imageUrl'] as String?,
      meals: ((json['meals'] as List<dynamic>?) ?? [])
          .map((meal) => Meal.fromJson(meal as Map<String, dynamic>))
          .toList(),
    );
  }

  // Convert Preset object to Firestore data
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'imageUrl': imageUrl,
      'meals': meals.map((meal) => meal.toJson()).toList(),
    };
  }
}
