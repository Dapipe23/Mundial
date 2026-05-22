import 'dart:ui';

import 'package:flutter/material.dart';

class WorldAuthShell extends StatelessWidget {
  static const String backgroundAssetPath = 'assets/images/world_cup_2026_logo.png';

  final String title;
  final String subtitle;
  final Color accentColor;
  final IconData icon;
  final List<String> chips;
  final Widget formContent;

  const WorldAuthShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.icon,
    required this.chips,
    required this.formContent,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF051224),
                    Color(0xFF05203B),
                    Color(0xFF073A4A),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.84,
                      child: Image.asset(
                        backgroundAssetPath,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF030C1E).withValues(alpha: 0.24),
                    const Color(0xFF07122C).withValues(alpha: 0.36),
                    const Color(0xFF020611).withValues(alpha: 0.64),
                  ],
                ),
              ),
            ),
          ),
          Positioned(top: 24, left: -22, child: _glow(const Color(0xFFFFC857), 140)),
          Positioned(top: 110, right: -20, child: _glow(accentColor, 120)),
          Positioned(bottom: 12, left: -18, child: _glow(const Color(0xFFFB7185), 100)),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: size.height - 36),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(13),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [accentColor, const Color(0xFF8B5CF6), const Color(0xFFFF7A59)]),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: accentColor.withValues(alpha: 0.34),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(icon, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Panini World Hub',
                            style: TextStyle(
                              fontSize: 33,
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Color(0xFFEAF2FF), fontSize: 15, height: 1.32, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: chips.map((chip) => _chip(chip)).toList(),
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF020817).withValues(alpha: 0.30),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
                            boxShadow: [
                              BoxShadow(
                                color: accentColor.withValues(alpha: 0.14),
                                blurRadius: 28,
                                offset: const Offset(0, 16),
                              ),
                            ],
                          ),
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              inputDecorationTheme: InputDecorationTheme(
                                filled: true,
                                fillColor: const Color(0xD6122238),
                                labelStyle: const TextStyle(color: Color(0xFFD8E5FF)),
                                hintStyle: const TextStyle(color: Color(0xFF9CB0D1)),
                                prefixIconColor: const Color(0xFFC0D5FF),
                                suffixIconColor: const Color(0xFFC0D5FF),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(color: accentColor, width: 1.4),
                                ),
                              ),
                            ),
                            child: DefaultTextStyle(
                              style: const TextStyle(color: Colors.white),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      fontSize: 28,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  formContent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glow(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: 0.28), color.withValues(alpha: 0.0)],
        ),
      ),
    );
  }

  Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1D4ED8).withValues(alpha: 0.48),
            const Color(0xFF7C3AED).withValues(alpha: 0.44),
          ],
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(color: Color(0xFFF8FBFF), fontSize: 12.2, fontWeight: FontWeight.w700),
      ),
    );
  }
}
