import 'package:flutter/material.dart';

import '../flutter_shaders.dart'
    show SpreadingFrostImageSwitcher, SpreadingFrostController;

/// SpreadingFrostWidget
///
/// A convenience wrapper around [SpreadingFrostImageSwitcher] that applies the
/// spreading frost transition between two arbitrary widgets (not just images).
///
/// Usage:
///  - Provide the [current] and [next] children.
///  - Hold a [controller] to trigger [play()] when you want to switch.
///
/// All shader parameters are exposed for fine-tuning.
class SpreadingFrostWidget extends StatelessWidget {
  const SpreadingFrostWidget({
    super.key,
    required this.current,
    required this.next,
    this.controller,
    this.duration = const Duration(milliseconds: 900),
    this.curve = Curves.easeInOut,
    this.frostiness = 0.5,
    this.blurAmount = 2.0,
    this.ringWidth = 0.12,
    this.ringIrregularity = 0.25,
    this.ringNoiseScale = 1.0,
    this.bloomStrength = 0.35,
    this.bloomWidth = 10.0,
    this.bloomColor = const Color(0xCCFFFFFF),
    this.onCompleted,
  });

  final Widget current;
  final Widget next;
  final SpreadingFrostController? controller;
  final Duration duration;
  final Curve curve;
  final double frostiness;
  final double blurAmount;
  final double ringWidth;
  final double ringIrregularity;
  final double ringNoiseScale;
  final double bloomStrength;
  final double bloomWidth;
  final Color bloomColor;
  final VoidCallback? onCompleted;

  @override
  Widget build(BuildContext context) {
    return SpreadingFrostImageSwitcher(
      current: current,
      next: next,
      controller: controller,
      duration: duration,
      curve: curve,
      frostiness: frostiness,
      blurAmount: blurAmount,
      ringWidth: ringWidth,
      ringIrregularity: ringIrregularity,
      ringNoiseScale: ringNoiseScale,
      bloomStrength: bloomStrength,
      bloomWidth: bloomWidth,
      bloomColor: bloomColor,
      onCompleted: onCompleted,
    );
  }
}
