import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../home/views/home_view.dart';

class Splash3View extends StatelessWidget {
  const Splash3View({super.key});

  static const _items = [
    _Item(Icons.document_scanner_rounded, 'Scan Room', Color(0xFFF5F6FF)),
    _Item(Icons.style_rounded, 'Flashcard', Color(0xFFF5F6FF)),
    _Item(Icons.summarize_rounded, 'Summarize', Color(0xFFF5F6FF)),
    _Item(Icons.quiz_rounded, 'Quiz', Color(0xFFF5F6FF)),
    _Item(Icons.translate_rounded, 'Translator', Color(0xFFF5F6FF)),
    _Item(Icons.spellcheck_rounded, 'Check Grammar', Color(0xFFF5F6FF)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              // SKIP
              Align(
                alignment: Alignment.topLeft,
                child: TextButton(
                  onPressed: () => Get.off(() => const HomeView()),
                  child: const Text(
                    'SKIP',
                    style: TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: _items
                    .map(
                      (item) => Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F7F7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(
                              item.icon,
                              color: const Color(0xFF4B5EFC),
                              size: 28,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item.label,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),

              const Spacer(),

              // Title
              const Text(
                'Explore the Most\nAdvanced AI Tools',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                ),
              ),

              const SizedBox(height: 32),

              // Continue button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () => Get.off(() => const HomeView()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4B5EFC),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == 2 ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == 2
                          ? const Color(0xFF4B5EFC)
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class _Item {
  final IconData icon;
  final String label;
  final Color bg;
  const _Item(this.icon, this.label, this.bg);
}
