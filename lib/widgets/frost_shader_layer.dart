import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import '../utils/shader_utils.dart';

/// FrostShaderLayer
/// A reusable overlay that renders a spreading-frost post-process over its child
/// while letting the child continue to update/animate underneath.
class FrostShaderLayer extends StatefulWidget {
  const FrostShaderLayer({
    super.key,
    required this.child,
    this.controller,
    this.duration = const Duration(milliseconds: 900),
    this.curve = Curves.easeInOutCubic,
    this.frostiness = 0.55,
    this.blurAmount = 3.0,
    this.ringWidth = 0.12,
    this.ringIrregularity = 0.28,
    this.ringNoiseScale = 1.2,
    this.bloomStrength = 0.35,
    this.bloomWidth = 12.0,
    this.bloomColor = const Color(0xCCBFE3FF),
    this.onCompleted,
  });

  final Widget child;
  final FrostLayerController? controller;
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
  State<FrostShaderLayer> createState() => _FrostShaderLayerState();
}

class _FrostShaderLayerState extends State<FrostShaderLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac;
  late final Animation<double> _t;
  bool _active = false;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(vsync: this, duration: widget.duration)
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) {
          setState(() => _active = false);
          widget.onCompleted?.call();
        }
      });
    _t = CurvedAnimation(parent: _ac, curve: widget.curve);
    widget.controller?._bind(play);
  }

  @override
  void didUpdateWidget(covariant FrostShaderLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._unbind();
      widget.controller?._bind(play);
    }
  }

  @override
  void dispose() {
    widget.controller?._unbind();
    _ac.dispose();
    super.dispose();
  }

  void play() {
    setState(() => _active = true);
    _ac
      ..reset()
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _t,
      builder: (context, _) {
        // Drive the shader even when inactive with p=0 to keep child mounted
        // and avoid remounting/resets of any inner animations.
        final p = _active ? _t.value : 0.0;
        return ShaderBuilder(
          (context, shader, __) {
            return AnimatedSampler(
              (image, size, canvas) {
                shader.setFloatUniforms((u) {
                  u.setSize(size);
                  u.setFloat(p);
                  u.setFloat(widget.frostiness);
                  u.setFloat(widget.blurAmount);
                  u.setFloat(widget.ringWidth);
                  u.setFloat(widget.ringIrregularity);
                  u.setFloat(widget.ringNoiseScale);
                  u.setFloat(widget.bloomStrength);
                  u.setFloat(widget.bloomWidth);
                  u.setColor(widget.bloomColor);
                });
                shader.setImageSampler(0, image);
                canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
              },
              child: widget.child,
            );
          },
          assetKey: ShaderUtils.getShaderAssetPath('frost_overlay.frag'),
        );
      },
    );
  }
}

class FrostLayerController {
  VoidCallback? _play;
  void _bind(VoidCallback play) => _play = play;
  void _unbind() => _play = null;
  void play() => _play?.call();
}
