import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart' show Routes;

class OnboardingController extends GetxController {
  final pageController = PageController();
  final currentPage = 0.obs;

  void onPageChanged(int index) => currentPage.value = index;

  void next() {
    if (currentPage.value < 2) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Get.offAllNamed(Routes.HOME);
    }
  }

  void skip() => Get.offAllNamed(Routes.HOME);

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
