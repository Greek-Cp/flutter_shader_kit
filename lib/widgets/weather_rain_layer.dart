import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import 'dart:ui' as ui;

import '../utils/shader_utils.dart';

/// WeatherRainLayer
/// A post-process layer that simulates rainy glass refraction and blur over
/// its [child]. Place it in a [Stack] between your background content and any
/// foreground UI you want to keep sharp.
class WeatherRainLayer extends StatefulWidget {
  const WeatherRainLayer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.rainAmount = 0.75,
    this.maxBlur = 6.0,
    this.minBlur = 2.0,
    this.refraction = 40.0,
    this.speed = 1.0,
    this.enabled = true,
    this.useBackdrop = false,
    this.lockToScreen = false,
  })  : assert(rainAmount >= 0.0 && rainAmount <= 1.0),
        assert(maxBlur >= 0.0),
        assert(minBlur >= 0.0),
        assert(maxBlur >= minBlur),
        assert(speed >= 0.0);

  /// Content captured by the shader. Typically matches the area you want the
  /// rainy glass effect to cover.
  final Widget child;

  /// Optional explicit width to enforce on the layer.
  final double? width;

  /// Optional explicit height to enforce on the layer.
  final double? height;

  /// Overall rain intensity (0..1). Drives drop density and motion.
  final double rainAmount;

  /// Maximum blur radius (in pixels) for areas away from drops.
  final double maxBlur;

  /// Minimum blur radius (in pixels) at the drops/trails.
  final double minBlur;

  /// Refraction strength (in pixels) applied to the underlying content.
  final double refraction;

  /// Speed multiplier for the animation timeline.
  final double speed;

  /// When false, bypasses the shader and returns [child] directly.
  final bool enabled;

  /// When true, use BackdropFilter + ImageFilter.shader to sample the
  /// pixels behind this widget (i.e. real backdrop). In this mode, [child]
  /// is rendered as the overlay content and is not used as the sampled image.
  ///
  /// When false (default), the shader samples only the offscreen capture of
  /// its [child] via AnimatedSampler.
  final bool useBackdrop;

  /// When true in non-backdrop mode, the raindrop pattern is anchored to
  /// screen space, so it does not move when this widget scrolls. The effect
  /// is still applied to this widget's [child] only.
  final bool lockToScreen;

  @override
  State<WeatherRainLayer> createState() => _WeatherRainLayerState();
}

class _WeatherRainLayerState extends State<WeatherRainLayer>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  double _timeSeconds = 0.0;
  double _lastElapsed = 0.0;
  Offset _globalOrigin = Offset.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_handleTick);
    if (widget.enabled) {
      _ticker.start();
    }
  }

  @override
  void didUpdateWidget(covariant WeatherRainLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled != widget.enabled) {
      if (widget.enabled) {
        _lastElapsed = 0.0;
        _ticker.start();
      } else {
        _ticker.stop();
      }
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _handleTick(Duration elapsed) {
    final double seconds = elapsed.inMicroseconds / 1e6;
    final double delta = seconds - _lastElapsed;
    _lastElapsed = seconds;
    if (delta <= 0.0) {
      return;
    }
    final double increment = delta * widget.speed;
    if (increment == 0.0) {
      return;
    }
    // Update global origin to keep screen-anchored effect stable when scrolling.
    final renderObject = context.findRenderObject();
    if (renderObject is RenderBox) {
      final Offset origin = renderObject.localToGlobal(Offset.zero);
      _globalOrigin = origin;
    }
    setState(() {
      _timeSeconds += increment;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = widget.child;
    if (widget.width != null || widget.height != null) {
      content = SizedBox(
        width: widget.width,
        height: widget.height,
        child: content,
      );
    }

    if (!widget.enabled) {
      return content;
    }

    if (widget.useBackdrop) {
      // Backdrop mode: filter the scene behind this widget's bounds.
      // Pass screen size to the shader so FlutterFragCoord normalization matches.
      final Size screenSize = MediaQuery.sizeOf(context);
      Widget sized = content;
      if (widget.width != null || widget.height != null) {
        sized = SizedBox(
          width: widget.width,
          height: widget.height,
          child: content,
        );
      }
      return ClipRect(
        child: ShaderBuilder(
          (context, shader, _) {
            // Compute origin every build to handle layout/scroll changes.
            Offset origin = Offset.zero;
            final ro = context.findRenderObject();
            if (ro is RenderBox) {
              origin = ro.localToGlobal(Offset.zero);
            }
            shader.setFloatUniforms((u) {
              u.setSize(screenSize); // resolution = screen for BackdropFilter
              u.setFloat(_timeSeconds);
              u.setFloat(widget.rainAmount);
              u.setFloat(widget.maxBlur);
              u.setFloat(widget.minBlur);
              u.setFloat(widget.refraction);
              u.setSize(screenSize); // screenSize
              u.setOffset(origin); // widgetOrigin
              u.setFloat(widget.lockToScreen ? 1.0 : 0.0); // screenSpaceDrops
            });
            try {
              return BackdropFilter(
                filter: ui.ImageFilter.shader(shader),
                child: sized,
              );
            } on UnsupportedError {
              // Fallback when ImageFilter.shader is not supported (non-Impeller).
              return sized; // graceful no-op
            } catch (_) {
              return sized;
            }
          },
          assetKey: ShaderUtils.getShaderAssetPath('weather_rain_layer.frag'),
        ),
      );
    }

    // Default: sample only the child via offscreen capture.
    return ShaderBuilder(
      (context, shader, _) {
        return AnimatedSampler(
          (image, size, canvas) {
            shader.setFloatUniforms((u) {
              u.setSize(size); // resolution
              u.setFloat(_timeSeconds);
              u.setFloat(widget.rainAmount);
              u.setFloat(widget.maxBlur);
              u.setFloat(widget.minBlur);
              u.setFloat(widget.refraction);
              // Extra uniforms to support screen-anchored drops
              final Size screenSize = MediaQuery.sizeOf(context);
              u.setSize(screenSize); // screenSize
              u.setOffset(_globalOrigin); // widgetOrigin in screen pixels
              u.setFloat(widget.lockToScreen ? 1.0 : 0.0); // screenSpaceDrops
            });
            shader.setImageSampler(0, image);
            canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
          },
          child: content,
        );
      },
      assetKey: ShaderUtils.getShaderAssetPath('weather_rain_layer.frag'),
    );
  }
}
