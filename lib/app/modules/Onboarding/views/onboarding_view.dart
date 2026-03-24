import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // SKIP
            Align(
              alignment: Alignment.topLeft,
              child: TextButton(
                onPressed: controller.skip,
                child: const Text(
                  'SKIP',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            ),

            // Pages
            Expanded(
              child: PageView(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                children: const [_Page1(), _Page2(), _Page3()],
              ),
            ),

            // Dots
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: controller.currentPage.value == i ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: controller.currentPage.value == i
                          ? const Color(0xFF4B5EFC)
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Continue button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: controller.next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4B5EFC),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Page 1 — like your screenshot 7 (app logo + trust stats)
class _Page1 extends StatelessWidget {
  const _Page1();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/icon.png', width: 110, height: 110),
          const SizedBox(height: 16),
          const Text(
            'AI Home Helper',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF0FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'Powered by Advanced AI Models',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.emoji_events, color: Colors.grey, size: 32),
              SizedBox(width: 8),
              Column(
                children: [
                  Text(
                    '5M+',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4B5EFC),
                    ),
                  ),
                  Text('Users', style: TextStyle(color: Colors.grey)),
                ],
              ),
              SizedBox(width: 8),
              Icon(Icons.emoji_events, color: Colors.grey, size: 32),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (_) => const Icon(Icons.star, color: Colors.amber, size: 28),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Page 2 — like screenshot 6 (camera scan illustration)
class _Page2 extends StatelessWidget {
  const _Page2();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 220,
            height: 260,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.camera_alt_rounded,
                  size: 80,
                  color: Colors.grey,
                ),
                // scan line
                Positioned(
                  top: 100,
                  left: 20,
                  right: 20,
                  child: Container(height: 3, color: Colors.red),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Snap & Analyze\nYour Home',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Take a photo of any area — our AI instantly detects issues and gives smart repair advice.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 15, height: 1.5),
          ),
        ],
      ),
    );
  }
}

// ── Page 3 — like screenshot 5 (feature grid)
class _Page3 extends StatelessWidget {
  const _Page3();

  static const _items = [
    [Icons.camera_alt_rounded, 'Scan Room'],
    [Icons.psychology_rounded, 'AI Analysis'],
    [Icons.view_in_ar_rounded, '3D Simulation'],
    [Icons.home_repair_service_rounded, 'Repair Guide'],
    [Icons.attach_money_rounded, 'Cost Estimate'],
    [Icons.history_rounded, 'History'],
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
            children: _items
                .map(
                  (item) => Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6FF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item[0] as IconData,
                          color: const Color(0xFF4B5EFC),
                          size: 30,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item[1] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 28),
          const Text(
            'Explore All AI Tools',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Everything you need for your smart home.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
