import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveDetectionData({
    required String imageUrl,
    required List<Map<String, dynamic>> detectionResults,
    required List embedding,
  }) async {
    final String categoryLabel = detectionResults[0]['label'];
    final String subCategoryLabel = detectionResults.length > 1
        ? detectionResults[1]['label']
        : 'Uncategorized';

    // Step 1: Save to detections
    final detectionDoc = await _firestore.collection('detections').add({
      'imageUrl': imageUrl,
      'embedding': embedding,
      'category': categoryLabel,
      'subCategories': detectionResults.take(3).toList(),
      'results': detectionResults,
      'timestamp': FieldValue.serverTimestamp(),
    });

    final detectionId = detectionDoc.id;

    // Step 2: Update or create face group
    if (embedding.isNotEmpty) {
      await _updateOrCreateFaceGroup(imageUrl, embedding);
    }

    // Step 3: Update or create category
    await _updateOrCreateCategory(categoryLabel, subCategoryLabel, detectionId);
  }

  Future<void> _updateOrCreateFaceGroup(String imageUrl, List embedding) async {
    final faceGroups = await _firestore.collection('face_groups').get();

    const double threshold = 0.5;
    String? matchedGroupId;

    for (var doc in faceGroups.docs) {
      final List groupEmbeddings = doc['embeddings'];

      for (var e in groupEmbeddings) {
        List<double> vec = List<double>.from(e['vector']);
        double similarity = _cosineSimilarity(embedding.cast<double>(), vec);

        if (similarity > threshold) {
          matchedGroupId = doc.id;
          break;
        }
      }

      if (matchedGroupId != null) break;
    }

    if (matchedGroupId != null) {
      await _firestore.collection('face_groups').doc(matchedGroupId).update({
        'images': FieldValue.arrayUnion([imageUrl]),
        'embeddings': FieldValue.arrayUnion([
          {'vector': embedding}
        ]),
      });
    } else {
      await _firestore.collection('face_groups').add({
        'images': [imageUrl],
        'embeddings': [
          {'vector': embedding}
        ],
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> _updateOrCreateCategory(
      String categoryLabel, String subCategoryLabel, String detectionId) async {
    final query = await _firestore
        .collection('category')
        .where('label', isEqualTo: categoryLabel)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      final docRef = query.docs.first.reference;
      final data = query.docs.first.data();
      List<dynamic> subcategories = data['subcategories'] ?? [];

      bool subcategoryExists = false;

      for (int i = 0; i < subcategories.length; i++) {
        if (subcategories[i]['label'] == subCategoryLabel) {
          subcategories[i]['items'] = List<String>.from(
            subcategories[i]['items'] ?? [],
          )..add(detectionId);
          subcategoryExists = true;
          break;
        }
      }

      if (!subcategoryExists) {
        subcategories.add({
          'label': subCategoryLabel,
          'items': [detectionId],
        });
      }

      await docRef.update({'subcategories': subcategories});
    } else {
      await _firestore.collection('category').add({
        'label': categoryLabel,
        'subcategories': [
          {
            'label': subCategoryLabel,
            'items': [detectionId]
          }
        ],
      });
    }
  }

  double _cosineSimilarity(List<double> a, List<double> b) {
    double dot = 0, magA = 0, magB = 0;
    for (int i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
      magA += a[i] * a[i];
      magB += b[i] * b[i];
    }
    return dot / (sqrt(magA) * sqrt(magB));
  }
}
