import 'package:flutter/material.dart';

class HomeServices extends StatelessWidget {
  const HomeServices({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Homework Solver',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        SizedBox(
          height: 140, // 🔥 control height here
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: const [
              HomeworkCard(
                icon: Icons.auto_awesome_rounded,
                title: 'General',
                colors: [
                  Color(0xFFE0F7FA),
                  Color(0xFFF8BBD0),
                  Color(0xFFFFF9C4),
                ],
              ),
              HomeworkCard(
                icon: Icons.calculate_rounded,
                title: 'Math',
                colors: [Color(0xFFD7CCC8), Color(0xFFC8E6C9)],
              ),
              HomeworkCard(
                icon: Icons.science_rounded,
                title: 'Chemistry',
                colors: [Color(0xFFBBDEFB), Color(0xFF90CAF9)],
              ),
              HomeworkCard(
                icon: Icons.menu_book_rounded,
                title: 'History',
                colors: [Color(0xFFFFE0B2), Color(0xFFFFCCBC)],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class HomeworkCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Color> colors;

  const HomeworkCard({
    super.key,
    required this.icon,
    required this.title,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140, // 🔥 important (fix long issue)
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Stack(
        children: [
          /// ICON (TOP LEFT)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: Colors.black87),
          ),

          /// TITLE (BOTTOM LEFT)
          Positioned(
            bottom: 0,
            left: 0,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
