class Meal {
  final String name;
  final String detail;
  final String? imageUrl; // Added for the card

  const Meal({required this.name, required this.detail, this.imageUrl});
}

// Update our Preset model to include meals
class Preset {
  final String id;
  final String title;
  final List<Meal> meals;
  final String description;

  const Preset({
    required this.id,
    required this.title,
    required this.meals,
    required this.description,
  });
}

// Mock Data
const List<Preset> mockPresets = [
  Preset(
    id: '1',
    title: 'Budget Bites',
    meals: [
      Meal(name: 'Ramen', detail: 'Cheap and classic.'),
      Meal(name: 'Toastie', detail: 'Cheese and bread, can\'t go wrong.'),
      Meal(name: 'Rice & Beans', detail: 'The bulk-buy king.'),
    ],
    description: 'Carbohydrate meal',
  ),
];
