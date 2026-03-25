import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ════════════════════════════════════════════════════════════════════════════
//  SETTINGS CONTROLLER
// ════════════════════════════════════════════════════════════════════════════
class SettingsController extends GetxController {
  // Make these Rx variables for reactive updates
  final decimalPlaces = 0.obs;
  final academicLevel = 'High'.obs;
  final isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize any saved preferences here
    _loadSavedPreferences();
  }

  void _loadSavedPreferences() {
    // Load saved preferences from SharedPreferences or similar
    // For now, just set defaults
    decimalPlaces.value = 0;
    academicLevel.value = 'High';
    isDarkMode.value = false;
  }

  // ── Decimal places picker ─────────────────────────────────────────────────
  void changeDecimalPlaces() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Decimal Places',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            5,
            (i) => ListTile(
              title: Text(
                '$i',
                style: const TextStyle(color: Color(0xFF333333)),
              ),
              trailing: decimalPlaces.value == i
                  ? const Icon(Icons.check_rounded, color: Color(0xFF6BCB77))
                  : null,
              onTap: () {
                decimalPlaces.value = i;
                Get.back();
              },
            ),
          ),
        ),
      ),
    );
  }

  // ── Academic level picker ─────────────────────────────────────────────────
  void changeAcademicLevel() {
    final levels = ['Primary', 'Middle', 'High', 'University'];
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Academic Level',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: levels
              .map(
                (level) => ListTile(
                  title: Text(
                    level,
                    style: const TextStyle(color: Color(0xFF333333)),
                  ),
                  trailing: academicLevel.value == level
                      ? const Icon(
                          Icons.check_rounded,
                          color: Color(0xFF6BCB77),
                        )
                      : null,
                  onTap: () {
                    academicLevel.value = level;
                    Get.back();
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  // ── Dark mode toggle ──────────────────────────────────────────────────────
  void toggleDarkMode(bool value) {
    isDarkMode.value = value;
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
    // Save preference
    // _saveDarkModePreference(value);
  }

  // ── Restore ───────────────────────────────────────────────────────────────
  void restore() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Restore Purchases',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'Looking for previous purchases…',
          style: TextStyle(color: Color(0xFF666666)),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF999999)),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Restore',
                'No previous purchases found.',
                backgroundColor: Colors.white,
                colorText: const Color(0xFF333333),
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text(
              'Restore',
              style: TextStyle(
                color: Color(0xFF6BCB77),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Rate app ──────────────────────────────────────────────────────────────
  void rateApp() {
    // TODO: use in_app_review package
    Get.snackbar(
      'Rate Us',
      'Thank you for your support! 🌟',
      backgroundColor: Colors.white,
      colorText: const Color(0xFF333333),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // ── Share app ─────────────────────────────────────────────────────────────
  void shareApp() {
    // TODO: use share_plus package
    Get.snackbar(
      'Share App',
      'Sharing coming soon!',
      backgroundColor: Colors.white,
      colorText: const Color(0xFF333333),
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
