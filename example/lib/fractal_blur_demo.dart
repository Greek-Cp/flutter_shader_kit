import 'package:flutter/material.dart';
import 'package:flutter_shader_kit/widgets/fractal_blur_layer.dart';

class FractalBlurDemoPage extends StatefulWidget {
  const FractalBlurDemoPage({super.key});

  @override
  State<FractalBlurDemoPage> createState() => _FractalBlurDemoPageState();
}

class _FractalBlurDemoPageState extends State<FractalBlurDemoPage> {
  double _frequency = 36.0;
  double _refract = 420.0;
  double _split = 1.0;
  double _feather = 0.02;
  double _blurRadius = 16.0;
  double _blurStrength = 0.9;
  bool _enabled = true;
  bool _useBackdrop = false;

  static const double _maxCardWidth = 520;
  static const double _cardHeight = 500;
  static const BorderRadius _cardRadius = BorderRadius.all(Radius.circular(40));

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double cardWidth =
        screenWidth.clamp(320.0, _maxCardWidth).toDouble();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: _buildSceneBackground()),
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 48),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 56),
                Center(
                  child: SizedBox(
                    width: cardWidth,
                    height: _cardHeight,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: _cardRadius,
                          child: FractalBlurLayer(
                            width: cardWidth,
                            height: _cardHeight,
                            frequency: _frequency,
                            refractAmount: _refract,
                            split: _split,
                            feather: _feather,
                            blurRadius: _blurRadius,
                            blurStrength: _blurStrength,
                            enabled: _enabled,
                            useBackdrop: _useBackdrop,
                            child: _useBackdrop
                                ? _buildBackdropGlass()
                                : _buildSamplerSurface(),
                          ),
                        ),
                        _buildForegroundContent(cardWidth),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    children: [
                      _buildSlider(
                        label: 'Frequency',
                        value: _frequency,
                        min: 0,
                        max: 80,
                        divisions: 70,
                        onChanged: (value) =>
                            setState(() => _frequency = value),
                      ),
                      _buildSlider(
                        label: 'Refraction',
                        value: _refract,
                        min: 0,
                        max: 800,
                        divisions: 70,
                        onChanged: (value) =>
                            setState(() => _refract = value),
                      ),
                      _buildSlider(
                        label: 'Blur Radius',
                        value: _blurRadius,
                        min: 0,
                        max: 40,
                        divisions: 40,
                        onChanged: (value) =>
                            setState(() => _blurRadius = value),
                      ),
                      _buildSlider(
                        label: 'Blur Strength',
                        value: _blurStrength,
                        min: 0,
                        max: 1,
                        divisions: 20,
                        onChanged: (value) =>
                            setState(() => _blurStrength = value),
                      ),
                      _buildSlider(
                        label: 'Split',
                        value: _split,
                        min: 0,
                        max: 1,
                        divisions: 20,
                        onChanged: (value) => setState(() => _split = value),
                      ),
                      _buildSlider(
                        label: 'Feather',
                        value: _feather,
                        min: 0.0,
                        max: 100,
                        divisions: 20,
                        onChanged: (value) => setState(() => _feather = value),
                      ),
                      SwitchListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 8),
                        title: const Text('Enable shader'),
                        value: _enabled,
                        onChanged: (value) => setState(() => _enabled = value),
                      ),
                      SwitchListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 8),
                        title: const Text('Backdrop filter mode'),
                        subtitle: const Text(
                          'Requires ImageFilter.shader support (Impeller)',
                        ),
                        value: _useBackdrop,
                        onChanged: !_enabled
                            ? null
                            : (value) => setState(() => _useBackdrop = value),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSceneBackground() {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF14162E),
            Color(0xFF261C39),
            Color(0xFF3A2A72),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: -60,
            top: 140,
            child: _backgroundBlob(
              const Color(0xFF9775FA).withOpacity(0.45),
              260,
            ),
          ),
          Positioned(
            right: -80,
            top: -40,
            child: _backgroundBlob(
              const Color(0xFFFF6B6B).withOpacity(0.35),
              220,
            ),
          ),
          Positioned(
            right: -120,
            bottom: -60,
            child: _backgroundBlob(
              const Color(0xFF4C6EF5).withOpacity(0.3),
              280,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSamplerSurface() {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF4C6EF5),
            Color(0xFF9775FA),
            Color(0xFFFF6B6B),
          ],
        ),
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Container(
            height: 280,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(96),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFFFFFF),
                  Color(0xFFFBF1FF),
                  Color(0xFFFDECEF),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackdropGlass() {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.00),
        border: Border.all(
          color: Colors.white.withOpacity(0.0),
          width: 1.5,
        ),
      ),
      child: const SizedBox.expand(),
    );
  }

  Widget _buildForegroundContent(double cardWidth) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: cardWidth * 0.7),
            child: const Text(
              'Hello world test',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Fractal blur layer demo',
            style: TextStyle(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _backgroundBlob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size),
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: size * 0.55,
            spreadRadius: size * 0.18,
          ),
        ],
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    int? divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 4, top: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                value.toStringAsFixed(2),
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
