import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import 'package:flutter_shaders/src/animated_sampler.dart';
import '../utils/shader_utils.dart';

/// An image switcher that plays a Spreading Frost transition when switching.
///
/// Pass two widgets (typically Images) for [current] and [next]. Call [play]
/// to animate from current to next with the frost effect. Once complete, the
/// [next] becomes the new base.
class SpreadingFrostImageSwitcher extends StatefulWidget {
  const SpreadingFrostImageSwitcher({
    super.key,
    required this.current,
    required this.next,
    this.duration = const Duration(milliseconds: 900),
    this.curve = Curves.easeInOut,
    this.frostiness = 0.5,
    this.blurAmount = 2.0,
    this.onCompleted,
    this.controller,
    this.ringWidth = 0.12,
    this.ringIrregularity = 0.25,
    this.ringNoiseScale = 1.0,
    this.bloomStrength = 0.35,
    this.bloomWidth = 10.0,
    this.bloomColor = const Color(0xCCFFFFFF),
  });

  final Widget current;
  final Widget next;
  final Duration duration;
  final Curve curve;
  final double frostiness; // 0..1
  final double blurAmount; // in pixels
  final VoidCallback? onCompleted;
  final SpreadingFrostController? controller;

  /// Thickness of the blur ring (0..1 relative to half-diagonal)
  final double ringWidth;

  /// Amount of irregularity/wave on the ring (0..1)
  final double ringIrregularity;

  /// Spatial frequency of the noise pattern
  final double ringNoiseScale;

  /// Bloom intensity around the ring front
  final double bloomStrength;

  /// Bloom width (in pixels) around the ring
  final double bloomWidth;

  /// Bloom color (RGB used, alpha ignored here)
  final Color bloomColor;

  @override
  State<SpreadingFrostImageSwitcher> createState() =>
      _SpreadingFrostImageSwitcherState();
}

class _SpreadingFrostImageSwitcherState
    extends State<SpreadingFrostImageSwitcher>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progress;
  bool _playing = false;
  Widget _base = const SizedBox.shrink();

  @override
  void initState() {
    super.initState();
    _base = widget.current;
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) {
          setState(() {
            _base = widget.next;
            _playing = false;
          });
          widget.onCompleted?.call();
        }
      });
    _progress = CurvedAnimation(parent: _controller, curve: widget.curve);
    widget.controller?._bind(play);
  }

  void play() {
    setState(() => _playing = true);
    _controller
      ..reset()
      ..forward();
  }

  @override
  void didUpdateWidget(covariant SpreadingFrostImageSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If next/current changed while idle, update base without animation
    if (!_playing && oldWidget.current != widget.current) {
      _base = widget.current;
    }
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._unbind();
      widget.controller?._bind(play);
    }
  }

  @override
  void dispose() {
    widget.controller?._unbind();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        _base,
        if (_playing)
          AnimatedBuilder(
            animation: _progress,
            builder: (context, _) {
              final t = _progress.value;
              return ShaderBuilder(
                (context, shader, __) {
                  return AnimatedSampler(
                    (image, size, canvas) {
                      shader.setFloatUniforms((u) {
                        u.setSize(size); // resolution
                        u.setFloat(t); // progress
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
                      canvas.drawRect(
                          Offset.zero & size, Paint()..shader = shader);
                    },
                    // Child is the widget to be revealed (next)
                    child: widget.next,
                  );
                },
                assetKey:
                    ShaderUtils.getShaderAssetPath('spreading_frost.frag'),
              );
            },
          ),
      ],
    );
  }
}

/// Controller to start the frost transition from outside the widget.
class SpreadingFrostController {
  VoidCallback? _play;
  void _bind(VoidCallback play) => _play = play;
  void _unbind() => _play = null;

  /// Start the transition animation.
  void play() => _play?.call();
}
