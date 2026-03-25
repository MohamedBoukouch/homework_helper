import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homework_helper/app/modules/home/pages/camera_page.dart';
import 'package:homework_helper/app/modules/settings/views/settings_view.dart';
import '../widgets/home_slider.dart';
import '../widgets/home_services.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentIndex = 0;

  /// Pages for tabs except Camera
  final List<Widget> _pages = [
    const HomePageContent(), // Home content
    const Center(child: Text('AI Tutor Page')), // AI Tutor
    const SizedBox.shrink(), // Placeholder for Scan, will open new page
    const Center(child: Text('History Page')), // History
    const SettingsView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: IndexedStack(index: _currentIndex, children: _pages),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF4B5EFC),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 2) {
            // Open camera page as full screen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CameraPage()),
            );
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy_rounded),
            label: 'AI Tutor',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt_rounded),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

/// Home page content extracted for clarity
class HomePageContent extends StatelessWidget {
  const HomePageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Hi, Good morning 👋',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Image.asset('assets/icon.png', width: 36, height: 36),
            ],
          ),
          const SizedBox(height: 20),
          const HomeSlider(),
          const SizedBox(height: 28),
          const HomeServices(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
