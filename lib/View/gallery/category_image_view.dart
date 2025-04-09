import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:page_up_assignment/components/gradient_scaffold.dart';
import 'image_viewer.dart';

class CategoryImagesScreen extends StatelessWidget {
  final String tag;
  final List<Map<String, dynamic>> images;

  const CategoryImagesScreen({
    required this.tag,
    required this.images,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      // appBar: AppBar(title: Text("Images for '$tag'")),
      body: images.isEmpty
          ? Center(child: Text("No images found for $tag"))
          : GridView.builder(
              padding: EdgeInsets.all(10),
              itemCount: images.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1,
              ),
              itemBuilder: (_, index) {
                final item = images[index];
                return GestureDetector(
                  onTap: () {
                    Get.to(() => ImageViewerScreen(
                          imageUrl: item['imageUrl'],
                          tags: item['results'],
                        ));
                  },
                  child: Hero(
                    tag: item['imageUrl'],
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
    );
  }
}
