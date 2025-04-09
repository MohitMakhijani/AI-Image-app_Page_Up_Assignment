import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_up_assignment/Repository/app_repository.dart';
import 'package:page_up_assignment/Repository/firebase_repository.dart';
import 'package:page_up_assignment/Services/cloudinary.dart';
import 'package:page_up_assignment/Services/face_recogination.dart';

class DetectionController extends GetxController {
  final RxString imageUrl = ''.obs;
  final RxBool isLoading = false.obs;
  final RxList<Map<String, dynamic>> detectedObjects =
      <Map<String, dynamic>>[].obs;

  final ImagePicker _picker = ImagePicker();

  Future<void> pickImageFromGallery() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      isLoading.value = true;
      try {
        await processDetectionWithEmbedding(File(picked.path));
      } catch (e) {
        print("Capture image error: $e");
        Get.snackbar("Upload Error", "Failed to upload image to Cloudinary");
      } finally {
        isLoading.value = false;
      }
    }
  }

  Future<void> captureImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      isLoading.value = true;
      try {
        await processDetectionWithEmbedding(File(picked.path));
      } catch (e) {
        print("Capture image error: $e");
        Get.snackbar("Upload Error", "Failed to upload image to Cloudinary");
      } finally {
        isLoading.value = false;
      }
    }
  }

  Future<void> processDetectionWithEmbedding(File imageFile) async {
    isLoading.value = true;

    try {
      final String? uploadedUrl =
          await CloudinaryUploader().uploadImage(imageFile);
      if (uploadedUrl == null) throw 'Cloudinary upload failed';

      List embedding = [];
      try {
        embedding = (await EmbeddingApi().uploadImageFile(imageFile))!;
      } catch (e) {
        print('Embedding failed, continuing without embedding: $e');
      }

      final List<Map<String, dynamic>> result =
          await ApiService.detectObjects(uploadedUrl);
      if (result.isEmpty) throw 'No objects detected';

      final firebaseService = FirebaseService();
      await firebaseService.saveDetectionData(
        imageUrl: uploadedUrl,
        detectionResults: result,
        embedding: embedding,
      );

      imageUrl.value = uploadedUrl;
      detectedObjects.assignAll(result);
    } catch (e) {
      print("Error in full process: $e");
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Stream<List<Map<String, dynamic>>> fetchGroups() {
    return FirebaseFirestore.instance
        .collection('face_groups')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((e) => e.data()).toList());
  }
}
