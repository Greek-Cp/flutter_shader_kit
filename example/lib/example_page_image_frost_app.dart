import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_shader_kit/widgets/spreading_frost_image_switcher.dart';

/// Aesthetic full-screen memories viewer using the Spreading Frost transition.
class ExamplePageImageFrostApp extends StatefulWidget {
  const ExamplePageImageFrostApp({super.key});

  @override
  State<ExamplePageImageFrostApp> createState() =>
      _ExamplePageImageFrostAppState();
}

class _ExamplePageImageFrostAppState extends State<ExamplePageImageFrostApp>
    with SingleTickerProviderStateMixin {
  final _controller = SpreadingFrostController();
  bool _isPlaying = false;

  final List<_MemoryPhoto> _photos = const [
    _MemoryPhoto(
      path: 'assets/images/a.jpg',
      title: 'Blue Hour by the Lake',
      subtitle: 'Hallstatt, Austria — Oct 2019',
    ),
    _MemoryPhoto(
      path: 'assets/images/b.jpg',
      title: 'Soft Dawn Light',
      subtitle: 'Yamanashi, Japan — Apr 2018',
    ),
    _MemoryPhoto(
      path: 'assets/images/c.jpg',
      title: 'Whispers of the Valley',
      subtitle: 'Dolomites, Italy — Sep 2020',
    ),
    _MemoryPhoto(
      path: 'assets/images/d.jpg',
      title: 'Golden Fields',
      subtitle: 'Provence, France — Jun 2017',
    ),
    _MemoryPhoto(
      path: 'assets/images/e.jpg',
      title: 'Sea Breeze',
      subtitle: 'Cornwall, UK — Aug 2021',
    ),
    _MemoryPhoto(
      path: 'assets/images/f.jpg',
      title: 'Sunrise at the Shore',
      subtitle: 'Bali, Indonesia — May 2020',
    ),
    _MemoryPhoto(
      path: 'assets/images/g.jpg',
      title: 'City Skyline at Dusk',
      subtitle: 'Hong Kong — Nov 2019',
    ),
    _MemoryPhoto(
      path: 'assets/images/h.jpg',
      title: 'Cobblestone Alleyway',
      subtitle: 'Prague, Czechia — Sep 2018',
    ),
  ];

  int _current = 0;
  int _next = 1;

  void _prepareNext() {
    _next = (_current + 1) % _photos.length;
  }

  void _advance() {
    if (_isPlaying) return;
    setState(() {
      _isPlaying = true;
      _prepareNext();
    });
    _controller.play();
  }

  void _select(int index) {
    if (_isPlaying || index == _current) return;
    setState(() {
      _isPlaying = true;
      _next = index;
    });
    _controller.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _advance,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(constraints.maxWidth, constraints.maxHeight);
            final current = _photos[_current];
            final next = _photos[_next];

            return Stack(
              fit: StackFit.expand,
              children: [
                // Background gradient scrim for subtle vignette
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.35),
                        Colors.transparent,
                        Colors.black.withOpacity(0.45),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),

                // Frost transition layer (images full-screen)
                SpreadingFrostImageSwitcher(
                  controller: _controller,
                  duration: const Duration(milliseconds: 3000),
                  curve: Curves.linear,
                  frostiness: 3.65,
                  blurAmount: 3.0,
                  ringWidth: 0.43,
                  ringIrregularity: 0.0,
                  ringNoiseScale: 3.1,
                  bloomStrength: 0,
                  bloomWidth: 0,
                  current: Image.asset(current.path,
                      fit: BoxFit.cover,
                      width: size.width,
                      height: size.height),
                  next: Image.asset(next.path,
                      fit: BoxFit.cover,
                      width: size.width,
                      height: size.height),
                  onCompleted: () {
                    setState(() {
                      _current = _next;
                      _isPlaying = false;
                      _prepareNext();
                    });
                  },
                ),

                // Top-left info card with glassy look
                SafeArea(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 340),
                        child: _InfoGlass(
                          key: ValueKey('info-${_photos[_current].path}'),
                          title: _photos[_current].title,
                          subtitle: _photos[_current].subtitle,
                        ),
                      ),
                    ),
                  ),
                ),

                // Bottom-centered thumbnail strip (above controls)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 90.0),
                      child: _ThumbStrip(
                        photos: _photos,
                        currentIndex: _current,
                        onSelect: _select,
                      ),
                    ),
                  ),
                ),

                // Bottom controls: label + next button
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _SoftPill(
                            child: Row(
                              children: [
                                const Icon(Icons.image_outlined,
                                    size: 18, color: Colors.white70),
                                const SizedBox(width: 8),
                                Text(
                                  '${_current + 1} / ${_photos.length}',
                                  style: const TextStyle(
                                      color: Colors.white, letterSpacing: 0.4),
                                ),
                              ],
                            ),
                          ),
                          _SoftPill(
                            onTap: _advance,
                            child: Row(
                              children: const [
                                Text('Next memory',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600)),
                                SizedBox(width: 10),
                                Icon(Icons.arrow_forward_rounded,
                                    color: Colors.white),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MemoryPhoto {
  final String path;
  final String title;
  final String subtitle;
  const _MemoryPhoto(
      {required this.path, required this.title, required this.subtitle});
}

class _InfoGlass extends StatelessWidget {
  const _InfoGlass({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            border: Border.all(color: Colors.white.withOpacity(0.14)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12.5,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SoftPill extends StatelessWidget {
  const _SoftPill({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: child,
    );
    if (onTap == null) return pill;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: pill,
    );
  }
}

class _ThumbStrip extends StatelessWidget {
  const _ThumbStrip(
      {required this.photos,
      required this.currentIndex,
      required this.onSelect});

  final List<_MemoryPhoto> photos;
  final int currentIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.28),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.38)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 16),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < photos.length; i++) ...[
                _ThumbItem(
                  path: photos[i].path,
                  selected: i == currentIndex,
                  onTap: () => onSelect(i),
                ),
                if (i != photos.length - 1) const SizedBox(width: 8),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ThumbItem extends StatelessWidget {
  const _ThumbItem(
      {required this.path, required this.selected, required this.onTap});

  final String path;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? Colors.white : Colors.white54;
    final borderWidth = selected ? 2.0 : 1.0;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: borderColor.withOpacity(selected ? 0.9 : 0.6),
              width: borderWidth),
        ),
        clipBehavior: Clip.antiAlias,
        child: AnimatedOpacity(
          opacity: selected ? 1.0 : 0.6,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          child: Image.asset(path, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
