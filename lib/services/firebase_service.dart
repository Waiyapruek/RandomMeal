import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/preset.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch all presets from Firestore
  Future<List<Preset>> fetchPresets() async {
    try {
      final snapshot = await _firestore.collection('presets').get();
      if (snapshot.docs.isEmpty) {
        print('No presets in Firestore, using mock data');
        return mockPresets;
      }
      return snapshot.docs
          .map((doc) => Preset.fromJson(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching presets: $e, using mock data');
      return mockPresets;
    }
  }

  // Fetch a single preset by ID
  Future<Preset?> fetchPresetById(String presetId) async {
    try {
      final doc = await _firestore.collection('presets').doc(presetId).get();
      if (doc.exists) {
        return Preset.fromJson(doc.id, doc.data()!);
      }
      // Fallback to mock data
      final mockData = mockPresets.where((p) => p.id == presetId).toList();
      return mockData.isNotEmpty ? mockData.first : null;
    } catch (e) {
      print('Error fetching preset: $e, using mock data');
      final mockData = mockPresets.where((p) => p.id == presetId).toList();
      return mockData.isNotEmpty ? mockData.first : null;
    }
  }

  // Save a preset to Firestore
  Future<void> savePreset(Preset preset) async {
    try {
      await _firestore
          .collection('presets')
          .doc(preset.id)
          .set(preset.toJson());
    } catch (e) {
      print('Error saving preset: $e');
    }
  }

  // Delete a preset from Firestore
  Future<void> deletePreset(String presetId) async {
    try {
      await _firestore.collection('presets').doc(presetId).delete();
    } catch (e) {
      print('Error deleting preset: $e');
    }
  }
}

// Firestore service provider
final firebaseServiceProvider = Provider((ref) => FirebaseService());

// Provider to fetch all presets from Firestore
final presetsProvider = FutureProvider<List<Preset>>((ref) async {
  final service = ref.watch(firebaseServiceProvider);
  return service.fetchPresets();
});

// Provider to fetch a single preset by ID
final presetByIdProvider =
    FutureProvider.family<Preset?, String>((ref, presetId) async {
  final service = ref.watch(firebaseServiceProvider);
  return service.fetchPresetById(presetId);
});
