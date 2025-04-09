import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_up_assignment/Controller/upload_controller.dart';
import 'package:page_up_assignment/components/gradient_scaffold.dart';

class UploadViewDart extends StatelessWidget {
  final DetectionController controller = Get.put(DetectionController());

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        controller.imageUrl.value = '';
        controller.detectedObjects.clear();
        // controller.isLoading.v .clear();

        return true;
      },
      child: GradientScaffold(
        // backgroundColor: Colors.black, // dark background for neon vibe
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            "OBJECT DETECTION",
            style: GoogleFonts.orbitron(
              color: Colors.cyanAccent,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              shadows: [
                Shadow(color: Colors.cyanAccent, blurRadius: 10),
                Shadow(color: Colors.blueAccent, blurRadius: 30),
              ],
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Obx(() {
                final url = controller.imageUrl.value;
                return ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.2)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: url.isEmpty
                          ? Center(
                              child: Text(
                                "No Image Selected",
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            )
                          : Image.network(url, fit: BoxFit.cover),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _neonButton("Capture & Upload", controller.captureImage),
                  _neonButton("Pick & Upload", controller.pickImageFromGallery),
                ],
              ),
              const SizedBox(height: 24),
              // _neonButton(
              //       "Detect Objects",
              //       controller.isLoading.value ? null : controller.detectObjects,
              //       disabled: controller.isLoading.value,
              //     ),
              const SizedBox(height: 24),
              Obx(() {
                if (controller.isLoading.value) {
                  return CircularProgressIndicator(
                    color: Colors.cyanAccent,
                  );
                } else if (controller.detectedObjects.isEmpty) {
                  return Text(
                    "",
                    style: TextStyle(color: Colors.white70),
                  );
                } else {
                  return Expanded(
                    child: ListView.builder(
                      itemCount: controller.detectedObjects.length,
                      itemBuilder: (context, index) {
                        final obj = controller.detectedObjects[index];
                        return Card(
                          color: Colors.white.withOpacity(0.05),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            leading: Icon(Icons.tag, color: Colors.cyanAccent),
                            title: Text(
                              obj['label'],
                              style: GoogleFonts.orbitron(
                                color: Colors.cyanAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                shadows: [
                                  Shadow(
                                      color: Colors.cyanAccent, blurRadius: 10),
                                ],
                              ),
                            ),
                            subtitle: Text(
                              "Confidence: ${(obj['confidence'] * 100).toStringAsFixed(2)}%",
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _neonButton(String text, VoidCallback? onPressed,
      {bool disabled = false}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.cyanAccent,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        side: BorderSide(color: Colors.cyanAccent, width: 2),
        elevation: disabled ? 0 : 10,
      ),
      child: Text(
        text,
        style: GoogleFonts.orbitron(
          color: disabled ? Colors.white38 : Colors.cyanAccent,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          shadows: disabled
              ? []
              : [
                  Shadow(color: Colors.cyanAccent, blurRadius: 10),
                  Shadow(color: Colors.blueAccent, blurRadius: 20),
                ],
        ),
      ),
    );
  }
}
