import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neon/neon.dart';
import 'package:page_up_assignment/Controller/image_options_controller.dart';
import 'package:page_up_assignment/Utils/utils.dart';

class BackgroundGenrationView extends StatelessWidget {
  final ImageOptionsController controller = Get.put(ImageOptionsController());

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.cyan;

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
                child: CircularProgressIndicator(color: Colors.cyanAccent));
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                /// Show Picked or Uploaded Image
                if (controller.imageUrl.value.isNotEmpty ||
                    controller.pickedFile.value != null)
                  AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: themeColor, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: themeColor.withOpacity(0.5),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Neon(
                          text: controller.imageUrl.value.isNotEmpty
                              ? "Generated Image"
                              : "Selected Image",
                          color: themeColor,
                          fontSize: 16,
                          font: NeonFont.Beon,
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: controller.imageUrl.value.isNotEmpty
                              ? Image.network(
                                  controller.imageUrl.value,
                                  height: 200,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  File(controller.pickedFile.value!.path),
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        const SizedBox(height: 12),
                        Obx(() {
                          final hasImage = controller.imageUrl.value.isNotEmpty;
                          return Row(
                            mainAxisAlignment: hasImage
                                ? MainAxisAlignment.center
                                : MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton.icon(
                                onPressed: controller.clearImage,
                                icon: const Icon(Icons.clear,
                                    color: Colors.black),
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
                              if (hasImage)
                                const SizedBox(
                                    width:
                                        16), // spacing between buttons if both are shown
                              if (hasImage)
                                ElevatedButton.icon(
                                  onPressed: () {
                                    ImageDownloader.downloadImage(
                                      context: context,
                                      imageUrl: controller.imageUrl.value,
                                    );
                                  },
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
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        }),
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
                          borderRadius: BorderRadius.all(Radius.circular(20)),
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

                const SizedBox(height: 20),

                /// Prompt Input
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.grey.shade900, Colors.grey.shade800],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: themeColor.withOpacity(0.4),
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    style: GoogleFonts.orbitron(color: Colors.white),
                    onChanged: (value) => controller.prompt.value = value,
                    decoration: InputDecoration(
                      labelText: "Enter your prompt",
                      labelStyle: TextStyle(color: themeColor),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: themeColor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.text_fields, color: themeColor),
                    ),
                  ),
                ),

                const Spacer(),

                /// Generate Button
                ElevatedButton.icon(
                  onPressed: () {
                    if (controller.pickedFile.value != null &&
                        controller.prompt.value.isNotEmpty) {
                      controller.generateBackground();
                    } else {
                      Get.snackbar("Error", "Select Image And Enter Prompt");
                    }
                  },
                  icon: Icon(Icons.auto_awesome, color: Colors.black),
                  label: Text(
                    "Generate",
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
