import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class ImageDownloader {
  static Future<bool> requestStoragePermission() async {
    if (await Permission.storage.isGranted) return true;

    if (Platform.isAndroid) {
      if (await Permission.manageExternalStorage.isGranted) return true;

      final result = await Permission.manageExternalStorage.request();
      return result.isGranted;
    } else {
      final result = await Permission.storage.request();
      return result.isGranted;
    }
  }

  static Future<void> downloadImage({
    required BuildContext context,
    required String imageUrl,
  }) async {
    if (!await requestStoragePermission()) {
      Get.snackbar(
        "Permission Denied",
        "Storage access is required",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final Directory directory = Directory("/storage/emulated/0/Download");
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }

        String filePath =
            '${directory.path}/image_${DateTime.now().millisecondsSinceEpoch}.jpg';
        File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        // Notify media scanner to show in gallery
        const channel = MethodChannel('gallery_saver');
        await channel.invokeMethod('scanFile', {'path': file.path});

        Get.snackbar(
          "Success",
          "Image saved to Downloads & Gallery",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        _showSnackBar(context, "Failed to download image: Server error");
      }
    } catch (e) {
      _showSnackBar(context, "Failed to save image: $e");
    }
  }

  

  static void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
