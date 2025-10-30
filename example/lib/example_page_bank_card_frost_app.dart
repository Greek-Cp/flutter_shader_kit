// Brand logo widget for more visual polish
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_shader_kit/widgets/frost_shader_layer.dart';

class _BrandLogo extends StatelessWidget {
  final String brand;
  const _BrandLogo({required this.brand});

  @override
  Widget build(BuildContext context) {
    switch (brand.toUpperCase()) {
      case 'VISA':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white.withOpacity(0.18),
          ),
          child: Text('VISA',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1.5)),
        );
      case 'MASTERCARD':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFF5F6D),
              ),
            ),
            const SizedBox(width: 2),
            Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFFC371),
              ),
            ),
          ],
        );
      case 'AMEX':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white.withOpacity(0.18),
          ),
          child: Text('AMEX',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1.5)),
        );
      case 'JCB':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white.withOpacity(0.18),
          ),
          child: Text('JCB',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1.5)),
        );
      default:
        return Container();
    }
  }
}

class ExamplePageBankCardFrostApp extends StatefulWidget {
  const ExamplePageBankCardFrostApp({super.key});

  @override
  State<ExamplePageBankCardFrostApp> createState() =>
      _ExamplePageBankCardFrostAppState();
}

class _ExamplePageBankCardFrostAppState
    extends State<ExamplePageBankCardFrostApp> {
  final _frostLayerCtrl = FrostLayerController();
  late final PageController _pageCtrl;
  int _index = 0;
  bool _animating = false;
  Color _backgroundColor = const Color(0xFF2C5364); // initial from first card

  final _cards = const [
    _BankCard(
      background: LinearGradient(
        colors: [Color(0xFF0F0F0F), Color(0xFF1A1A1A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      brand: 'BLACK',
      number: '**** 0000',
      holder: 'Yanuar T.',
      expiry: '01/30',
      logoColor: Colors.white,
    ),
    _BankCard(
      background: LinearGradient(
        colors: [Color(0xFF00C9FF), Color(0xFF92FE9D)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      brand: 'NOVA',
      number: '**** 7788',
      holder: 'Yanuar T.',
      expiry: '09/27',
      logoColor: Colors.white,
    ),
    _BankCard(
      background: LinearGradient(
        colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      brand: 'DISC',
      number: '**** 5566',
      holder: 'Yanuar T.',
      expiry: '07/26',
      logoColor: Colors.white,
    ),

    _BankCard(
      background: LinearGradient(
        colors: [
          Color.fromARGB(255, 82, 12, 61),
          Color.fromARGB(255, 63, 45, 45)
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      brand: 'BLACK',
      number: '**** 0000',
      holder: 'Yanuar T.',
      expiry: '01/30',
      logoColor: Colors.white,
    ),
    // More aesthetic dark + color cards
    _BankCard(
      background: LinearGradient(
        colors: [Color(0xFF001F3F), Color(0xFF003366)], // dark blue
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      brand: 'NAVY',
      number: '**** 4242',
      holder: 'Yanuar T.',
      expiry: '02/28',
      logoColor: Colors.white,
    ),
    _BankCard(
      background: LinearGradient(
        colors: [Color(0xFF0B486B), Color(0xFFF56217)], // teal to orange
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      brand: 'TEALOR',
      number: '**** 1357',
      holder: 'Yanuar T.',
      expiry: '06/29',
      logoColor: Colors.white,
    ),
    _BankCard(
      background: LinearGradient(
        colors: [Color(0xFFFF7E5F), Color(0xFFFEB47B)], // sunrise
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      brand: 'SUN',
      number: '**** 2468',
      holder: 'Yanuar T.',
      expiry: '03/31',
      logoColor: Colors.white,
    ),
    _BankCard(
      background: LinearGradient(
        colors: [Color(0xFFB79891), Color(0xFF94716B)], // rose-gold
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      brand: 'ROSE',
      number: '**** 9090',
      holder: 'Yanuar T.',
      expiry: '10/26',
      logoColor: Colors.white,
    ),

    _BankCard(
      background: LinearGradient(
        colors: [
          Color(0xFFFC5C7D), // pink
          Color(0xFF6A82FB), // blue
          Color(0xFF56CCF2), // cyan
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      brand: 'VISA',
      number: '**** 4821',
      holder: 'Yanuar T.',
      expiry: '12/28',
      logoColor: Colors.white,
    ),
    _BankCard(
      background: LinearGradient(
        colors: [
          Color(0xFFFFB75E), // orange
          Color(0xFFED8F03), // deep orange
          Color(0xFFFC466B), // pink
        ],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ),
      brand: 'Mastercard',
      number: '**** 9913',
      holder: 'Yanuar T.',
      expiry: '08/27',
      logoColor: Colors.white,
    ),
    _BankCard(
      background: LinearGradient(
        colors: [
          Color(0xFF43E97B), // green
          Color(0xFF38F9D7), // teal
          Color(0xFF30Cfd0), // blue
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      brand: 'AMEX',
      number: '**** 2210',
      holder: 'Yanuar T.',
      expiry: '04/29',
      logoColor: Colors.white,
    ),
    _BankCard(
      background: LinearGradient(
        colors: [
          Color(0xFFF7971E), // yellow
          Color(0xFFFF5858), // red
          Color(0xFFDD5E89), // magenta
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      brand: 'JCB',
      number: '**** 3344',
      holder: 'Yanuar T.',
      expiry: '11/30',
      logoColor: Colors.white,
    ),
    // Additional colorful cards
  ];

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController(
      initialPage: 0,
      viewportFraction: 0.88,
    );
    _backgroundColor = _getCardPrimaryColor(_cards[0]);

    // Real-time color transition listener
    _pageCtrl.addListener(() {
      if (!mounted) return;
      double page = _pageCtrl.page ?? 0.0;
      int baseIndex = page.floor().clamp(0, _cards.length - 1);
      int nextIndex = (baseIndex + 1).clamp(0, _cards.length - 1);
      double t = (page - baseIndex).clamp(0.0, 1.0);

      Color baseColor = _getCardPrimaryColor(_cards[baseIndex]);
      Color nextColor = _getCardPrimaryColor(_cards[nextIndex]);
      Color lerped = Color.lerp(baseColor, nextColor, t)!;

      setState(() {
        _backgroundColor = lerped;
      });
    });
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _freezeAndNext() {
    if (_animating) return;
    setState(() => _animating = true);
    // Play overlay frost while page scrolls to next
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _frostLayerCtrl.play();
      final next = (_index + 1) % _cards.length;
      _pageCtrl
          .animateToPage(next,
              duration: const Duration(milliseconds: 2500),
              curve: Curves.easeInOutCubic)
          .whenComplete(() => setState(() {
                _index = next;
              }));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FrostShaderLayer(
          controller: _frostLayerCtrl,
          duration: const Duration(milliseconds: 3000),
          curve: Curves.easeInOutCubic,
          frostiness: 3.55,
          blurAmount: 4.0,
          ringWidth: 1.3,
          ringIrregularity: 0.0,
          ringNoiseScale: 0.4,
          bloomStrength: 0.0,
          bloomWidth: 0.0,
          bloomColor: const Color(0xCCBFE3FF),
          onCompleted: () => setState(() => _animating = false),
          child: _Scene(
            idx: _index,
            cards: _cards,
            backgroundColor: _backgroundColor,
            interactive: !_animating,
            pageController: _pageCtrl,
            onPageChanged: (i) => setState(() => _index = i),
            onFreeze: _freezeAndNext,
            busy: _animating,
          ),
        ),
      ),
    );
  }
}

class _Scene extends StatelessWidget {
  const _Scene({
    required this.idx,
    required this.cards,
    required this.backgroundColor,
    this.interactive = true,
    this.pageController,
    this.onPageChanged,
    this.onFreeze,
    this.busy,
  });

  final int idx;
  final List<_BankCard> cards;
  final Color backgroundColor;
  final bool interactive;
  final PageController? pageController;
  final ValueChanged<int>? onPageChanged;
  final VoidCallback? onFreeze;
  final bool? busy;

  @override
  Widget build(BuildContext context) {
    final cardAspect = 16 / 10;
    return LayoutBuilder(builder: (context, constraints) {
      final width = math.min(constraints.maxWidth, 420.0);
      final height = width / cardAspect;
      return AnimatedContainer(
        duration:
            const Duration(milliseconds: 0), // real-time update via listener
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.lerp(const Color(0xFF0B0F14), backgroundColor, 0.5)!,
              Color.lerp(const Color(0xFF0B0F14), backgroundColor, 0.3)!,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 15,
            ),
            // Fancy App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _FancyAppBar(
                title: 'My Wallet',
                index: idx + 1,
                total: cards.length,
                onMenuTap: () {},
                onSearchTap: () {},
              ),
            ),
            Container(
              width: width,
              height: height + 90,
              child: _PageViewCarousel(
                cards: cards,
                pageController: pageController,
                onPageChanged: interactive ? onPageChanged : null,
                inputEnabled: interactive,
              ),
            ),
            const SizedBox(height: 16),
            // Controls row similar to screenshot
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _IconPill(
                    icon: Icons.ac_unit_rounded,
                    label: 'Freeze Card',
                    onTap: onFreeze,
                    enabled: (busy ?? false) ? false : interactive,
                  ),
                  _IconPill(
                    icon: Icons.visibility_off_rounded,
                    label: 'Hide Details',
                    onTap: () {},
                    enabled: interactive,
                  ),
                  _IconPill(
                    icon: Icons.settings_rounded,
                    label: 'Settings',
                    onTap: () {},
                    enabled: interactive,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Transactions list (dummy)
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  border: Border(
                      top: BorderSide(color: Colors.white.withOpacity(0.06))),
                ),
                child: _TransactionsList(accent: _accentFromCard(cards[idx])),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _IconPill extends StatelessWidget {
  const _IconPill(
      {required this.icon,
      required this.label,
      this.onTap,
      this.enabled = true});
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final bg = Colors.white.withOpacity(enabled ? 0.08 : 0.04);
    final fg = Colors.white.withOpacity(enabled ? 0.92 : 0.5);
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 110,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: fg),
            const SizedBox(height: 6),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: fg, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _FancyAppBar extends StatelessWidget {
  final String title;
  final int index;
  final int total;
  final VoidCallback? onMenuTap;
  final VoidCallback? onSearchTap;

  const _FancyAppBar({
    required this.title,
    required this.index,
    required this.total,
    this.onMenuTap,
    this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: onMenuTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.menu, color: Colors.white),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18)),
              const SizedBox(height: 2),
              Text('$index of $total',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.7), fontSize: 12)),
            ],
          ),
        ),
        InkWell(
          onTap: onSearchTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.search, color: Colors.white),
          ),
        ),
        const SizedBox(width: 8),
        CircleAvatar(
          radius: 18,
          backgroundColor: Colors.white.withOpacity(0.14),
          child: const Icon(Icons.person, color: Colors.white),
        ),
      ],
    );
  }
}

class _TransactionsList extends StatelessWidget {
  const _TransactionsList({required this.accent});
  final Color accent;

  @override
  Widget build(BuildContext context) {
    // Shimmer placeholder for loading state
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        return _ShimmerTransactionItem();
      },
    );
  }
}

class _ShimmerTransactionItem extends StatefulWidget {
  @override
  State<_ShimmerTransactionItem> createState() =>
      _ShimmerTransactionItemState();
}

class _ShimmerTransactionItemState extends State<_ShimmerTransactionItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final shimmerGradient = LinearGradient(
          colors: [
            Colors.white.withOpacity(0.10),
            Colors.white.withOpacity(0.30),
            Colors.white.withOpacity(0.10),
          ],
          stops: const [0.1, 0.5, 0.9],
          begin: Alignment(-1.0 + 2.0 * _controller.value, 0),
          end: Alignment(1.0 + 2.0 * _controller.value, 0),
        );
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: shimmerGradient,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 90,
                      height: 12,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        gradient: shimmerGradient,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 60,
                      height: 10,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        gradient: shimmerGradient,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 40,
                height: 14,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  gradient: shimmerGradient,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Helper to extract primary color from card gradient for background transition
Color _getCardPrimaryColor(_BankCard c) {
  if (c.background is LinearGradient) {
    final lg = c.background as LinearGradient;
    return lg.colors.first;
  }
  return Colors.blueAccent;
}

// PageView-based carousel for smooth scroll tracking
class _PageViewCarousel extends StatelessWidget {
  const _PageViewCarousel({
    required this.cards,
    this.pageController,
    this.onPageChanged,
    this.inputEnabled = true,
  });

  final List<_BankCard> cards;
  final PageController? pageController;
  final ValueChanged<int>? onPageChanged;
  final bool inputEnabled;

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: !inputEnabled,
      child: PageView.builder(
        controller: pageController,
        physics: inputEnabled ? null : const NeverScrollableScrollPhysics(),
        onPageChanged: onPageChanged,
        itemCount: cards.length,
        itemBuilder: (context, i) {
          return AnimatedBuilder(
            animation: pageController!,
            builder: (context, child) {
              double value = 1.0;
              if (pageController!.position.haveDimensions) {
                value = pageController!.page! - i;
                // Scale calculation: center card = 1.0, side cards get smaller
                value = (1 - (value.abs() * 0.3)).clamp(0.9, 1.0);
              }
              return Center(
                child: SizedBox(
                  height: Curves.easeInOut.transform(value) * 250,
                  width: Curves.easeInOut.transform(value) * 400,
                  child: child,
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.30),
                      blurRadius: 22,
                      spreadRadius: -6,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: _CardView(card: cards[i]),
              ),
            ),
          );
        },
      ),
    );
  }
}

Color _accentFromCard(_BankCard c) {
  if (c.background is LinearGradient) {
    final lg = c.background as LinearGradient;
    return lg.colors.first;
  }
  return Colors.blueAccent;
}

class _CardView extends StatelessWidget {
  const _CardView({required this.card});
  final _BankCard card;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Soft blurred gradient shadow derived from the card background
        Positioned.fill(
          child: Center(
            child: Transform.translate(
              offset: const Offset(0, 18),
              child: Transform.scale(
                scale: 1.07,
                child: Opacity(
                  opacity: 0.38,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 22.0, sigmaY: 22.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Container(
                        decoration: BoxDecoration(gradient: card.background),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Foreground card with glassmorphism and overlays
        ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              // Glassmorphism overlay
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.18),
                        Colors.white.withOpacity(0.08),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              // Subtle white highlight
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 38,
                  decoration: BoxDecoration(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(28)),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.22),
                        Colors.transparent,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              // Decorative orbs
              Positioned(
                top: -24,
                right: -18,
                child: _CornerOrbs(color: Colors.white.withOpacity(0.13)),
              ),
              Positioned(
                bottom: -32,
                left: -24,
                child: _CornerOrbs(color: Colors.black.withOpacity(0.10)),
              ),
              // Card content
              Padding(
                padding: const EdgeInsets.all(26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.nfc_rounded,
                            color: Colors.white.withOpacity(0.92), size: 28),
                        const Spacer(),
                        _BrandLogo(brand: card.brand),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      card.number,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontFeatures: [FontFeature.tabularFigures()],
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.w800,
                        shadows: [
                          Shadow(
                            color: Colors.black38,
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('CARD HOLDER',
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 10,
                                    letterSpacing: 1.2)),
                            const SizedBox(height: 4),
                            Text(card.holder,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15)),
                          ],
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('EXPIRES',
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 10,
                                    letterSpacing: 1.2)),
                            const SizedBox(height: 4),
                            Text(card.expiry,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15)),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CornerOrbs extends StatelessWidget {
  const _CornerOrbs({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.4,
      child: Row(
        children: [
          _orb(34),
          const SizedBox(width: 8),
          _orb(16),
          const SizedBox(width: 8),
          _orb(12),
        ],
      ),
    );
  }

  Widget _orb(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.6),
              blurRadius: size * 0.9,
              spreadRadius: -size * 0.2),
        ],
      ),
    );
  }
}

class _BankCard {
  final Gradient background;
  final String brand;
  final String number;
  final String holder;
  final String expiry;
  final Color logoColor;
  const _BankCard({
    required this.background,
    required this.brand,
    required this.number,
    required this.holder,
    required this.expiry,
    required this.logoColor,
  });
}
