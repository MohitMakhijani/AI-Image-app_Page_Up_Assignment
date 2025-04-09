import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neon/neon.dart';
import 'package:page_up_assignment/Controller/image_options_controller.dart';
import 'package:page_up_assignment/Utils/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class BackgroundPresetView extends StatelessWidget {
  BackgroundPresetView({super.key});

  final ImageOptionsController controller = Get.put(ImageOptionsController());
  final themeColor = Colors.cyan;
  final GlobalKey previewContainer =
      GlobalKey(); // define this at the top in your widget

  Future<void> _saveMergedImage() async {
    try {
      // Ask for permission
      ImageDownloader.requestStoragePermission();
      if (await Permission.storage.request().isGranted) {
        RenderRepaintBoundary boundary = previewContainer.currentContext!
            .findRenderObject() as RenderRepaintBoundary;

        ui.Image image = await boundary.toImage(pixelRatio: 3.0);
        ByteData? byteData =
            await image.toByteData(format: ui.ImageByteFormat.png);
        Uint8List pngBytes = byteData!.buffer.asUint8List();

        // Save to public Downloads directory
        Directory? directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory(); // fallback
        }

        String filePath =
            '${directory!.path}/merged_image_${DateTime.now().millisecondsSinceEpoch}.png';
        File imgFile = File(filePath);
        await imgFile.writeAsBytes(pngBytes);

        // Notify media scanner
        const channel = MethodChannel('gallery_saver');
        await channel.invokeMethod('scanFile', {'path': filePath});

        Get.snackbar(
          "Success",
          "Image saved to Downloads & Gallery",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar("Permission Denied", "Storage permission not granted");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to save image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        controller.clearImage();
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Neon(
            text: "Background Generator",
            color: themeColor,
            font: NeonFont.Beon,
            fontSize: 22,
          ),
          centerTitle: true,
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.cyanAccent),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (controller.imageUrl.value.isNotEmpty ||
                    controller.pickedFile.value != null)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: themeColor, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: themeColor.withOpacity(0.5),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Neon(
                          text: controller.imageUrl.value.isNotEmpty
                              ? "Preview with Background"
                              : "Selected Image",
                          color: themeColor,
                          fontSize: 16,
                          font: NeonFont.Beon,
                        ),
                        const SizedBox(height: 10),

                        /// Image with draggable and zoomable overlay
                        RepaintBoundary(
                          key: previewContainer,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              height: 200,
                              width: double.infinity,
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: Image.asset(
                                      controller.presets[
                                          controller.selectedPreset.value],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned.fill(
                                    child: InteractiveViewer(
                                      panEnabled: true,
                                      scaleEnabled: true,
                                      minScale: 0.5,
                                      maxScale: 3.0,
                                      child:
                                          controller.imageUrl.value.isNotEmpty
                                              ? Image.network(
                                                  controller.imageUrl.value,
                                                  fit: BoxFit.contain,
                                                )
                                              : Image.file(
                                                  File(controller
                                                      .pickedFile.value!.path),
                                                  fit: BoxFit.contain,
                                                ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: controller.clearImage,
                              icon:
                                  const Icon(Icons.clear, color: Colors.black),
                              label: const Text(
                                "Clear Image",
                                style: TextStyle(color: Colors.black),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: themeColor,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: _saveMergedImage,
                              icon: const Icon(Icons.download,
                                  color: Colors.black),
                              label: const Text(
                                "Save Image",
                                style: TextStyle(color: Colors.black),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: themeColor,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                else

                  /// Tap to Pick Image
                  Expanded(
                    child: GestureDetector(
                      onTap: controller.pickImage,
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white),
                        ),
                        child: Center(
                          child: Text(
                            "Click Here To Select Image",
                            style: GoogleFonts.orbitron(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                /// Background Preset Selector
                if (controller.imageUrl.value.isNotEmpty ||
                    controller.pickedFile.value != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Choose Background:",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 80,
                        child: Obx(() => ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: controller.presets.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () =>
                                      controller.selectBackground(index),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color:
                                            controller.selectedPreset.value ==
                                                    index
                                                ? themeColor
                                                : Colors.transparent,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.asset(
                                        controller.presets[index],
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),

                /// Generate Button
                ElevatedButton.icon(
                  onPressed: () {
                    if (controller.pickedFile.value != null) {
                      controller.removeBackground();
                    } else {
                      Get.snackbar("Error", "Select Image First");
                    }
                  },
                  icon: const Icon(Icons.auto_awesome, color: Colors.black),
                  label: const Text(
                    "Remove Background",
                    style: TextStyle(color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 5,
                    shadowColor: themeColor.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
