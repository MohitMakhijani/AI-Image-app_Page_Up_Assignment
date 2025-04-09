import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neon/neon.dart';
import 'package:page_up_assignment/Controller/image_options_controller.dart';
import 'package:page_up_assignment/Utils/utils.dart';

class RemoveBgOnlyView extends StatelessWidget {
  RemoveBgOnlyView({super.key});

  final ImageOptionsController controller = Get.put(ImageOptionsController());
  final themeColor = Colors.cyan;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        controller.clearImage();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Neon(
            text: "Remove Background",
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
                if (controller.imageUrl.value.isNotEmpty || controller.pickedFile.value != null)
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
                              ? "Background Removed"
                              : "Selected Image",
                          color: themeColor,
                          fontSize: 16,
                          font: NeonFont.Beon,
                        ),
                        const SizedBox(height: 10),

                        ClipRRect(
                          
                          borderRadius: BorderRadius.circular(12),
                          child: controller.imageUrl.value.isNotEmpty
                              ? Image.network(
                                  controller.imageUrl.value,
                                  height: 200,
                                  // color: Colors.amber,
                                  fit: BoxFit.contain,
                                )
                              : Image.file(
                                  File(controller.pickedFile.value!.path),
                                  height: 200,
                                  fit: BoxFit.contain,
                                ),
                        ),

                        const SizedBox(height: 12),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: controller.clearImage,
                              icon: const Icon(Icons.clear, color: Colors.black),
                              label: const Text(
                                "Clear",
                                style: TextStyle(color: Colors.black),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: themeColor,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                ImageDownloader.downloadImage(
                                  context: context,
                                  imageUrl: controller.imageUrl.value,
                                );
                              },
                              icon: const Icon(Icons.download, color: Colors.black),
                              label: const Text(
                                "Download",
                                style: TextStyle(color: Colors.black),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: themeColor,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
