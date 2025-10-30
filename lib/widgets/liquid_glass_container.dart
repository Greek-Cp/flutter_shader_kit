// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import '../utils/shader_utils.dart';

/// A container widget with liquid glass effect, similar to Container but with glass styling.
///
/// This widget applies a liquid glass shader effect to the container's decoration,
/// with the child rendered on top just like a normal Container.
///
/// Example:
/// ```dart
/// LiquidGlassContainer(
///   width: 300,
///   height: 200,
///   padding: EdgeInsets.all(20),
///   decoration: BoxDecoration(
///     gradient: LinearGradient(
///       colors: [Colors.blue, Colors.purple],
///     ),
///   ),
///   child: Text('Hello Glass!'),
/// )
/// ```
class LiquidGlassContainer extends StatelessWidget {
  /// Creates a liquid glass container widget.
  const LiquidGlassContainer({
    super.key,
    this.alignment,
    this.padding,
    this.color,
    this.decoration,
    this.foregroundDecoration,
    this.width,
    this.height,
    this.constraints,
    this.margin,
    this.transform,
    this.transformAlignment,
    this.child,
    this.clipBehavior = Clip.antiAlias,
    this.glassEnabled = true,
    this.glassPosition,
  });

  /// Align the [child] within the container.
  final AlignmentGeometry? alignment;

  /// Empty space to inscribe inside the [decoration]. The [child], if any, is
  /// placed inside this padding.
  final EdgeInsetsGeometry? padding;

  /// The color to paint behind the [child].
  final Color? color;

  /// The decoration to paint behind the [child].
  final Decoration? decoration;

  /// The decoration to paint in front of the [child].
  final Decoration? foregroundDecoration;

  /// Width of the container.
  final double? width;

  /// Height of the container.
  final double? height;

  /// Additional constraints to apply to the child.
  final BoxConstraints? constraints;

  /// Empty space to surround the [decoration] and [child].
  final EdgeInsetsGeometry? margin;

  /// The transformation matrix to apply before painting the container.
  final Matrix4? transform;

  /// The alignment of the origin, relative to the size of the container.
  final AlignmentGeometry? transformAlignment;

  /// The [child] contained by the container.
  final Widget? child;

  /// The clip behavior when [Container.decoration] is not null.
  final Clip clipBehavior;

  /// Whether the glass effect is enabled. If false, acts like a normal Container.
  final bool glassEnabled;

  /// Position of the glass effect (deprecated - no longer used).
  @Deprecated('Glass effect now covers full container automatically')
  final Offset? glassPosition;

  @override
  Widget build(BuildContext context) {
    // If glass is disabled, just use normal Container
    if (!glassEnabled) {
      return Container(
        alignment: alignment,
        padding: padding,
        color: color,
        decoration: decoration,
        foregroundDecoration: foregroundDecoration,
        width: width,
        height: height,
        constraints: constraints,
        margin: margin,
        transform: transform,
        transformAlignment: transformAlignment,
        clipBehavior: clipBehavior,
        child: child,
      );
    }

    // Create base container with decoration
    // Wrap in SizedBox to ensure fixed size when width/height are specified
    Widget baseContainer = Container(
      width: width,
      height: height,
      decoration:
          decoration ?? (color != null ? BoxDecoration(color: color) : null),
    );

    // If width or height specified, enforce with tight constraints
    if (width != null || height != null) {
      baseContainer = ConstrainedBox(
        constraints: BoxConstraints.tightFor(
          width: width,
          height: height,
        ),
        child: baseContainer,
      );
    }

    // Apply glass shader effect
    Widget glassContainer = ShaderBuilder(
      (context, shader, _) {
        return AnimatedSampler(
          (image, size, canvas) {
            // Set uniforms
            shader.setFloatUniforms((u) {
              u.setSize(size);
            });
            shader.setImageSampler(0, image);

            // Draw the shader covering full size
            canvas.drawRect(
              Offset.zero & size,
              Paint()..shader = shader,
            );
          },
          child: baseContainer,
        );
      },
      assetKey: ShaderUtils.getShaderAssetPath('liquid_glass_shader.frag'),
    );

    // Stack: glass background + child on top
    Widget result = Stack(
      fit: StackFit.loose,
      children: [
        // Glass effect background
        glassContainer,
        // Child content on top - positioned to fill
        if (child != null)
          Positioned.fill(
            child: Container(
              alignment: alignment,
              padding: padding,
              child: child,
            ),
          ),
      ],
    );

    // If width/height specified, wrap with SizedBox to enforce exact size
    // UnconstrainedBox breaks parent constraints so Stack doesn't expand
    if (width != null || height != null) {
      result = UnconstrainedBox(
        child: SizedBox(
          width: width,
          height: height,
          child: result,
        ),
      );
    }

    // Apply clipping FIRST if decoration has border radius
    // This ensures the shader output is properly clipped
    if (decoration != null && decoration is BoxDecoration) {
      final boxDecoration = decoration as BoxDecoration;
      if (boxDecoration.borderRadius != null) {
        result = ClipRRect(
          borderRadius: boxDecoration.borderRadius as BorderRadius,
          clipBehavior: clipBehavior,
          child: result,
        );
      }
    }

    // Apply constraints if specified
    if (constraints != null) {
      result = ConstrainedBox(
        constraints: constraints!,
        child: result,
      );
    }

    // Apply foreground decoration if specified
    if (foregroundDecoration != null) {
      result = DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: foregroundDecoration!,
        child: result,
      );
    }

    // Apply transform if specified
    if (transform != null) {
      result = Transform(
        transform: transform!,
        alignment: transformAlignment,
        child: result,
      );
    }

    // Apply margin if specified
    if (margin != null) {
      result = Padding(
        padding: margin!,
        child: result,
      );
    }

    return result;
  }
}
