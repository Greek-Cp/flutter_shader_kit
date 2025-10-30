import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_shader_kit/widgets/frost_blur_layer.dart';

class FrostBlurDemoPage extends StatefulWidget {
  const FrostBlurDemoPage({super.key});

  @override
  State<FrostBlurDemoPage> createState() => _FrostBlurDemoPageState();
}

class _FrostBlurDemoPageState extends State<FrostBlurDemoPage> {
  double _noiseScale = 6.0;
  double _distortion = 0.045;
  double _directionalMix = 0.2;
  double _iterations = 12;
  double _blend = 0.9;
  bool _enabled = true;
  bool _useBackdrop = false;
  bool _circularShape = false;

  static const double _cardHeight = 420;
  static const BorderRadius _cardRadius = BorderRadius.all(Radius.circular(36));

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double maxWidth = screenWidth.clamp(320.0, 520.0).toDouble();
    final double cardWidth =
        _circularShape ? math.min(maxWidth, _cardHeight) : maxWidth;
    final double cardHeight = _circularShape ? cardWidth : _cardHeight;
    final BorderRadius? radius = _circularShape ? null : _cardRadius;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: _buildBackground()),
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 48),
            child: Column(
              children: [
                const SizedBox(height: 56),
                Center(
                  child: SizedBox(
                    width: cardWidth,
                    height: cardHeight,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        FrostBlurLayer(
                          width: cardWidth,
                          height: cardHeight,
                          shape: _circularShape
                              ? BoxShape.circle
                              : BoxShape.rectangle,
                          noiseScale: _noiseScale,
                          distortion: _distortion,
                          directionalMix: _directionalMix,
                          iterations: _iterations,
                          blend: _blend,
                          enabled: _enabled,
                          useBackdrop: _useBackdrop,
                          borderRadius: radius,
                          child: _useBackdrop
                              ? _buildBackdropSurface()
                              : _buildSamplerSurface(),
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
                        label: 'Noise Scale',
                        value: _noiseScale,
                        min: 1,
                        max: 16,
                        divisions: 30,
                        onChanged: (value) =>
                            setState(() => _noiseScale = value),
                      ),
                      _buildSlider(
                        label: 'Distortion',
                        value: _distortion,
                        min: 0,
                        max: 0.12,
                        divisions: 40,
                        onChanged: (value) =>
                            setState(() => _distortion = value),
                      ),
                      _buildSlider(
                        label: 'Directional Mix',
                        value: _directionalMix,
                        min: 0,
                        max: 1,
                        divisions: 20,
                        onChanged: (value) =>
                            setState(() => _directionalMix = value),
                      ),
                      _buildSlider(
                        label: 'Iterations',
                        value: _iterations,
                        min: 1,
                        max: 32,
                        divisions: 31,
                        onChanged: (value) =>
                            setState(() => _iterations = value),
                      ),
                      _buildSlider(
                        label: 'Blend',
                        value: _blend,
                        min: 0,
                        max: 1,
                        divisions: 20,
                        onChanged: (value) => setState(() => _blend = value),
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
                          'Samples true backdrop via ImageFilter.shader',
                        ),
                        value: _useBackdrop,
                        onChanged: !_enabled
                            ? null
                            : (value) => setState(() => _useBackdrop = value),
                      ),
                      SwitchListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 8),
                        title: const Text('Circular aperture'),
                        value: _circularShape,
                        onChanged: (value) =>
                            setState(() => _circularShape = value),
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

  Widget _buildBackground() {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF1F1147),
            Color(0xFF201D35),
            Color(0xFF13253D),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: -90,
            top: 120,
            child: _lightBlob(
              const Color(0xFF7B88FF).withOpacity(0.35),
              280,
            ),
          ),
          Positioned(
            right: -120,
            top: -40,
            child: _lightBlob(
              const Color(0xFF8CE9FF).withOpacity(0.3),
              300,
            ),
          ),
          Positioned(
            right: -80,
            bottom: -100,
            child: _lightBlob(
              const Color(0xFFFA87D0).withOpacity(0.28),
              260,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSamplerSurface() {
    if (_circularShape) {
      return DecoratedBox(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 0.85,
            colors: [
              Color(0xFFE0ECFF),
              Color(0xFFC2DAFF),
              Color(0xFFA3C8FF),
            ],
          ),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.only(top: 48),
                width: 120,
                height: 28,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: Colors.white.withOpacity(0.55),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withOpacity(0.95),
            const Color(0xFFE8F0FF),
            const Color(0xFFCCE5FF),
          ],
        ),
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 48),
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const SweepGradient(
                colors: [
                  Color(0xFFB3C7FF),
                  Color(0xFFCCE5FF),
                  Color(0xFFF4F8FF),
                  Color(0xFFB3C7FF),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackdropSurface() {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: _circularShape ? BoxShape.circle : BoxShape.rectangle,
        color: Colors.white.withOpacity(0.08),
        border: Border.all(
          color: Colors.white.withOpacity(0.18),
          width: 1.2,
        ),
        borderRadius: _circularShape ? null : _cardRadius,
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
            constraints: BoxConstraints(maxWidth: cardWidth * 0.72),
            child: const Text(
              'Frosted Aurora',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.9,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Noise-driven frost distortion with optional real backdrop sampling.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _lightBlob(Color color, double size) {
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
            spreadRadius: size * 0.2,
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
