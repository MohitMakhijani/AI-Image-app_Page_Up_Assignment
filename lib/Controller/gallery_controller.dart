import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:page_up_assignment/Repository/firebase_repository.dart';

class GalleryController extends GetxController {
  final images = <Map<String, dynamic>>[].obs;
  final faceGroups = <Map<String, dynamic>>[].obs;
  final categories = <Map<String, dynamic>>[].obs;
  final categorizedImages = <String, List<Map<String, dynamic>>>{}.obs;
  final isLoading = false.obs;

  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchDetectionsFromDatabase() async {
    try {
      final snapshot = await _firestore
          .collection('detections')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'imageUrl': data['imageUrl'],
          'results': data['results'],
          'category': data['category'],
          'subCategories': data['subCategories'],
          'timestamp': data['timestamp'],
          'embedding': data['embedding'],
          'documentId': doc.id,
        };
      }).toList();
    } catch (e) {
      print("Error fetching detections from database: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchCategories() async {
    try {
      final snapshot = await _firestore.collection('category').get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'label': data['label'],
          'subcategories': data['subcategories'] ?? [],
          'documentId': doc.id,
        };
      }).toList();
    } catch (e) {
      print("Error fetching categories: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchFaceGroups() async {
    try {
      final snapshot = await _firestore
          .collection('face_groups')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        final images = (data['images'] ?? []) as List;
        return {
          'images': images, // full list for dialog
          'previewImage': images.isNotEmpty ? images.first : null, // first for UI
          'embeddings': data['embeddings'] ?? [],
          'timestamp': data['timestamp'],
          'documentId': doc.id,
        };
      }).toList();
    } catch (e) {
      print("Error fetching face groups: $e");
      return [];
    }
  }

  void fetchAllData() async {
    isLoading.value = true;

    try {
      final detections = await fetchDetectionsFromDatabase();
      images.assignAll(detections);

      final faces = await fetchFaceGroups();
      faceGroups.assignAll(faces);

      final cats = await fetchCategories();
      categories.assignAll(cats);

      final Map<String, List<Map<String, dynamic>>> categorized = {};

      for (var img in detections) {
        final imgSubcatRaw = img['subCategories'] ?? [];
        final List<String> imgSubcatList = [];
        for (var sub in imgSubcatRaw) {
          if (sub is String) {
            imgSubcatList.add(sub);
          } else if (sub is Map && sub['label'] is String) {
            imgSubcatList.add(sub['label']);
          }
        }

        bool matched = false;

        for (var cat in cats) {
          final label = cat['label'];
          final subcatListRaw = cat['subcategories'] ?? [];

          final List<String> subcatList = [];
          for (var sub in subcatListRaw) {
            if (sub is String) {
              subcatList.add(sub);
            } else if (sub is Map && sub['label'] is String) {
              subcatList.add(sub['label']);
            }
          }

          if (subcatList.any((subcat) => imgSubcatList.contains(subcat))) {
            categorized.putIfAbsent(label, () => []);
            categorized[label]!.add(img);
            matched = true;
            break; // Stop at the first matching category
          }
        }

        if (!matched) {
          categorized.putIfAbsent('Uncategorized', () => []);
          categorized['Uncategorized']!.add(img);
        }
      }

      categorizedImages.assignAll(categorized);
    } catch (e) {
      print("Error in fetchAllData: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
