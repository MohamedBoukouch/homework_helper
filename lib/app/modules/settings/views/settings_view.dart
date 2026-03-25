import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/settings_controller.dart';
import '../widgets/slide.dart';
import '../widgets/settings_menu_tile.dart';

// ════════════════════════════════════════════════════════════════════════════
//  SETTINGS VIEW  —  Light mode
// ════════════════════════════════════════════════════════════════════════════
class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is initialized
    if (!Get.isRegistered<SettingsController>()) {
      Get.put(SettingsController());
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          _TopBar(),
          Expanded(
            child: Obx(
              () => ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                children: [
                  // ── Premium banner ───────────────────────────────────────
                  const Slide(),
                  const SizedBox(height: 24),

                  // ════════════════════════════════════════════════════════
                  //  PREFERENCES
                  // ════════════════════════════════════════════════════════
                  const _SectionLabel('Preferences'),
                  const SizedBox(height: 8),
                  _MenuGroup(
                    children: [
                      SettingsMenuTile(
                        icon: Icons.tag_rounded,
                        iconColor: const Color(0xFF4D96FF),
                        label: 'Result decimal places',
                        trailing: controller.decimalPlaces.value.toString(),
                        onTap: controller.changeDecimalPlaces,
                      ),
                      SettingsMenuTile(
                        icon: Icons.school_rounded,
                        iconColor: const Color(0xFF9B59B6),
                        label: 'Academic Level',
                        trailing: controller.academicLevel.value,
                        onTap: controller.changeAcademicLevel,
                      ),
                      SettingsMenuTile(
                        icon: Icons.help_outline_rounded,
                        iconColor: const Color(0xFFFF8C42),
                        label: 'Floating Ball Question Search',
                        onTap: () => Get.toNamed('/floating-ball'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ════════════════════════════════════════════════════════
                  //  GENERAL
                  // ════════════════════════════════════════════════════════
                  const _SectionLabel('General'),
                  const SizedBox(height: 8),
                  _MenuGroup(
                    children: [
                      SettingsMenuTile(
                        icon: Icons.dark_mode_rounded,
                        iconColor: const Color(0xFF5C6BC0),
                        label: 'Dark Mode',
                        isToggle: true,
                        toggleValue: controller.isDarkMode.value,
                        onToggle: controller.toggleDarkMode,
                      ),
                      SettingsMenuTile(
                        icon: Icons.restore_rounded,
                        iconColor: const Color(0xFF4DB6AC),
                        label: 'Restore',
                        onTap: controller.restore,
                      ),
                      SettingsMenuTile(
                        icon: Icons.description_outlined,
                        iconColor: const Color(0xFF4D96FF),
                        label: 'Term of Services',
                        onTap: () => Get.toNamed('/terms'),
                      ),
                      SettingsMenuTile(
                        icon: Icons.shield_outlined,
                        iconColor: const Color(0xFF9B59B6),
                        label: 'Privacy Policy',
                        onTap: () => Get.toNamed('/privacy'),
                      ),
                      SettingsMenuTile(
                        icon: Icons.attach_money_rounded,
                        iconColor: const Color(0xFF2ECC71),
                        label: 'Manage Subscription',
                        onTap: () => Get.toNamed('/subscription'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ════════════════════════════════════════════════════════
                  //  SHARING & SUPPORT
                  // ════════════════════════════════════════════════════════
                  const _SectionLabel('Sharing & Support'),
                  const SizedBox(height: 8),
                  _MenuGroup(
                    children: [
                      SettingsMenuTile(
                        icon: Icons.star_outline_rounded,
                        iconColor: const Color(0xFFF4C430),
                        label: 'Rate Us',
                        onTap: controller.rateApp,
                      ),
                      SettingsMenuTile(
                        icon: Icons.ios_share_rounded,
                        iconColor: const Color(0xFF4D96FF),
                        label: 'Share App',
                        onTap: controller.shareApp,
                      ),
                      SettingsMenuTile(
                        icon: Icons.mail_outline_rounded,
                        iconColor: const Color(0xFF6BCB77),
                        label: 'Contact Us',
                        onTap: () => Get.toNamed('/contact'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ... rest of the widgets remain the same

// ════════════════════════════════════════════════════════════════════════════
//  TOP BAR
// ════════════════════════════════════════════════════════════════════════════
class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: Color(0xFF1A1A1A),
                  size: 20,
                ),
              ),
            ),
            const Expanded(
              child: Center(
                child: Text(
                  'Settings',
                  style: TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 36),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  SECTION LABEL
// ════════════════════════════════════════════════════════════════════════════
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF999999),
          fontSize: 13,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  MENU GROUP  — white card with dividers between tiles
// ════════════════════════════════════════════════════════════════════════════
class _MenuGroup extends StatelessWidget {
  final List<Widget> children;
  const _MenuGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              const Divider(
                height: 1,
                thickness: 0.6,
                indent: 56,
                color: Color(0xFFF0F0F0),
              ),
          ],
        ],
      ),
    );
  }
}
