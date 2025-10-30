// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'example_page_image_frost_app.dart';
import 'example_page_bank_card_frost_app.dart';
import 'note_app_demo.dart';
import 'fractal_blur_demo.dart';
import 'frost_blur_demo.dart';
import 'weather_rain_demo.dart';
import 'motion_blur_demo.dart';
import 'cloud_shader_demo.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Shaders Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const RootDemoPage(),
      routes: {
        '/frost': (_) => const ExamplePageImageFrostApp(),
        '/bank-card': (_) => const ExamplePageBankCardFrostApp(),
        '/note-app': (_) => const NoteAppDemo(),
        '/fractal-blur': (_) => const FractalBlurDemoPage(),
        '/frost-blur': (_) => const FrostBlurDemoPage(),
        '/weather-rain': (_) => const WeatherRainDemoPage(),
        '/motion-blur': (_) => const MotionBlurDemoPage(),
        '/cloud-shader': (_) => const CloudShaderDemoPage(),
      },
    );
  }
}

class RootDemoPage extends StatelessWidget {
  const RootDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem(
        icon: Icons.water_drop_rounded,
        title: 'Liquid Glass Demo',
        subtitle: 'Full-container glass/refraction',
        route: '/glass',
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
      ),
      _NavItem(
        icon: Icons.camera_alt_rounded,
        title: 'Memories (Frost Spread)',
        subtitle: 'Full-screen image story with frost transition',
        route: '/frost',
        gradient: const LinearGradient(
          colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
        ),
      ),
      _NavItem(
        icon: Icons.credit_card_rounded,
        title: 'Bank Card Frost',
        subtitle: 'Freeze animation swaps to a new card',
        route: '/bank-card',
        gradient: const LinearGradient(
          colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
        ),
      ),
      _NavItem(
        icon: Icons.note_rounded,
        title: 'Note App',
        subtitle: 'Simple beautiful note app with paper-like design',
        route: '/note-app',
        gradient: const LinearGradient(
          colors: [Color(0xFFfa709a), Color(0xFFfee140)],
        ),
      ),
      _NavItem(
        icon: Icons.blur_on_rounded,
        title: 'Fractal Blur Layer',
        subtitle: 'Reeded glass shader overlay with controls',
        route: '/fractal-blur',
        gradient: const LinearGradient(
          colors: [Color(0xFF4C6EF5), Color(0xFFFF6B6B)],
        ),
      ),
      _NavItem(
        icon: Icons.ac_unit_rounded,
        title: 'Frost Blur Layer',
        subtitle: 'Noise-driven frost distortion and blur',
        route: '/frost-blur',
        gradient: const LinearGradient(
          colors: [Color(0xFF7B88FF), Color(0xFF8CE9FF)],
        ),
      ),
      _NavItem(
        icon: Icons.cloud,
        title: 'Weather Rain Layer',
        subtitle: 'Animated rainy glass overlay',
        route: '/weather-rain',
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
        ),
      ),
      _NavItem(
        icon: Icons.flash_on_rounded,
        title: 'Motion Blur Layer',
        subtitle: 'Velocity-based temporal smearing',
        route: '/motion-blur',
        gradient: const LinearGradient(
          colors: [Color(0xFF15F1FF), Color(0xFF4154FF)],
        ),
      ),
      _NavItem(
        icon: Icons.cloud_queue,
        title: 'Cloud Shader',
        subtitle: 'Realistic & toon-style animated skies',
        route: '/cloud-shader',
        gradient: const LinearGradient(
          colors: [Color(0xFF0F2027), Color(0xFF2C5364)],
        ),
      ),
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF5F7FA),
              Color(0xFFE8EAF6),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF667EEA).withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Flutter Shaders',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D3748),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Beautiful shader effects',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF718096),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Demo Cards
              Expanded(
                child: ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _DemoCard(
                      item: item,
                      onTap: () => Navigator.of(context).pushNamed(item.route),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DemoCard extends StatefulWidget {
  final _NavItem item;
  final VoidCallback onTap;

  const _DemoCard({
    required this.item,
    required this.onTap,
  });

  @override
  State<_DemoCard> createState() => _DemoCardState();
}

class _DemoCardState extends State<_DemoCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(_isHovered ? 0.15 : 0.08),
                      blurRadius: _isHovered ? 24 : 16,
                      offset: Offset(0, _isHovered ? 8 : 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Gradient Icon Section
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: widget.item.gradient,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                        ),
                      ),
                      child: Icon(
                        widget.item.icon,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    // Content Section
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.item.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.item.subtitle,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF718096),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Arrow Icon
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        transform: Matrix4.identity()
                          ..translate(_isHovered ? 4.0 : 0.0, 0.0),
                        child: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Color(0xFF718096),
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final String route;
  final Gradient gradient;

  const _NavItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
    required this.gradient,
  });
}
