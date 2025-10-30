#include <flutter/runtime_effect.glsl>

// Mirror spreading_frost.frag naming and order so Dart uniforms align 1:1
uniform vec2  resolution;   // widget size in pixels
uniform float progress;     // 0.0 -> 1.0
uniform float frostiness;   // ~0..1 strength
uniform float blurAmount;   // blur radius in pixels
uniform float ringWidth;    // thickness of the blur ring (0..1 of half-diagonal)
uniform float ringIrregularity; // 0..1 amount of irregular wave on the ring
uniform float ringNoiseScale;   // spatial frequency of irregularity
uniform float bloomStrength;    // intensity of ring bloom
uniform float bloomWidth;       // width of bloom in pixels around ring front
uniform vec4  bloomColor;       // color of bloom (non-premultiplied)

layout(binding = 0) uniform sampler2D image; // captured scene image

// simple 2D noise based on hash
float hash(vec2 p) {
  p = fract(p * vec2(123.34, 345.45));
  p += dot(p, p + 34.345);
  return fract(p.x * p.y);
}

float noise(vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);
  // bilinear interpolation of hashed corners
  float a = hash(i);
  float b = hash(i + vec2(1.0, 0.0));
  float c = hash(i + vec2(0.0, 1.0));
  float d = hash(i + vec2(1.0, 1.0));
  vec2 u = f * f * (3.0 - 2.0 * f);
  return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

// Small 3x3 box blur (samples global 'image')
vec4 sampleBlur(vec2 uv, vec2 res, float radiusPx) {
  if (radiusPx <= 0.001) return texture(image, uv);
  vec2 px = radiusPx / res;
  vec4 acc = vec4(0.0);
  float cnt = 0.0;
  for (int x = -1; x <= 1; x++) {
    for (int y = -1; y <= 1; y++) {
      vec2 o = vec2(float(x), float(y)) * px;
      acc += texture(image, uv + o);
      cnt += 1.0;
    }
  }
  return acc / max(cnt, 1.0);
}

out vec4 fragColor;
void main() {
  vec2 frag = FlutterFragCoord().xy;
  vec2 uv = frag / resolution;

  float p = clamp(progress, 0.0, 1.0);
  // When animation hasn't started, render the scene unchanged.
  if (p <= 0.0001) {
    fragColor = texture(image, uv);
    return;
  }
  float distPx = length(frag - (resolution * 0.5));

  // Base front radius and thickness
  float halfDiagPx = length(resolution * 0.5);
  float ringWpx = clamp(ringWidth, 0.01, 0.5) * halfDiagPx;
  float sRing = ringWpx * 0.5;
  // Overshoot beyond corners to guarantee exit
  float maxReachPx = halfDiagPx + ringWpx;
  float rFrontBasePx = max(1e-3, p * maxReachPx);

  // Irregular warp of the front radius (spatial noise animated by progress)
  float n = noise(uv * max(0.1, ringNoiseScale) * 6.0 + vec2(p * 1.37, p * 0.91));
  // Taper irregularity near completion so edge fully seals
  float taper = 1.0 - smoothstep(0.9, 1.0, p);
  float deltaPx = (n - 0.5) * 2.0 * clamp(ringIrregularity, 0.0, 1.0) * ringWpx * taper;
  float rFront = clamp(rFrontBasePx + deltaPx, 0.0, maxReachPx);
  float rClear = max(0.0, rFront - ringWpx);

  // Smooth edge widths (sRing already defined)
  float sClear = max(1e-6, ringWpx * p * 0.8);

  // Inside masks (1.0 when inside respective radius with soft edges)
  float insideFront = 1.0 - smoothstep(rFront - sRing, rFront + sRing, distPx);
  float insideClear = 1.0 - smoothstep(rClear - sClear, rClear + sClear, distPx);

  // Build a blur ring and a clear core
  float blurRingAlpha = clamp(insideFront - insideClear, 0.0, 1.0);
  float clearAlpha = clamp(insideClear, 0.0, 1.0);

  // Frosty offset only on the blur ring
  // Simple hash-based random for a tiny offset
  float a = dot(uv, vec2(92.0, 80.0));
  float b = dot(uv, vec2(41.0, 62.0));
  float x = sin(a) + cos(b) * 51.0;
  float r = fract(x);
  vec2 rnd = vec2(r, fract(r * 1.37));
  rnd = (rnd - 0.5) * 2.0;
  rnd *= frostiness * blurRingAlpha;

  // Samples
  vec4 base = texture(image, uv);
  vec4 blurTo = sampleBlur(uv + rnd * 0.01, resolution, blurAmount);
  blurTo.rgb *= vec3(0.9, 0.9, 1.1); // slight cool tint on blur ring

  // Compose final full image: start with base; blur ring overrides; clear core restores base
  vec3 rgb = base.rgb;
  rgb = mix(rgb, blurTo.rgb, blurRingAlpha);
  rgb = mix(rgb, base.rgb, clearAlpha);

  // Bloom/silhouette around the moving front
  float dFront = abs(distPx - rFront);
  float glow = smoothstep(bloomWidth, 0.0, dFront);
  float glowMask = glow * (1.0 - insideClear);
  rgb += bloomStrength * glowMask * bloomColor.rgb;
  rgb = clamp(rgb, 0.0, 1.0);

  fragColor = vec4(rgb, 1.0);
}
