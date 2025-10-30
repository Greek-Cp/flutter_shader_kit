## flutter_shader_kit

High‑quality, real‑time UI effects powered by fragment shaders for Flutter. Flutter Shader Kit provides production‑ready widgets: frost overlays, reeded glass (fractal blur), rainy glass, motion blur, animated clouds, a liquid glass container, a curl card, and a frost transition switcher.

Works on Flutter 3.7+ with the FragmentProgram API. Backdrop modes that use ImageFilter.shader work best with Impeller.

### Why use this?
- GPU‑accelerated effects with minimal boilerplate
- Drop‑in widgets with sensible defaults and tunable parameters
- No manual shader plumbing in your app code

---

## Installation

Add the package and its shader runtime to your app. This library uses the utilities (`ShaderBuilder`, `AnimatedSampler`, etc.) from `flutter_shaders`.

```yaml
dependencies:
  flutter:
    sdk: flutter
  # Shader runtime utilities used by this package
  flutter_shaders: ^0.1.3
  # This package
  flutter_shader_kit: ^0.1.0
```

If you’re using this repository directly (local development):

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_shaders: ^0.1.3
  # Use a local path or git dependency for this library
  flutter_shader_kit:
    path: ../flutter_shader_fork
```

Notes:
- Shader assets are bundled in this package – consumers don’t need to list them in their app’s `flutter: shaders:` section.
- Backdrop variants rely on `ImageFilter.shader`. On devices/targets without Impeller support, these gracefully no‑op (fall back) where possible.

---

## Quick start

```dart
import 'package:flutter/material.dart';
import 'package:flutter_shader_kit/flutter_shaders.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            // Animated clouds background
            const CloudShader(),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  // Reeded glass look over any child
                  SizedBox(
                    width: 300,
                    height: 160,
                    child: FractalBlurLayer(
                      child: FlutterLogo(size: 120),
                    ),
                  ),
                  SizedBox(height: 24),
                  // Frost overlay you can trigger with a controller
                  FrostShaderLayer(
                    child: Text('Frost me'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## Widgets and utilities

Below are each widget/utility, parameters, defaults, and example usage.

### 1) `CloudShader`
Animated procedural cloud backgrounds. Two styles: `realistic` (noise‑based) and `toon` (stylized).

Imports:
```dart
import 'package:flutter_shader_kit/flutter_shaders.dart';
```

Constructor (defaults shown):
- `style` = `CloudShaderStyle.realistic`
- `child` = `null` (optional overlay content)
- `width`/`height` = `null`
- `enabled` = `true`
- `animate` = `true`
- `animationSpeed` = `1.0`
- `cloudDensity` = `1.0` (realistic)
- `noisiness` = `0.35` (realistic)
- `flowSpeed` = `0.1` (realistic)
- `cloudHeight` = `2.5` (realistic)
- `brightness` = `1.0` (realistic)
- `windSpeed` = `1.0` (toon)
- `blurScale` = `1.0` (toon)
- `skyColor`/`cloudColor` = `null` (auto by style)
- `opacity` = `1.0`

Example:
```dart
const CloudShader(
  style: CloudShaderStyle.realistic,
  opacity: 0.95,
  child: Center(child: Text('On top of clouds')),
)
```

### 2) `FractalBlurLayer`
Reeded glass effect (directional blur + refraction) applied to a child or backdrop.

Constructor:
- `child` (Widget) required
- `width`/`height` = `null`
- `frequency` = `40.0`
- `refractAmount` = `500.0`
- `split` = `1.0` (mix between processed/original)
- `feather` = `0.003`
- `blurRadius` = `20.0`
- `blurStrength` = `1.0`
- `enabled` = `true`
- `useBackdrop` = `false` (uses `BackdropFilter` when `true`)

Example:
```dart
const FractalBlurLayer(
  blurRadius: 16,
  blurStrength: 0.85,
  child: YourContent(),
)
```

### 3) `FrostBlurLayer`
Frosted glass blur/distortion with optional circle/rounded‑rect clipping and backdrop mode.

Constructor:
- `child` required
- `width`/`height` = `null`
- `shape` = `BoxShape.rectangle`
- `noiseScale` = `6.0`
- `distortion` = `0.045`
- `directionalMix` = `0.25`
- `iterations` = `12`
- `blend` = `1.0` (0 = original, 1 = full frost)
- `enabled` = `true`
- `useBackdrop` = `false`
- `borderRadius` = `null` (when rectangle)

Example (rounded rectangle):
```dart
const FrostBlurLayer(
  borderRadius: BorderRadius.all(Radius.circular(24)),
  child: YourContent(),
)
```

### 4) `FrostShaderLayer`
Spreading frost overlay animation over its child. Trigger via `FrostLayerController`.

Constructor:
- `child` required
- `controller` = `null`
- `duration` = `900ms`
- `curve` = `Curves.easeInOutCubic`
- `frostiness` = `0.55`
- `blurAmount` = `3.0`
- `ringWidth` = `0.12`
- `ringIrregularity` = `0.28`
- `ringNoiseScale` = `1.2`
- `bloomStrength` = `0.35`
- `bloomWidth` = `12.0`
- `bloomColor` = `Color(0xCCBFE3FF)`
- `onCompleted` = `null`

Usage:
```dart
final controller = FrostLayerController();

FrostShaderLayer(
  controller: controller,
  child: const YourContent(),
)

// Trigger later
controller.play();
```

### 5) `LiquidGlassContainer`
Container‑like widget that renders a liquid glass shader behind its child.

Key parameters (Container‑compatible):
- `alignment`, `padding`, `color`, `decoration`, `foregroundDecoration`
- `width`, `height`, `constraints`, `margin`, `transform`, `transformAlignment`
- `clipBehavior` (default `Clip.antiAlias`)
- `child`
- `glassEnabled` = `true`

Example:
```dart
const LiquidGlassContainer(
  width: 320,
  height: 180,
  decoration: BoxDecoration(
    gradient: LinearGradient(colors: [Colors.blue, Colors.purple]),
    borderRadius: BorderRadius.all(Radius.circular(20)),
  ),
  child: Center(child: Text('Hello Glass')),
)
```

### 6) `MotionBlurLayer`
Applies a subtle motion blur based on widget movement. You can provide your own velocity.

Constructor:
- `child` required
- `enabled` = `true`
- `velocity` = `null` (use auto‑measured motion when not provided)

Example:
```dart
const MotionBlurLayer(
  child: YourMovingWidget(),
)
```

### 7) `CurlCard`
Interactive card with a page‑curl shader overlay and optional action layer underneath.

Constructor:
- `width`, `height` required
- `content` required (top layer)
- `actionLayer` = `null` (revealed underneath)
- `borderRadius` = `16.0`
- `curlThreshold` = `150.0` (gesture distance for full curl)
- `animationDuration` = `240ms`
- `animationCurve` = `Curves.easeOut`
- `onCurlStart`/`onCurlUpdate(double amount)`/`onCurlComplete(double amount)`
- `enabled` = `true`

Example:
```dart
CurlCard(
  width: 300,
  height: 180,
  content: Container(color: Colors.blue),
  actionLayer: Container(color: Colors.red),
  onCurlComplete: (amount) {
    if (amount > 0.5) debugPrint('Dismiss');
  },
)
```

### 8) `SpreadingFrostImageSwitcher`
Animates a frost ring to transition from `current` to `next` content.

Constructor:
- `current`, `next` required
- `duration` = `900ms`
- `curve` = `Curves.easeInOut`
- `frostiness` = `0.5`
- `blurAmount` = `2.0`
- `ringWidth` = `0.12`
- `ringIrregularity` = `0.25`
- `ringNoiseScale` = `1.0`
- `bloomStrength` = `0.35`
- `bloomWidth` = `10.0`
- `bloomColor` = `Color(0xCCFFFFFF)`
- `onCompleted` = `null`
- `controller` = `null` (`SpreadingFrostController`)

Example:
```dart
final frost = SpreadingFrostController();

SpreadingFrostImageSwitcher(
  controller: frost,
  current: const Placeholder(),
  next: const FlutterLogo(size: 120),
)

// Trigger later
frost.play();
```

### 9) `SpreadingFrostWidget`
Convenience wrapper over `SpreadingFrostImageSwitcher` for arbitrary widgets (not just images). Same parameters.

Example:
```dart
const SpreadingFrostWidget(
  current: Text('A'),
  next: Text('B'),
)
```

### 10) `WeatherRainLayer`
Rainy glass post‑process with blur and refraction. Supports backdrop and screen‑anchored raindrops.

Constructor:
- `child` required
- `width`/`height` = `null`
- `rainAmount` = `0.75` (0..1)
- `maxBlur` = `6.0`
- `minBlur` = `2.0`
- `refraction` = `40.0` (pixels)
- `speed` = `1.0`
- `enabled` = `true`
- `useBackdrop` = `false`
- `lockToScreen` = `false` (anchor pattern to screen in non‑backdrop mode)

Example:
```dart
const WeatherRainLayer(
  child: YourContent(),
  rainAmount: 0.7,
)
```

### 11) `ShaderUtils`
Utility for resolving package shader asset paths.

API:
- `static String getShaderAssetPath(String shaderName)` → returns `packages/flutter_shaders/shaders/<shaderName>`.

You generally don’t need this directly unless building custom wrappers.

### 12) Barrel export: `flutter_shaders.dart`
Single import for all widgets/utilities in this package.

```dart
import 'package:flutter_shader_kit/flutter_shaders.dart';
```

Exports:
- Widgets: `curl_card.dart`, `liquid_glass_container.dart`, `spreading_frost_image_switcher.dart`, `spreading_frost_widget.dart`, `frost_shader_layer.dart`, `frost_blur_layer.dart`, `fractal_blur_layer.dart`, `weather_rain_layer.dart`, `motion_blur_layer.dart`, `cloud_shader.dart`
- Utils: `utils/shader_utils.dart`

---

## Examples by effect

Clouds background with content overlay:
```dart
const CloudShader(
  style: CloudShaderStyle.toon,
  child: Center(child: Text('Toon clouds')),
)
```

Rainy glass over a photo card:
```dart
const SizedBox(
  width: 320,
  height: 200,
  child: WeatherRainLayer(
    child: Image(asset: 'assets/images/photo.jpg', fit: BoxFit.cover),
  ),
)
```

Motion blur around a moving avatar:
```dart
const MotionBlurLayer(
  child: CircleAvatar(radius: 32, child: Icon(Icons.person)),
)
```

---

## Performance and platform notes
- Prefer release/profile builds when evaluating visual quality and performance.
- Backdrop variants (`useBackdrop: true`) depend on `ImageFilter.shader`. This is supported on engines with Impeller; on others, these code paths may no‑op with graceful fallbacks.
- Most parameters are real‑valued; start with defaults, then adjust gradually.

---

## Contributing
Issues and PRs are welcome. Please include screenshots or short screen captures for visual changes.
You’re encouraged to contribute new shaders and effects; include a minimal demo and document parameters.

---

## License
MIT. Free to use, modify, and distribute. See the LICENSE file.

# flutter_shaders

A collection of utilities to make working with the FragmentProgram API easier.

## Features

- **ShaderBuilder**: Easily load and cache fragment shaders
- **AnimatedSampler**: Capture widget content as texture for shader sampling
- **SetUniforms**: Convenient API for setting shader uniforms without manual index management
- **ShaderInkFeatureFactory**: Custom Material ink splash effects with shaders
- **CurlCard**: Ready-to-use page curl card widget with swipe gesture support

## Getting Started

### Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_shaders: ^latest_version
```

### Basic Usage

#### Using ShaderBuilder

```dart
import 'package:flutter_shaders/flutter_shaders.dart';

ShaderBuilder(
  assetKey: 'shaders/my_shader.frag',
  (context, shader, child) {
    return CustomPaint(
      painter: MyShaderPainter(shader),
      child: child,
    );
  },
  child: Text('Hello Shader!'),
)
```

#### Using AnimatedSampler with ShaderBuilder

```dart
ShaderBuilder(
  assetKey: 'packages/flutter_shaders/shaders/pixelation.frag',
  (context, shader, child) {
    return AnimatedSampler(
      (image, size, canvas) {
        shader.setFloatUniforms((uniforms) {
          uniforms
            ..setFloat(10.0) // pixels X
            ..setFloat(10.0) // pixels Y
            ..setSize(size);
        });
        shader.setImageSampler(0, image);
        canvas.drawRect(
          Offset.zero & size,
          Paint()..shader = shader,
        );
      },
      child: Text('Pixelated!', style: TextStyle(fontSize: 24)),
    );
  },
)
```

#### Using CurlCard Widget

```dart
CurlCard(
  width: 300,
  height: 200,
  borderRadius: 16,
  content: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.blue, Colors.purple],
      ),
    ),
    child: Center(
      child: Text('Swipe me!', style: TextStyle(color: Colors.white)),
    ),
  ),
  actionLayer: Container(
    color: Colors.red,
    child: Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Icon(Icons.delete, color: Colors.white),
      ),
    ),
  ),
  onCurlComplete: (amount) {
    if (amount > 0.5) {
      print('Card dismissed!');
    }
  },
)
```

#### Setting Uniforms Made Easy

```dart
shader.setFloatUniforms((setter) {
  setter.setFloat(1.0);
  setter.setSize(const Size(100, 200));
  setter.setColor(Colors.red);
  setter.setOffset(const Offset(10, 20));
  setter.setMatrix4(Matrix4.identity());
});
```

#### Custom Material Ink Splash

```dart
MaterialApp(
  theme: ThemeData(
    splashFactory: ShaderInkFeatureFactory(
      program,
      (shader, {
        required animation,
        required color,
        required position,
        required referenceBoxSize,
        required targetRadius,
        required textDirection,
      }) {
        shader.setFloatUniforms((u) => u
          ..setFloat(animation)
          ..setColor(color, premultiply: true)
          ..setFloat(targetRadius)
          ..setOffset(position));
      },
    ),
  ),
  home: MyApp(),
)
```

## Available Shaders

This package includes shaders that can be included in your application by declaring them in the pubspec.yaml:

### Pixelation Shader

Reduces the provided sampler to M×N samples for a pixelated effect.

**Required Uniforms:**
- `vec2 uPixels`: Number of pixels in X and Y
- `vec2 uSize`: Width and height of the sampled area
- `sampler2D uTexture`: The child widget captured as texture

**Usage:**
```yaml
flutter:
  shaders:
    - packages/flutter_shaders/shaders/pixelation.frag
