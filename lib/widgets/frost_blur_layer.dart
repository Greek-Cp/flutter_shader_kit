import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

import '../utils/shader_utils.dart';

/// A layer widget that applies a frosted glass blur and distortion shader to
/// its [child]. Similar to [FractalBlurLayer], but based on a noise-driven
/// frosty diffusion pattern. Use [shape] and [borderRadius] to clip the output
/// to rounded rectangles or circles.
class FrostBlurLayer extends StatelessWidget {
  const FrostBlurLayer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.shape = BoxShape.rectangle,
    this.noiseScale = 6.0,
    this.distortion = 0.045,
    this.directionalMix = 0.25,
    this.iterations = 12,
    this.blend = 1.0,
    this.enabled = true,
    this.useBackdrop = false,
    this.borderRadius,
  }) : assert(
          shape == BoxShape.rectangle || borderRadius == null,
          'borderRadius only applies when shape is rectangle.',
        );

  /// Content captured by the shader in non-backdrop mode.
  final Widget child;

  /// Optional explicit width of the render area.
  final double? width;

  /// Optional explicit height of the render area.
  final double? height;

  /// Clip shape for the shader output.
  final BoxShape shape;

  /// Frequency of the noise field that defines the frost pattern.
  final double noiseScale;

  /// Overall distortion strength (typical range 0.0–0.08).
  final double distortion;

  /// Mix between vertical streaking (0) and isotropic distortion (1).
  final double directionalMix;

  /// Number of iterative distortion steps (1–32). Higher values = smoother.
  final double iterations;

  /// Mix between original content (0) and fully frosted result (1).
  final double blend;

  /// When false, the shader is bypassed and [child] is returned directly.
  final bool enabled;

  /// When true, renders using [BackdropFilter] so the shader samples from the
  /// scene behind this layer instead of the provided [child].
  final bool useBackdrop;

  /// Optional radius used to clip the shader output when [shape] is rectangle.
  final BorderRadius? borderRadius;

  Widget _clip(Widget child, {bool forceRect = false}) {
    if (shape == BoxShape.circle) {
      return ClipOval(child: child);
    }
    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: child,
      );
    }
    if (forceRect) {
      return ClipRect(child: child);
    }
    return child;
  }

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
      return _clip(sizedChild);
    }

    final Widget clippedChild = _clip(sizedChild);

    if (useBackdrop) {
      return _clip(
        ShaderBuilder(
          (context, shader, _) {
            Size resolution = Size.zero;
            final renderObject = context.findRenderObject();
            if (renderObject is RenderBox && renderObject.hasSize) {
              resolution = renderObject.size;
            }
            if (resolution.isEmpty) {
              final media = MediaQuery.maybeOf(context);
              final size = media?.size;
              resolution = Size(
                width ?? size?.width ?? 0.0,
                height ?? size?.height ?? 0.0,
              );
            }
            if (resolution.width <= 0 || resolution.height <= 0) {
              resolution = const Size(1, 1);
            }

            shader.setFloatUniforms((u) {
              u.setSize(resolution);
              u.setFloat(noiseScale);
              u.setFloat(distortion);
              u.setFloat(directionalMix);
              u.setFloat(iterations);
              u.setFloat(blend);
            });

            try {
              return BackdropFilter(
                filter: ui.ImageFilter.shader(shader),
                child: clippedChild,
              );
            } on UnsupportedError {
              return sizedChild;
            } catch (_) {
              return sizedChild;
            }
          },
          assetKey: ShaderUtils.getShaderAssetPath('frost_blur_layer.frag'),
        ),
        forceRect: true,
      );
    }

    final shaderWidget = ShaderBuilder(
      (context, shader, _) {
        return AnimatedSampler(
          (image, size, canvas) {
            shader.setFloatUniforms((u) {
              u.setSize(size);
              u.setFloat(noiseScale);
              u.setFloat(distortion);
              u.setFloat(directionalMix);
              u.setFloat(iterations);
              u.setFloat(blend);
            });
            shader.setImageSampler(0, image);
            canvas.drawRect(
              Offset.zero & size,
              Paint()..shader = shader,
            );
          },
          child: clippedChild,
        );
      },
      assetKey: ShaderUtils.getShaderAssetPath('frost_blur_layer.frag'),
    );

    return _clip(shaderWidget);
  }
}
