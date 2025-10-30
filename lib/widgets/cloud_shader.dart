import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

import '../utils/shader_utils.dart';

/// Available cloud shader styles.
enum CloudShaderStyle {
  realistic,
  toon,
}

/// Available preset color palettes for the cloud shaders.
enum CloudColorPreset {
  /// Default bright daytime palette.
  standard,

  /// Darker, desaturated storm clouds.
  stormy,
}

/// A reusable animated cloud background powered by fragment shaders.
///
/// Wrap any widget with [CloudShader] to render animated clouds behind it.
/// You can choose between a noise-based realistic style or a stylised toon
/// look through [style].
class CloudShader extends StatefulWidget {
  const CloudShader({
    super.key,
    this.style = CloudShaderStyle.realistic,
    this.child,
    this.width,
    this.height,
    this.enabled = true,
    this.animate = true,
    this.animationSpeed = 1.0,
    this.cloudDensity = 1.0,
    this.noisiness = 0.35,
    this.flowSpeed = 0.1,
    this.cloudHeight = 2.5,
    this.brightness = 1.0,
    this.colorPreset = CloudColorPreset.stormy,
    this.windSpeed = 1.0,
    this.blurScale = 1.0,
    this.skyColor,
    this.cloudColor,
    this.opacity = 1.0,
  })  : assert(animationSpeed >= 0.0),
        assert(cloudDensity >= 0.0),
        assert(noisiness >= 0.0),
        assert(flowSpeed >= 0.0),
        assert(cloudHeight >= 0.0),
        assert(brightness >= 0.0),
        assert(windSpeed >= 0.0),
        assert(blurScale >= 0.0),
        assert(opacity >= 0.0 && opacity <= 1.0);

  /// Determines which shader asset to use.
  final CloudShaderStyle style;

  /// Optional child rendered on top of the cloud background.
  final Widget? child;

  /// Optional explicit width.
  final double? width;

  /// Optional explicit height.
  final double? height;

  /// When false, the shader is bypassed and only [child] is shown.
  final bool enabled;

  /// Controls whether the shader timeline animates.
  final bool animate;

  /// Multiplier applied to the timeline progression.
  final double animationSpeed;

  /// Realistic style: overall density of the clouds.
  final double cloudDensity;

  /// Realistic style: strength of the offset noise.
  final double noisiness;

  /// Realistic style: noise scroll speed used inside the shader.
  final double flowSpeed;

  /// Realistic style: inverse height of the vertical gradient.
  final double cloudHeight;

  /// Realistic style: overall brightness multiplier.
  final double brightness;

  /// Pre-configured color palette for both cloud styles.
  final CloudColorPreset colorPreset;

  /// Toon style: wind speed multiplier that drives horizontal motion.
  final double windSpeed;

  /// Toon style: scales the blur threshold for the puff shapes.
  final double blurScale;

  /// Base sky color; defaults depend on [style].
  final Color? skyColor;

  /// Primary cloud color; defaults depend on [style].
  final Color? cloudColor;

  /// Overall opacity of the cloud layer (0 = fully transparent, 1 = opaque).
  final double opacity;

  @override
  State<CloudShader> createState() => _CloudShaderState();
}

