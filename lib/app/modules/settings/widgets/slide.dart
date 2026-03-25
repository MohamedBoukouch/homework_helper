import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ════════════════════════════════════════════════════════════════════════════
//  SLIDE  —  Premium banner widget
// ════════════════════════════════════════════════════════════════════════════
class Slide extends StatelessWidget {
  const Slide({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed('/premium'),
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD966), Color(0xFFFFA726), Color(0xFFFF8F00)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFB300).withOpacity(0.35),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // sparkles
            const Positioned(
              top: 14,
              right: 115,
              child: Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white70,
                size: 13,
              ),
            ),
            const Positioned(
              top: 34,
              right: 74,
              child: Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white60,
                size: 9,
              ),
            ),
            const Positioned(
              bottom: 22,
              right: 138,
              child: Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white70,
                size: 11,
              ),
            ),
            // crown
            Positioned(
              right: 16,
              bottom: 0,
              child: Icon(
                Icons.emoji_events_rounded,
                size: 100,
                color: const Color(0xFF7B4F00).withOpacity(0.85),
              ),
            ),
            // text + button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 140, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Go Premium',
                    style: TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Unlock All Features & No-Ads',
                    style: TextStyle(
                      color: Color(0xFF3D2600),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SlideButton(
                    label: 'Upgrade Now',
                    icon: Icons.workspace_premium_rounded,
                    onTap: () => Get.toNamed('/premium'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  SlideButton  — reusable button for the Slide banner
//  Pass any [label] text and optional [icon].
// ════════════════════════════════════════════════════════════════════════════
class SlideButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;

  const SlideButton({super.key, required this.label, this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 14),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
