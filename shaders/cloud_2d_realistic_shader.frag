#include <flutter/runtime_effect.glsl>

// 2D cloud shader based on simplex noise and fBm.
// Adapted for Flutter runtime effects.

uniform vec2 resolution;
uniform float time;
uniform float cloudDensity;  // [0,1]
uniform float noisiness;     // [0,1]
uniform float speed;         // animation speed multiplier
uniform float cloudHeight;   // inverse height of gradient
uniform vec3 skyColor;       // base sky color
uniform vec3 cloudColor;     // highlight cloud color
uniform float brightness;    // global brightness multiplier
uniform float opacity;       // global alpha multiplier for blending

out vec4 fragColor;

vec3 mod289(vec3 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 mod289(vec4 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 permute(vec4 x) {
  return mod289(((x * 34.0) + 1.0) * x);
}

vec4 taylorInvSqrt(vec4 r) {
  return 1.79284291400159 - 0.85373472095314 * r;
}

float snoise(vec3 v) {
  const vec2 C = vec2(1.0 / 6.0, 1.0 / 3.0);
  const vec4 D = vec4(0.0, 0.5, 1.0, 2.0);

  vec3 i = floor(v + dot(v, C.yyy));
  vec3 x0 = v - i + dot(i, C.xxx);

  vec3 g = step(x0.yzx, x0.xyz);
  vec3 l = 1.0 - g;
  vec3 i1 = min(g.xyz, l.zxy);
  vec3 i2 = max(g.xyz, l.zxy);

  vec3 x1 = x0 - i1 + C.xxx;
  vec3 x2 = x0 - i2 + C.yyy;
  vec3 x3 = x0 - D.yyy;

  i = mod289(i);
  vec4 p = permute(
      permute(permute(i.z + vec4(0.0, i1.z, i2.z, 1.0)) + i.y + vec4(0.0, i1.y, i2.y, 1.0)) +
      i.x + vec4(0.0, i1.x, i2.x, 1.0));

  float n_ = 0.142857142857;
  vec3 ns = n_ * D.wyz - D.xzx;

  vec4 j = p - 49.0 * floor(p * ns.z * ns.z);

  vec4 x_ = floor(j * ns.z);
  vec4 y_ = floor(j - 7.0 * x_);

  vec4 x = x_ * ns.x + ns.yyyy;
  vec4 y = y_ * ns.x + ns.yyyy;
  vec4 h = 1.0 - abs(x) - abs(y);

  vec4 b0 = vec4(x.xy, y.xy);
  vec4 b1 = vec4(x.zw, y.zw);

  vec4 s0 = floor(b0) * 2.0 + 1.0;
  vec4 s1 = floor(b1) * 2.0 + 1.0;
  vec4 sh = -step(h, vec4(0.0));

  vec4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
  vec4 a1 = b1.xzyw + s1.xzyw * sh.zzww;

  vec3 p0 = vec3(a0.xy, h.x);
  vec3 p1 = vec3(a0.zw, h.y);
  vec3 p2 = vec3(a1.xy, h.z);
  vec3 p3 = vec3(a1.zw, h.w);

  vec4 norm = taylorInvSqrt(vec4(dot(p0, p0), dot(p1, p1), dot(p2, p2), dot(p3, p3)));
  p0 *= norm.x;
  p1 *= norm.y;
  p2 *= norm.z;
  p3 *= norm.w;

  vec4 m = max(0.6 - vec4(dot(x0, x0), dot(x1, x1), dot(x2, x2), dot(x3, x3)), 0.0);
  m = m * m;
  return 42.0 * dot(m * m, vec4(dot(p0, x0), dot(p1, x1), dot(p2, x2), dot(p3, x3)));
}

const float maximum = 1.0 / 1.0 + 1.0 / 2.0 + 1.0 / 3.0 + 1.0 / 4.0 + 1.0 / 5.0 + 1.0 / 6.0 + 1.0 / 7.0 + 1.0 / 8.0;

float fBm(vec3 uv) {
  float sum = 0.0;
  for (int i = 0; i < 8; ++i) {
    float f = float(i + 1);
    sum += snoise(uv * f) / f;
  }
  return sum / maximum;
}

float gradient(vec2 uv, float height) {
  return 1.0 - uv.y * uv.y * height;
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  vec2 res = max(resolution, vec2(1.0));
  vec2 uv = fragCoord / res;

  vec3 p = vec3(uv, time * speed);
  vec3 offset = vec3(0.1, 0.3, 0.2);
  vec2 duv = vec2(fBm(p), fBm(p + offset)) * noisiness;
  float density = gradient(uv + duv, cloudHeight) * cloudDensity;
  density = clamp(density, 0.0, 1.0);

  vec3 color = mix(skyColor, cloudColor, density) * brightness;
  fragColor = vec4(color, opacity);
}
