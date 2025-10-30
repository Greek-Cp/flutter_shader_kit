// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import 'dart:math' as math;
import '../utils/shader_utils.dart';

/// Callback invoked when curl gesture completes.
///
/// [curlAmount] represents how far the card was curled (0.0 to 1.0).
typedef OnCurlComplete = void Function(double curlAmount);

/// A card widget with a page-curl effect when swiped horizontally.
///
/// This widget renders a card with customizable content and an action layer
/// that is revealed underneath when the user performs a horizontal swipe gesture.
/// The curl effect is achieved using a fragment shader.
///
/// Example:
/// ```dart
/// CurlCard(
///   width: 300,
///   height: 200,
///   borderRadius: 16,
///   content: Container(
///     color: Colors.blue,
///     child: Center(child: Text('Swipe me!')),
///   ),
///   actionLayer: Container(
///     color: Colors.red,
///     child: Align(
///       alignment: Alignment.centerRight,
///       child: Padding(
///         padding: EdgeInsets.all(16),
///         child: Icon(Icons.delete, color: Colors.white),
///       ),
///     ),
///   ),
///   onCurlComplete: (amount) {
///     if (amount > 0.5) {
///       print('Card dismissed!');
///     }
///   },
/// )
/// ```
class CurlCard extends StatefulWidget {
  /// Creates a curl card widget.
  const CurlCard({
    super.key,
    required this.width,
    required this.height,
    required this.content,
    this.actionLayer,
    this.borderRadius = 16.0,
    this.curlThreshold = 150.0,
    this.animationDuration = const Duration(milliseconds: 240),
    this.animationCurve = Curves.easeOut,
    this.onCurlStart,
    this.onCurlUpdate,
    this.onCurlComplete,
    this.enabled = true,
  });

  /// Width of the card.
  final double width;

  /// Height of the card.
  final double height;

  /// The main content of the card (displayed on top).
  final Widget content;

  /// Optional layer revealed underneath the curl (e.g., delete button).
  final Widget? actionLayer;

  /// Corner radius of the card.
  final double borderRadius;

  /// Threshold distance for curl effect visibility (in logical pixels).
  /// Higher values = more gradual curl reveal.
  final double curlThreshold;

  /// Duration of the snap-back animation when gesture ends.
  final Duration animationDuration;

  /// Curve for the snap-back animation.
  final Curve animationCurve;

  /// Callback when curl gesture starts.
  final VoidCallback? onCurlStart;

  /// Callback during curl gesture with curl amount (0.0 to 1.0).
  final ValueChanged<double>? onCurlUpdate;

  /// Callback when curl gesture completes (on drag end).
  final OnCurlComplete? onCurlComplete;

  /// Whether curl gesture is enabled.
  final bool enabled;

  @override
  State<CurlCard> createState() => _CurlCardState();
}

class _CurlCardState extends State<CurlCard> with TickerProviderStateMixin {
  double _originX = 0.0;
  double _pointerX = 0.0;
  bool _isDragging = false;
  AnimationController? _returnController;

  // Dynamic padding calculated based on card size to prevent cropping
  late double _padding;

  @override
  void initState() {
    super.initState();
    _calculatePadding();
  }

  @override
  void didUpdateWidget(CurlCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.width != widget.width || oldWidget.height != widget.height) {
      _calculatePadding();
    }
  }

  void _calculatePadding() {
    // Padding should be enough to accommodate the curl effect
    // Use a formula based on card dimensions and curl radius
    const double baseRadius = 150.0; // curl radius from shader
    final double maxDimension = math.max(widget.width, widget.height);

    // Dynamic padding: minimum 150, scales with card size
    _padding = math.max(
      baseRadius,
      (maxDimension * 0.35).clamp(150.0, 300.0),
    );
  }

  double get _curlAmount {
    final double delta = (_originX - _pointerX).abs();
    return (delta / widget.curlThreshold).clamp(0.0, 1.0);
  }

  void _onDragStart(DragStartDetails details) {
    if (!widget.enabled) return;

    setState(() {
      _isDragging = true;
      _originX = details.localPosition.dx;
      _pointerX = _originX;
    });

    widget.onCurlStart?.call();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!widget.enabled || !_isDragging) return;

    setState(() {
      _pointerX = details.localPosition.dx;
    });

    widget.onCurlUpdate?.call(_curlAmount);
  }

  void _onDragEnd([DragEndDetails? _]) {
    if (!widget.enabled || !_isDragging) return;

    final double finalCurlAmount = _curlAmount;

    // Dispose existing controller before creating new one
    _returnController?.dispose();
    _returnController = null;

    final double start = _pointerX;
    final double end = _originX;

    _returnController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    )
      ..addListener(() {
        if (mounted) {
          setState(() {
            final double t = _returnController!.value;
            _pointerX =
                start + (end - start) * widget.animationCurve.transform(t);
          });
        }
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed ||
            status == AnimationStatus.dismissed) {
          if (mounted) {
            setState(() {
              _isDragging = false;
            });
          }
          _returnController?.dispose();
          _returnController = null;

          widget.onCurlComplete?.call(finalCurlAmount);
        }
      })
      ..forward();
  }

  @override
  void dispose() {
    _returnController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: _onDragStart,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            // Bottom layer: main content
            ClipRRect(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: SizedBox(
                width: widget.width,
                height: widget.height,
                child: widget.content,
              ),
            ),

            // Middle layer: action layer revealed under curl
            if (widget.actionLayer != null)
              Positioned.fill(
                child: AnimatedOpacity(
                  opacity: (_originX - _pointerX) > 0 ? _curlAmount : 0.0,
                  duration: const Duration(milliseconds: 120),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    child: widget.actionLayer,
                  ),
                ),
              ),

            // Top layer: shader overlay with curl effect
            Positioned(
              left: -_padding,
              top: -_padding,
              right: -_padding,
              bottom: -_padding,
              child: ShaderBuilder(
                (context, shader, child) {
                  return AnimatedSampler(
                    (image, size, canvas) {
                      // Uniforms must match declaration order in shader
                      shader.setFloatUniforms((u) {
                        // resolution (expanded size with padding)
                        u.setSize(size);
                        // pointer and origin (adjusted for padding)
                        u.setFloat(_pointerX + _padding);
                        u.setFloat(_originX + _padding);
                        // container: left, top, right, bottom
                        u.setFloats([
                          _padding,
                          _padding,
                          _padding + widget.width,
                          _padding + widget.height,
                        ]);
                        // cornerRadius
                        u.setFloat(widget.borderRadius);
                      });

                      shader.setImageSampler(0, image);

                      // Paint full rect; shader handles transparency
                      canvas.drawRect(
                        Offset.zero & size,
                        Paint()..shader = shader,
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.all(_padding),
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(widget.borderRadius),
                        child: SizedBox(
                          width: widget.width,
                          height: widget.height,
                          child: widget.content,
                        ),
                      ),
                    ),
                  );
                },
                assetKey:
                    ShaderUtils.getShaderAssetPath('riveo_widget_curl.frag'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
