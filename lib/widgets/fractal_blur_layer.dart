import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

import '../utils/shader_utils.dart';

/// A reusable layer widget that applies the fractal blur "reeded glass" shader
/// to its [child]. Place it in a [Stack] above your background content and
/// below any foreground UI.
class FractalBlurLayer extends StatelessWidget {
  const FractalBlurLayer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.frequency = 40.0,
    this.refractAmount = 500.0,
    this.split = 1.0,
    this.feather = 0.003,
    this.blurRadius = 20.0,
    this.blurStrength = 1.0,
    this.enabled = true,
    this.useBackdrop = false,
  });

  /// Content that is sampled by the shader. This should match the area you want
  /// the effect to cover.
  final Widget child;

  /// Optional explicit width of the layer.
  final double? width;

  /// Optional explicit height of the layer.
  final double? height;

  /// Number of vertical ridges in the reeded glass profile.
  final double frequency;

  /// Refractive strength in pixels.
  final double refractAmount;

  /// Blend position between processed (left) and original (right) image.
  final double split;

  /// Softness of the split transition.
  final double feather;

  /// Horizontal blur radius applied inside the glass.
  final double blurRadius;

  /// Mix factor between pure refraction (0) and full blur (1).
  final double blurStrength;

  /// If false, bypasses the shader and returns [child] as-is.
  final bool enabled;

  /// When true, wraps [child] in an [ImageFilter.shader] via [BackdropFilter]
  /// so the effect samples the pixels behind this layer instead of the child.
  final bool useBackdrop;

  @override
  Widget build(BuildContext context) {
    Widget sizedChild = child;
    if (width != null || height != null) {
      sizedChild = SizedBox(
        width: width,
        height: height,
        child: sizedChild,
      );
    }

    if (!enabled) {
      return sizedChild;
    }

    if (useBackdrop) {
      return ClipRect(
        child: ShaderBuilder(
          (context, shader, _) {
            Size resolution = Size.zero;
            final renderObject = context.findRenderObject();
            if (renderObject is RenderBox && renderObject.hasSize) {
              resolution = renderObject.size;
            }
            if (resolution.isEmpty) {
              final mediaQuery = MediaQuery.maybeOf(context);
              final mediaSize = mediaQuery?.size;
              resolution = Size(
                width ?? mediaSize?.width ?? 0.0,
                height ?? mediaSize?.height ?? 0.0,
              );
            }
            if (resolution.width <= 0 || resolution.height <= 0) {
              resolution = const Size(1, 1);
            }

            shader.setFloatUniforms((u) {
              u.setSize(resolution);
              u.setFloat(frequency);
              u.setFloat(refractAmount);
              u.setFloat(split);
              u.setFloat(feather);
              u.setFloat(blurRadius);
              u.setFloat(blurStrength);
            });

            try {
              return BackdropFilter(
                filter: ui.ImageFilter.shader(shader),
                child: sizedChild,
              );
            } on UnsupportedError {
              return sizedChild;
            } catch (_) {
              return sizedChild;
            }
          },
          assetKey: ShaderUtils.getShaderAssetPath('fractal_blur_layer.frag'),
        ),
      );
    }

    return ShaderBuilder(
      (context, shader, _) {
        return AnimatedSampler(
          (image, size, canvas) {
            shader.setFloatUniforms((u) {
              u.setSize(size);
              u.setFloat(frequency);
              u.setFloat(refractAmount);
              u.setFloat(split);
              u.setFloat(feather);
              u.setFloat(blurRadius);
              u.setFloat(blurStrength);
            });
            shader.setImageSampler(0, image);
            canvas.drawRect(
              Offset.zero & size,
              Paint()..shader = shader,
            );
          },
          child: sizedChild,
        );
      },
      assetKey: ShaderUtils.getShaderAssetPath('fractal_blur_layer.frag'),
    );
  }
}
