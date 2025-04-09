import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:page_up_assignment/View/background_blur/bg_blur_view.dart';
import 'package:page_up_assignment/View/background_gen/select_bg_gen.dart';
import 'package:page_up_assignment/View/background_rem/bg_rem_view.dart';
import 'package:page_up_assignment/View/gallery/gallery_view.dart';
import 'package:page_up_assignment/View/upload/upload_view.dart';
import 'package:page_up_assignment/components/custom_frosted_container.dart';
import 'package:page_up_assignment/components/gradient_scaffold.dart';
import 'package:page_up_assignment/components/neon_shimmer_conatiner.dart';

class HomePageView extends StatelessWidget {
  const HomePageView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GradientScaffold(
          // backgroundColor: Colors.blueGrey,
          body: Padding(
        padding: EdgeInsets.symmetric(vertical: 40.0.h, horizontal: 20.w),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FrostedTextCard(
                  route: RemoveBgOnlyView(),
                  lottie: 'assets/lottie/l2.json',
                  title: "BG Remove",
                  width: 100.w,
                  height: 150.h, // You can use height inside if needed
                ),
                FrostedTextCard(
                  route: SelectBgGenView(),
                  lottie: 'assets/lottie/l1.json',
                  title: "BG Gen",
                  width: 100.w,
                  height: 150.h, // You can use height inside if needed
                ),
                FrostedTextCard(
                  route: BlurBgOnlyView(),
                  lottie: 'assets/lottie/l4.json',
                  title: "Potraite",
                  width: 100.w,
                  height: 150.h, // You can use height inside if needed
                ),
              ],
            ),
            SizedBox(
              height: 30.h,
            ),
            neonShimmerBox(
              route: UploadViewDart(),
              height: 230.h,
              lottiePath: 'assets/lottie/l6.json',
              text: "Object Detection",
            ),
            SizedBox(
              height: 30.h,
            ),
            neonShimmerBox(
              route: GalleryScreen(),
              height: 230.h,
              lottiePath: 'assets/lottie/l7.json',
              text: "View Gallery",
            ),
          ],
        ),
      )),
    );
  }
}
