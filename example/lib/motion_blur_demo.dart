import 'package:flutter/material.dart';
import 'package:flutter_shader_kit/widgets/motion_blur_layer.dart';

class MotionBlurDemoPage extends StatefulWidget {
  const MotionBlurDemoPage({super.key});

  @override
  State<MotionBlurDemoPage> createState() => _MotionBlurDemoPageState();
}

class _MotionBlurDemoPageState extends State<MotionBlurDemoPage> {
  final PageController _pc = PageController(viewportFraction: 0.78);

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Motion Blur Layer')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF5F7FA), Color(0xFFE8EAF6)],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              const Text(
                'ListView (scroll to see motion blur)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 160,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return _ClickableHorizontalCard(index: index);
                  },
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemCount: 20,
                ),
              ),

              const SizedBox(height: 28),
              const Text(
                'Vertical List (scroll inside)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 420,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return _ClickableVerticalTile(index: index);
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemCount: 30,
                ),
              ),

              const SizedBox(height: 28),
              const Text(
                'Carousel (PageView)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 240,
                child: PageView.builder(
                  controller: _pc,
                  physics: const BouncingScrollPhysics(),
                  itemCount: 6,
                  itemBuilder: (context, index) {
                    return AnimatedBuilder(
                      animation: _pc,
                      builder: (context, child) {
                        double page = 0.0;
                        if (_pc.positions.isNotEmpty && _pc.hasClients) {
                          page = _pc.page ?? _pc.initialPage.toDouble();
                        }
                        final dist = (index - page).abs();
                        final scale = 0.92 + (1 - dist.clamp(0.0, 1.0)) * 0.08;
                        return Center(
                          child: Transform.scale(
                            scale: scale,
                            child: child,
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: MotionBlurLayer(
                          child: _CarouselCard(index: index),
                        ),
                      ),
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

class _ClickableHorizontalCard extends StatefulWidget {
  const _ClickableHorizontalCard({required this.index});
  final int index;

  @override
  State<_ClickableHorizontalCard> createState() => _ClickableHorizontalCardState();
}

class _ClickableHorizontalCardState extends State<_ClickableHorizontalCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final w = _expanded ? 200.0 : 140.0;
    final h = _expanded ? 190.0 : 160.0;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: MotionBlurLayer(
        child: GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeInOut,
            width: w,
            height: h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  Colors.primaries[widget.index % Colors.primaries.length].shade400,
                  Colors.primaries[widget.index % Colors.primaries.length].shade700,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _expanded ? 'Tap to shrink' : '#${widget.index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CarouselCard extends StatelessWidget {
  const _CarouselCard({required this.index});
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Colors.accents[index % Colors.accents.length].withOpacity(0.9),
            Colors.accents[(index + 3) % Colors.accents.length].withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
        
        ],
      ),
      child: Center(
        child: Text(
          'Card ${index + 1}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
    );
  }
}

class _ClickableVerticalTile extends StatefulWidget {
  const _ClickableVerticalTile({required this.index});
  final int index;

  @override
  State<_ClickableVerticalTile> createState() => _ClickableVerticalTileState();
}

class _ClickableVerticalTileState extends State<_ClickableVerticalTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final h = _expanded ? 120.0 : 80.0;
    final thumb = _expanded ? 100.0 : 80.0;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: MotionBlurLayer(
        child: GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeInOut,
            height: h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeInOut,
                  width: thumb,
                  height: thumb,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.primaries[widget.index % Colors.primaries.length].shade400,
                        Colors.primaries[widget.index % Colors.primaries.length].shade700,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Item ${widget.index + 1}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _expanded
                            ? 'Tap untuk mengecilkan (cek blur saat resize)'
                            : 'Tap untuk membesar (cek blur saat resize)',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF718096),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


