
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:neon/neon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:page_up_assignment/components/gradient_scaffold.dart';
import 'package:permission_handler/permission_handler.dart';

class ImageViewerScreen extends StatelessWidget {
  final String imageUrl;
  final List<dynamic> tags;

  const ImageViewerScreen({
    Key? key,
    required this.imageUrl,
    required this.tags,
  }) : super(key: key);
 
  Future<bool> _requestStoragePermission() async {
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

  Future<void> _downloadImage(Uint8List editedBytes) async {
    try {
      // Ensure permissions
      if (!await _requestStoragePermission()) {
        Get.snackbar("Permission Denied", "Storage access is required",
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      // Save to Downloads
      Directory? directory = Directory("/storage/emulated/0/Download");
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      String filePath =
          '${directory.path}/image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      File file = File(filePath);
      await file.writeAsBytes(editedBytes);

      // Notify media scanner to show in gallery
      const channel = MethodChannel('gallery_saver');
      await channel.invokeMethod('scanFile', {'path': file.path});
      await
      Get.snackbar("Success", "Image saved to Gallery",
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", "Failed to save image",
          backgroundColor: Colors.red, colorText: Colors.white);
      print(e);
    }
  }

  Future<void> _openEditor() async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        Uint8List imageBytes = response.bodyBytes;

        final editedImage = await Get.to(() => ImageEditor(image: imageBytes));
        if (editedImage != null && editedImage is Uint8List) {
          if (await _requestStoragePermission()) {
            await _downloadImage(editedImage);
          } else {
            Get.snackbar("Failed", "Permission not granted",
                backgroundColor: Colors.red, colorText: Colors.white);
          }
        }
      }
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      // backgroundColor: Colors.black,
      appBar: AppBar(
        actions: [
          IconButton(onPressed: () => _openEditor(), icon: Icon(Icons.edit))
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 10),
        children: [
          CachedNetworkImage(
            imageUrl: imageUrl,
            placeholder: (context, url) => Container(
              height: 400,
              width: double.infinity,
            ),
            errorWidget: (context, url, error) =>
                const Icon(Icons.error, color: Colors.red),
          ),
          const SizedBox(height: 10),
          Center(
            child: Neon(
              text: "Detected Tags",
              color: Colors.cyan,
              fontSize: 18,
              font: NeonFont.Beon,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: RepaintBoundary(
              child: Wrap(
                spacing: 8.0,
                runSpacing: 6.0,
                children: tags.map<Widget>((tag) {
                  return Chip(
                    label: Text(
                      "${tag['label']} (${tag['confidence'].toStringAsFixed(1)}%)",
                      style: GoogleFonts.orbitron(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: Colors.black,
                    shape: const StadiumBorder(
                      side: BorderSide(color: Colors.cyanAccent),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