```

### Curl Effect Shader

Creates a realistic page curl effect with proper lighting and perspective.

**Required Uniforms:**
- `vec2 resolution`: Total rendering area size
- `float pointer`: Current touch/drag X position
- `float origin`: Starting touch X position
- `vec4 container`: Bounding box (left, top, right, bottom)
- `float cornerRadius`: Border radius of the card
- `sampler2D image`: The content to be curled

**Usage:**
```yaml
flutter:
  shaders:
    - packages/flutter_shaders/shaders/curl.frag
```

Or use the pre-built `CurlCard` widget (recommended).

## API Reference

### CurlCard

A card widget with page-curl effect on horizontal swipe. The curl shader is built-in, no need to register it separately.

**Properties:**
- `width` (required): Card width
- `height` (required): Card height
- `content` (required): Main card content widget
- `actionLayer`: Widget revealed underneath curl (optional)
- `borderRadius`: Corner radius (default: 16.0)
- `curlThreshold`: Distance for curl visibility (default: 150.0)
- `animationDuration`: Snap-back duration (default: 240ms)
- `animationCurve`: Snap-back curve (default: Curves.easeOut)
- `enabled`: Enable/disable curl gesture (default: true)

**Callbacks:**
- `onCurlStart`: Called when curl gesture starts
- `onCurlUpdate(double amount)`: Called during curl (0.0 to 1.0)
- `onCurlComplete(double amount)`: Called when gesture ends

**Dynamic Padding:**
The CurlCard automatically calculates padding based on card size to prevent the curl effect from being cropped. The padding scales with card dimensions while maintaining a minimum of 150px and maximum of 300px.

### ShaderBuilder

Widget that loads and caches FragmentProgram shaders.

**Methods:**
- `ShaderBuilder.precacheShader(String assetKey)`: Preload shader for immediate availability

### AnimatedSampler

Widget that captures child content as texture for shader sampling.

**Properties:**
- `builder`: Callback providing image, size, and canvas
- `child`: Widget to capture as texture
- `enabled`: Enable/disable sampling (default: true)

### SetUniforms Extension

Extension on `FragmentShader` for convenient uniform setting.

**Available Methods:**
- `setFloat(double)`
- `setFloats(List<double>)`
- `setSize(Size)`
- `setOffset(Offset)`
- `setColor(Color, {bool premultiply})`
- `setVector(Vector)`
- `setMatrix2/3/4(Matrix)`

## Examples

See the `example/` directory for complete working examples:
- Basic shader usage
- Pixelation effect
- Custom ink splash
- Curl card demos

## Creating Custom Shaders

Your GLSL shaders must:
1. Use `#version 460 core`
2. Include `<flutter/runtime_effect.glsl>` for Flutter helpers
3. Declare `out vec4 fragColor` for output
4. Use `FlutterFragCoord()` for pixel coordinates

Example shader:
```glsl
#version 460 core
#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform vec4 uColor;

out vec4 fragColor;

void main() {
  vec2 uv = FlutterFragCoord().xy / uSize;
  fragColor = uColor * uv.x;
}
```

Register in `pubspec.yaml`:
```yaml
flutter:
  shaders:
    - shaders/my_shader.frag
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT license - see the LICENSE file for details.
