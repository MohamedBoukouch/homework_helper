import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homework_helper/app/modules/home/views/home_view.dart';

class Splash2View extends StatelessWidget {
  const Splash2View({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
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

              const Spacer(),

              // GIF image
              Image.asset(
                'assets/reading.gif',
                height: 320,
                fit: BoxFit.contain,
              ),

              const Spacer(),

              // Title
              const Text(
                'Snap & Analyze\nYour Home',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
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
                    width: i == 1 ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == 1
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
