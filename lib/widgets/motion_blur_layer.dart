import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import '../utils/shader_utils.dart';

class MotionBlurLayer extends StatefulWidget {
  const MotionBlurLayer({
    super.key,
    required this.child,
    this.enabled = true,
    this.velocity,
  });

  final Widget child;
  final bool enabled;

  /// Optional override. If provided, uses this velocity instead of auto-detect.
  final Offset? velocity;

  @override
  State<MotionBlurLayer> createState() => _MotionBlurLayerState();
}

class _MotionBlurLayerState extends State<MotionBlurLayer>
    with SingleTickerProviderStateMixin {
  final GlobalKey _childKey = GlobalKey();
  Ticker? _ticker;
  Offset _lastCenter = Offset.zero;
  Offset _velocity = Offset.zero;
  bool _hasMeasured = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker?..dispose();
    super.dispose();
  }

  void _onTick(Duration _) {
    if (widget.velocity != null) {
      // External velocity provided; no auto measurement needed.
      final v = widget.velocity!;
      if ((v - _velocity).distanceSquared > 0.001) {
        setState(() => _velocity = v);
      }
      return;
    }

    final context = _childKey.currentContext;
    final renderObject = context?.findRenderObject();
    if (renderObject is RenderBox && renderObject.hasSize) {
      final topLeft = renderObject.localToGlobal(Offset.zero);
      final size = renderObject.size;
      final currentCenter = topLeft + Offset(size.width / 2, size.height / 2);
      if (_hasMeasured) {
        final delta = currentCenter - _lastCenter;
        // Small deadzone to avoid flicker when idle.
        if (delta.distanceSquared > 0.01) {
          setState(() => _velocity = delta);
        } else if (_velocity.distanceSquared > 0.01) {
          // Decay to zero when motion stops.
          setState(() => _velocity = _velocity * 0.8);
        }
      }
      _lastCenter = currentCenter;
      _hasMeasured = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = KeyedSubtree(key: _childKey, child: widget.child);
    if (!widget.enabled) return child;

    return ShaderBuilder(
      (context, shader, _) {
        return AnimatedSampler(
          (image, size, canvas) {
            final v = widget.velocity ?? _velocity;
            shader.setFloatUniforms((u) {
              u.setSize(size);
              u.setOffset(v);
            });
            shader.setImageSampler(0, image);
            canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
          },
          child: child,
        );
      },
      assetKey: ShaderUtils.getShaderAssetPath('motion_blur_layer.frag'),
    );
  }
}


