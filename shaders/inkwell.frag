// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include <flutter/runtime_effect.glsl>

uniform float animation;
uniform vec4 color;
uniform float targetRadius;
uniform vec2 position;

out vec4 fragColor;

void main() {
  vec2 xy = FlutterFragCoord().xy;
  float distance = length(xy - position);
  float alpha = smoothstep(0.0, 1.0, animation);
  float radius = targetRadius * alpha;
  
  if (distance < radius) {
    float intensity = 1.0 - (distance / radius);
    fragColor = color * intensity * alpha;
  } else {
    fragColor = vec4(0.0);
  }
}

