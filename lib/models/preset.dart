class Meal {
  final String name;
  final String detail;
  final String? imageUrl; // Added for the card
  final String category;

  const Meal({
    required this.name,
    required this.detail,
    this.imageUrl,
    required this.category,
  });

  // Convert Firestore data to Meal object
  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      name: json['name'] as String,
      detail: json['detail'] as String,
      imageUrl: json['imageUrl'] as String?,
      category: json['category'] as String,
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

// Mutable list so custom presets can be added at runtime
final List<Preset> mockPresets = [
  Preset(
    id: '1',
    title: 'Budget Bites',
    meals: [
      Meal(name: 'Ramen', detail: 'Cheap and classic.', category: 'Budget'),
      Meal(
        name: 'Toasties',
        detail: 'Cheese and bread, can\'t go wrong.',
        category: 'Budget',
      ),
      Meal(
        name: 'Rice & Beans',
        detail: 'The bulk-buy king.',
        category: 'Budget',
      ),
    ],
    description: 'Carbohydrate meal',
    category: 'Budget',
    imageUrl: 'https://images.unsplash.com/photo-1584622181563-430f63602d4b?w=500&h=500&fit=crop',
  ),
  Preset(
    id: '2',
    title: 'Noodles Menu',
    meals: [
      Meal(
        name: 'Pad Thai',
        detail: 'Stir-fried rice noodles with tamarind sauce.',
        category: 'Noodles',
      ),
      Meal(
        name: 'Spaghetti Carbonara',
        detail: 'Creamy pasta with bacon and parmesan.',
        category: 'Noodles',
      ),
      Meal(
        name: 'Yakisoba',
        detail: 'Japanese stir-fried noodles with vegetables.',
        category: 'Noodles',
      ),
    ],
    description: 'Noodle dishes from around the world',
    category: 'Noodles',
    imageUrl: 'https://www.kitchensanctuary.com/wp-content/uploads/2024/03/Sesame-Noodles-tall-FS.jpg',
  ),
];
