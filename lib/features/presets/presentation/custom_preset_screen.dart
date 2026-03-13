import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/preset.dart';

class CustomPresetScreen extends StatefulWidget {
  const CustomPresetScreen({super.key});

  @override
  State<CustomPresetScreen> createState() => _CustomPresetScreenState();
}

class _CustomPresetScreenState extends State<CustomPresetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _imagePicker = ImagePicker();
  final List<Meal> _meals = [];
  String? _presetImagePath;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _pickPresetImage() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (picked != null) {
      setState(() {
        _presetImagePath = picked.path;
      });
    }
  }

  void _addMeal() {
    final nameController = TextEditingController();
    final detailController = TextEditingController();
    final mealCategoryController = TextEditingController();
    String? mealImagePath;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Add Meal'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Meal image picker
                GestureDetector(
                  onTap: () async {
                    final picked = await _imagePicker.pickImage(
                      source: ImageSource.gallery,
                      maxWidth: 800,
                      maxHeight: 800,
                    );
                    if (picked != null) {
                      setDialogState(() {
                        mealImagePath = picked.path;
                      });
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        dialogContext,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      image: mealImagePath != null
                          ? DecorationImage(
                              image: kIsWeb
                                  ? NetworkImage(mealImagePath!)
                                  : FileImage(File(mealImagePath!))
                                        as ImageProvider,
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: mealImagePath == null
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo, size: 32),
                              SizedBox(height: 4),
                              Text('Add Photo'),
                            ],
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Meal Name',
                    hintText: 'e.g. Spaghetti',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: detailController,
                  decoration: const InputDecoration(
                    labelText: 'Detail',
                    hintText: 'e.g. Classic Italian pasta',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: mealCategoryController,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    hintText: 'e.g. Italian',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  setState(() {
                    _meals.add(
                      Meal(
                        name: nameController.text.trim(),
                        detail: detailController.text.trim(),
                        category: mealCategoryController.text.trim(),
                        imageUrl: mealImagePath,
                      ),
                    );
                  });
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _removeMeal(int index) {
    setState(() {
      _meals.removeAt(index);
    });
  }

  void _savePreset() {
    if (!_formKey.currentState!.validate()) return;

    if (_meals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one meal to the preset.')),
      );
      return;
    }

    final newPreset = Preset(
      id: (Random().nextInt(9000) + 1000).toString(),
      title: _titleController.text.trim(),
      meals: List.unmodifiable(_meals),
      description: _descriptionController.text.trim(),
      category: _categoryController.text.trim(),
      imageUrl: _presetImagePath,
    );

    // TODO: Persist the preset (e.g. via a provider or database)
    // For now, go back to home
    context.pop(newPreset);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Create Preset'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Preset image
            GestureDetector(
              onTap: _pickPresetImage,
              child: Container(
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  image: _presetImagePath != null
                      ? DecorationImage(
                          image: kIsWeb
                              ? NetworkImage(_presetImagePath!)
                              : FileImage(File(_presetImagePath!))
                                    as ImageProvider,
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _presetImagePath == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo,
                            size: 40,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add Preset Photo',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),

            // Preset title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Preset Title',
                hintText: 'e.g. Weeknight Dinners',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'e.g. Quick and easy meals for busy nights',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Category
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Category',
                hintText: 'e.g. Dinner',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a category';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Meals header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Meals (${_meals.length})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                FilledButton.icon(
                  onPressed: _addMeal,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Meal'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Meals list
            if (_meals.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      'No meals added yet.\nTap "Add Meal" to get started.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                ),
              )
            else
              ..._meals.asMap().entries.map((entry) {
                final index = entry.key;
                final meal = entry.value;
                return Card(
                  child: ListTile(
                    leading: meal.imageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: kIsWeb
                                ? Image.network(
                                    meal.imageUrl!,
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    File(meal.imageUrl!),
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                  ),
                          )
                        : const Icon(Icons.fastfood),
                    title: Text(meal.name),
                    subtitle: Text(
                      meal.detail.isNotEmpty ? meal.detail : meal.category,
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: colorScheme.error),
                      onPressed: () => _removeMeal(index),
                    ),
                  ),
                );
              }),

            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _savePreset,
                child: const Text('Save Preset'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