class _CloudShaderState extends State<CloudShader>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  double _timeSeconds = 0.0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_handleTick);
    if (widget.enabled && widget.animate) {
      _ticker.start();
    }
  }

  @override
  void didUpdateWidget(covariant CloudShader oldWidget) {
    super.didUpdateWidget(oldWidget);
    final bool shouldAnimate = widget.enabled && widget.animate;
    final bool wasAnimating = oldWidget.enabled && oldWidget.animate;
    if (shouldAnimate && !wasAnimating) {
      _ticker.start();
    } else if (!shouldAnimate && wasAnimating) {
      _ticker.stop();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _handleTick(Duration elapsed) {
    if (!widget.animate || !widget.enabled) {
      return;
    }
    setState(() {
      _timeSeconds = elapsed.inMicroseconds / 1e6;
    });
  }

  Color get _effectiveSkyColor {
    if (widget.skyColor != null) {
      return widget.skyColor!;
    }
    switch (widget.colorPreset) {
      case CloudColorPreset.standard:
        switch (widget.style) {
          case CloudShaderStyle.realistic:
            return const Color(0xFF4066B8);
          case CloudShaderStyle.toon:
            return const Color(0xFF006699);
        }
      case CloudColorPreset.stormy:
        switch (widget.style) {
          case CloudShaderStyle.realistic:
            return const Color(0xFF152441);
          case CloudShaderStyle.toon:
            return const Color(0xFF003243);
        }
    }
  }

  Color get _effectiveCloudColor {
    if (widget.cloudColor != null) {
      return widget.cloudColor!;
    }
    switch (widget.colorPreset) {
      case CloudColorPreset.standard:
        switch (widget.style) {
          case CloudShaderStyle.realistic:
            return const Color(0xFFEFF6FF);
          case CloudShaderStyle.toon:
            return const Color(0xFF2EB3DE);
        }
      case CloudColorPreset.stormy:
        switch (widget.style) {
          case CloudShaderStyle.realistic:
            return const Color(0xFF6F8292);
          case CloudShaderStyle.toon:
            return const Color(0xFF3A6C8A);
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double time = _timeSeconds * widget.animationSpeed;

    Widget content;
    if (!widget.enabled) {
      content = DecoratedBox(
        decoration: BoxDecoration(color: _effectiveSkyColor),
        child: widget.child,
      );
    } else {
      final String assetName = widget.style == CloudShaderStyle.realistic
          ? 'cloud_2d_realistic_shader.frag'
          : 'cloud_2d_toon_shader.frag';

      content = ShaderBuilder(
        (context, shader, child) {
          return Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(
                painter: _CloudPainter(
                  shader: shader,
                  style: widget.style,
                  time: time,
                  cloudDensity: widget.cloudDensity,
                  noisiness: widget.noisiness,
                  flowSpeed: widget.flowSpeed,
                  cloudHeight: widget.cloudHeight,
                  brightness: widget.brightness,
                  windSpeed: widget.windSpeed,
                  blurScale: widget.blurScale,
                  skyColor: _effectiveSkyColor,
                  cloudColor: _effectiveCloudColor,
                  opacity: widget.opacity,
                ),
              ),
              if (child != null) Positioned.fill(child: child),
            ],
          );
        },
        assetKey: ShaderUtils.getShaderAssetPath(assetName),
        child: widget.child,
      );
    }

    if (widget.width != null || widget.height != null) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: content,
      );
    }

    return content;
  }
}

class _CloudPainter extends CustomPainter {
  _CloudPainter({
    required this.shader,
    required this.style,
    required this.time,
    required this.cloudDensity,
    required this.noisiness,
    required this.flowSpeed,
    required this.cloudHeight,
    required this.brightness,
    required this.windSpeed,
    required this.blurScale,
    required this.skyColor,
    required this.cloudColor,
    required this.opacity,
  });

  final FragmentShader shader;
  final CloudShaderStyle style;
  final double time;
  final double cloudDensity;
  final double noisiness;
  final double flowSpeed;
  final double cloudHeight;
  final double brightness;
  final double windSpeed;
  final double blurScale;
  final Color skyColor;
  final Color cloudColor;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    shader.setFloatUniforms((u) {
      u.setSize(size);
      u.setFloat(time.toDouble());
      if (style == CloudShaderStyle.realistic) {
        u.setFloat(cloudDensity);
        u.setFloat(noisiness);
        u.setFloat(flowSpeed);
        u.setFloat(cloudHeight);
        u.setFloats([
          skyColor.r,
          skyColor.g,
          skyColor.b,
        ]);
        u.setFloats([
          cloudColor.r,
          cloudColor.g,
          cloudColor.b,
        ]);
        u.setFloat(brightness);
        u.setFloat(opacity);
      } else {
        u.setFloat(windSpeed);
        u.setFloats([
          skyColor.r,
          skyColor.g,
          skyColor.b,
        ]);
        u.setFloats([
          cloudColor.r,
          cloudColor.g,
          cloudColor.b,
        ]);
        u.setFloat(blurScale);
        u.setFloat(opacity);
      }
    });

    canvas.drawRect(
      Offset.zero & size,
      Paint()..shader = shader,
    );
  }

  @override
  bool shouldRepaint(covariant _CloudPainter oldDelegate) {
    return oldDelegate.time != time ||
        oldDelegate.style != style ||
        oldDelegate.cloudDensity != cloudDensity ||
        oldDelegate.noisiness != noisiness ||
        oldDelegate.flowSpeed != flowSpeed ||
        oldDelegate.cloudHeight != cloudHeight ||
        oldDelegate.brightness != brightness ||
        oldDelegate.windSpeed != windSpeed ||
        oldDelegate.blurScale != blurScale ||
        oldDelegate.skyColor != skyColor ||
        oldDelegate.cloudColor != cloudColor ||
        oldDelegate.opacity != opacity;
  }
}
