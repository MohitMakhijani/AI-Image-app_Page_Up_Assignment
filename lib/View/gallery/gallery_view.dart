import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neon/neon.dart';
import 'package:page_up_assignment/Controller/gallery_controller.dart';
import 'package:page_up_assignment/View/gallery/category_image_view.dart';
import 'package:page_up_assignment/View/gallery/image_viewer.dart';
import 'package:page_up_assignment/components/gradient_scaffold.dart';
import 'package:page_up_assignment/test.dart';

class GalleryScreen extends StatelessWidget {
  final GalleryController controller = Get.put(GalleryController());

  @override
  Widget build(BuildContext context) {
    controller.fetchAllData();

    return GradientScaffold(
      appBar: AppBar(
        title: Neon(
          text: 'Uploaded Images',
          color: Colors.cyan,
          font: NeonFont.Membra,
          fontSize: 18,
          glowing: true,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
              child: CircularProgressIndicator(color: Colors.cyanAccent));
        }

        return SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (controller.categorizedImages.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                "Categories",
                style: GoogleFonts.orbitron(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.categorizedImages.length,
                itemBuilder: (_, index) {
                  final tag =
                      controller.categorizedImages.keys.elementAt(index);
                  final imageList = controller.categorizedImages[tag]!;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Get.to(() => CategoryImagesScreen(
                                tag: tag, images: imageList));
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Colors.grey[800]!, Colors.black],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.cyanAccent,
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.network(
                                imageList[0]['imageUrl'],
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          tag,
                          style: GoogleFonts.orbitron(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
         
            if (controller.faceGroups.isNotEmpty ) ...[
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  "Face Groups",
                  style: GoogleFonts.orbitron(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.faceGroups.length,
                  itemBuilder: (_, index) {
                    final group = controller.faceGroups[index];
                    final images = group['images'] ?? [];

                    if (images.isEmpty) return SizedBox();

                    return GestureDetector(
                      onTap: () {
                        Get.to(() => FaceGroupScreen(images: images));
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            images[0],
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                "All Images",
                style: GoogleFonts.orbitron(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            controller.images.isEmpty
                ? Center(
                    child: Text(
                      "No images found.",
                      style: GoogleFonts.orbitron(color: Colors.white70),
                    ),
                  )
                : GridView.builder(
                    padding: EdgeInsets.all(10),
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: controller.images.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (_, index) {
                      final item = controller.images[index];
                      return GestureDetector(
                        onTap: () {
                          Get.to(() => ImageViewerScreen(
                                imageUrl: item['imageUrl'],
                                tags: item['results'],
                              ));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(
                              colors: [Colors.grey[850]!, Colors.black],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.cyanAccent,
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              item['imageUrl'],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ));
      }),
    );
  }
}
