import 'dart:io';
import 'package:get/get.dart';
import 'package:page_up_assignment/Services/cloudinary.dart';

class ImageOptionsController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString imageUrl = ''.obs;
  final RxString prompt = ''.obs;
  final RxInt selectedPreset = 0.obs;

  final RxList<String> presets = [
    "assets/images/b1.jpeg",
    "assets/images/b2.jpeg",
    "assets/images/b3.jpeg",
    "assets/images/b4.jpeg",
  ].obs;

  void selectBackground(int index) {
    selectedPreset.value = index;
  }

  final uploader = CloudinaryUploader();

  Rx<File?> pickedFile = Rx<File?>(null);

  Future<void> pickImage() async {
    final picked = await uploader.pickImage();
    if (picked != null) {
      pickedFile.value = picked;
    }
  }

  Future<void> _processImage(
      Future<String?> Function(File, String) uploadMethod) async {
    if (pickedFile.value == null) {
      Get.snackbar("Error", "Please select an image and enter a prompt.");
      return;
    }

    isLoading.value = true;
    final url = await uploadMethod(pickedFile.value!, prompt.value);

    if (url != null) {
      imageUrl.value = url;
      print("Uploaded image URL: $url");
    } else {
      print("Upload failed");
    }

    isLoading.value = false;
  }

  Future<void> generateBackground() async =>
      await _processImage(uploader.uploadImageWithGenBackground);

  Future<void> removeBackground() async {
    await _processImage(uploader.removeBgAndSaveImage);
  }

  Future<void> blurBackground() async {
    await _processImage(uploader.uploadImageWithBlurBackground);
  }

  void clearImage() {
    imageUrl.value = '';
    pickedFile.value = null;
  }
}
