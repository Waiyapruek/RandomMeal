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
  ),
];
