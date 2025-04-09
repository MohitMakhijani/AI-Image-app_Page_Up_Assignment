import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';

class FrostedTextCard extends StatelessWidget {
  final String lottie;
  final double width;
  final double height;
  final String title;
  final Widget route;

  const FrostedTextCard({
    super.key,
    required this.title,
    required this.lottie,
    required this.width,
    required this.height,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(
          route,
          transition: Transition.native,
          duration: Duration(milliseconds: 0),
          // curve: Curves.easeInOut, // Smooth and professional
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: height,
            width: width,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(25.r),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyanAccent.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  lottie,
                  fit: BoxFit.contain,
                  width: width * 0.7,
                  height: height * 0.5,
                ),
                SizedBox(height: 12.h),
                Shimmer.fromColors(
                  baseColor: Colors.white,
                  highlightColor: Colors.cyanAccent,
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
