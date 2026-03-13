import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/preset.dart';

/// Shows a detail dialog for a [Meal], matching the app's standard card style.
///
/// Optionally displays a [subtitle] (e.g. preset name) below the meal name.
/// Optionally displays a [timestamp] formatted as date and time.
void showMealDetailDialog(
  BuildContext context,
  Meal meal, {
  String? subtitle,
  DateTime? timestamp,
}) {
  showDialog(
    context: context,
    builder: (dialogContext) {
      final theme = Theme.of(dialogContext);
      final colorScheme = theme.colorScheme;

      return Dialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Meal image
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: meal.imageUrl != null
                        ? Image.network(
                            meal.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: colorScheme.primaryContainer,
                              child: Icon(
                                Icons.restaurant,
                                size: 64,
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                          )
                        : Container(
                            color: colorScheme.primaryContainer,
                            child: Icon(
                              Icons.restaurant,
                              size: 64,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                  ),
                ),
                // Meal details
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meal.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          subtitle,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                      if (timestamp != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('dd/MM/yy – HH:mm').format(timestamp),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Text(
                        meal.detail,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                // Close button
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
