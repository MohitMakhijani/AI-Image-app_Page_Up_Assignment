import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:lottie/lottie.dart';

Widget neonShimmerBox({
  required double height,
  required String lottiePath,
  required String text,
  required Widget route,
}) {
  return Shimmer.fromColors(
    baseColor: const Color(0xFF00F5FF),
    highlightColor: const Color(0xFF00FF87),
    child: GestureDetector(
      onTap: () {Get.to(
  route,
  transition: Transition.native,
  duration: Duration(milliseconds: 0),
  // curve: Curves.easeInOut, // Smooth and professional
);

      },
      child: Container(
        height: height,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              const Color(0xFF00F5FF).withOpacity(0.1),
              const Color(0xFF00FF87).withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00F5FF).withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 5,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              lottiePath,
              width: height * 0.4,
              height: height * 0.4,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            Shimmer.fromColors(
              baseColor: Colors.white,
              highlightColor: Colors.cyanAccent,
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
