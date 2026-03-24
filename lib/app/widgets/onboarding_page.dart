import 'package:flutter/material.dart';
import '../config/AppTheme.dart' show AppTheme;

class OnboardingPageData {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final IconData secondaryIcon;
  final List<Color> gradientColors;
  final List<String> featureTags;

  const OnboardingPageData({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.secondaryIcon,
    required this.gradientColors,
    required this.featureTags,
  });
}

class OnboardingPageWidget extends StatefulWidget {
  final OnboardingPageData data;
  final bool isVisible;

  const OnboardingPageWidget({
    super.key,
    required this.data,
    required this.isVisible,
  });

  @override
  State<OnboardingPageWidget> createState() => _OnboardingPageWidgetState();
}

class _OnboardingPageWidgetState extends State<OnboardingPageWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnim = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _fadeAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    if (widget.isVisible) _controller.forward();
  }

  @override
  void didUpdateWidget(covariant OnboardingPageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Illustration card
              ScaleTransition(
                scale: _scaleAnim,
                child: Container(
                  width: size.width * 0.75,
                  height: size.width * 0.75,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: widget.data.gradientColors,
                    ),
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: widget.data.gradientColors[0].withOpacity(0.35),
                        blurRadius: 40,
                        offset: const Offset(0, 16),
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Background pattern
                      Positioned(
                        top: -20,
                        right: -20,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -30,
                        left: -30,
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.06),
                          ),
                        ),
                      ),

                      // Main icon
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                widget.data.icon,
                                size: 64,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Secondary floating icon
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ),
                              child: Icon(
                                widget.data.secondaryIcon,
                                size: 24,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Subtitle chip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.data.subtitle,
                  style: const TextStyle(
                    color: AppTheme.primaryBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Title
              Text(
                widget.data.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                ),
              ),

              const SizedBox(height: 14),

              // Description
              Text(
                widget.data.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.textGrey,
                  fontSize: 15,
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 24),

              // Feature tags
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: widget.data.featureTags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.softWhite,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.lightBlue.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        color: AppTheme.accentBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
