import 'package:flutter/material.dart';
import 'package:flutter_shader_kit/widgets/cloud_shader.dart';

class CloudShaderDemoPage extends StatefulWidget {
  const CloudShaderDemoPage({super.key});

  @override
  State<CloudShaderDemoPage> createState() => _CloudShaderDemoPageState();
}

class _CloudShaderDemoPageState extends State<CloudShaderDemoPage> {
  CloudShaderStyle _style = CloudShaderStyle.realistic;
  bool _enabled = true;
  bool _animate = true;

  double _animationSpeed = 1.0;
  double _density = 1.0;
  double _noisiness = 0.35;
  double _flowSpeed = 0.1;
  double _height = 2.5;
  double _brightness = 1.0;
  double _opacity = 1.0;

  double _windSpeed = 1.0;
  double _blurScale = 1.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controls = <Widget>[
      SwitchListTile.adaptive(
        title: const Text('Enable shader'),
        value: _enabled,
        onChanged: (value) => setState(() => _enabled = value),
      ),
      SwitchListTile.adaptive(
        title: const Text('Animate'),
        value: _animate,
        onChanged: (value) => setState(() => _animate = value),
      ),
      ListTile(
        title: const Text('Style'),
        subtitle: SegmentedButton<CloudShaderStyle>(
          segments: const [
            ButtonSegment(
              value: CloudShaderStyle.realistic,
              icon: Icon(Icons.cloud_outlined),
              label: Text('Realistic'),
            ),
            ButtonSegment(
              value: CloudShaderStyle.toon,
              icon: Icon(Icons.cloud_queue),
              label: Text('Toon'),
            ),
          ],
          selected: <CloudShaderStyle>{_style},
          onSelectionChanged: (selection) {
            if (selection.isNotEmpty) {
              setState(() => _style = selection.first);
            }
          },
        ),
      ),
      _buildSlider(
        label: 'Animation speed',
        value: _animationSpeed,
        min: 0.0,
        max: 2.0,
        onChanged: (value) => setState(() => _animationSpeed = value),
      ),
      _buildSlider(
        label: 'Opacity',
        value: _opacity,
        min: 0.0,
        max: 1.0,
        onChanged: (value) => setState(() => _opacity = value),
      ),
      if (_style == CloudShaderStyle.realistic) ...[
        _buildSlider(
          label: 'Cloud density',
          value: _density,
          min: 0.0,
          max: 1.5,
          onChanged: (value) => setState(() => _density = value),
        ),
        _buildSlider(
          label: 'Noisiness',
          value: _noisiness,
          min: 0.0,
          max: 1.0,
          onChanged: (value) => setState(() => _noisiness = value),
        ),
        _buildSlider(
          label: 'Flow speed',
          value: _flowSpeed,
          min: 0.0,
          max: 0.3,
          onChanged: (value) => setState(() => _flowSpeed = value),
        ),
        _buildSlider(
          label: 'Cloud height',
          value: _height,
          min: 0.5,
          max: 5.0,
          onChanged: (value) => setState(() => _height = value),
        ),
        _buildSlider(
          label: 'Brightness',
          value: _brightness,
          min: 0.2,
          max: 1.5,
          onChanged: (value) => setState(() => _brightness = value),
        ),
      ] else ...[
        _buildSlider(
          label: 'Wind speed',
          value: _windSpeed,
          min: 0.0,
          max: 3.0,
          onChanged: (value) => setState(() => _windSpeed = value),
        ),
        _buildSlider(
          label: 'Blur scale',
          value: _blurScale,
          min: 0.5,
          max: 2.0,
          onChanged: (value) => setState(() => _blurScale = value),
        ),
      ],
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloud Shader Demo'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          AspectRatio(
            aspectRatio: 3 / 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: CloudShader(
                style: _style,
                enabled: _enabled,
                animate: _animate,
                animationSpeed: _animationSpeed,
                cloudDensity: _density,
                noisiness: _noisiness,
                flowSpeed: _flowSpeed,
                cloudHeight: _height,
                brightness: _brightness,
                windSpeed: _windSpeed,
                blurScale: _blurScale,
                opacity: _opacity,
                child: _buildOverlay(theme),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ...controls,
        ],
      ),
    );
  }

  Widget _buildOverlay(ThemeData theme) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cloud Layers',
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Switch between realistic noise-driven clouds or a stylised toon sky.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(label),
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
