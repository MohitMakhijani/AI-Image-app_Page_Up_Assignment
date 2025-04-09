import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:page_up_assignment/View/background_gen/bg_gen_preset.dart';
import 'package:page_up_assignment/View/background_gen/bg_gen_prompt.dart';
import 'package:page_up_assignment/View/gallery/gallery_view.dart';
import 'package:page_up_assignment/View/upload/upload_view.dart';
import 'package:page_up_assignment/components/gradient_scaffold.dart';
import 'package:page_up_assignment/components/neon_shimmer_conatiner.dart';

class SelectBgGenView extends StatelessWidget {
  const SelectBgGenView({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: 
    Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
             neonShimmerBox(
                route: BackgroundGenrationView(),
                height: 230.h,
                lottiePath: 'assets/lottie/l8.json',
                text: "Prompt Based",
              ),
              SizedBox(
                height: 30.h,
              ),
              neonShimmerBox(
                route: BackgroundPresetView(),
                height: 230.h,
                lottiePath: 'assets/lottie/l9.json',
                text: "Preset Based",
              ),
        ],
      ),
    )
    );
  }
}