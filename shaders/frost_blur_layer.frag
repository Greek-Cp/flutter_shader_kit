#include <flutter/runtime_effect.glsl>

// Frosted blur layer shader with iterative noise-based distortion.

uniform vec2 resolution;     // widget size in pixels
uniform float noiseScale;    // frequency of the noise field
uniform float distortion;    // overall distortion strength (0..0.2 typical)
uniform float directionalMix; // 0 => vertical streaks, 1 => isotropic
uniform float iterations;    // number of distortion steps (1..32)
uniform float blend;         // mix between original (0) and frost effect (1)

layout(binding = 0) uniform sampler2D image;

out vec4 fragColor;

vec2 hash22(vec2 p) {
    p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
    return fract(sin(p) * 43758.5453);
}

vec2 frostPattern(vec2 uv, float scale, float directionalMix) {
    vec2 rnd = hash22(uv * scale + vec2(13.17, 7.31)) * 2.0 - 1.0;
    vec2 weights = vec2(max(directionalMix, 0.0), 1.0);
    return rnd * weights;
}

vec3 frostSample(vec2 uv) {
    return texture(image, clamp(uv, 0.0, 1.0)).rgb;
}

void main() {
    vec2 res = resolution;
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv = fragCoord / res;

    float iterFloat = clamp(iterations, 1.0, 32.0);
    int iterCount = int(iterFloat + 0.5);
    iterCount = clamp(iterCount, 1, 32);
    float strength = clamp(distortion, 0.0, 0.5);
    float stepStrength = strength / float(iterCount);
    float scale = max(noiseScale, 0.001);
    float mixAmount = clamp(blend, 0.0, 1.0);
    float dirMix = clamp(directionalMix, 0.0, 1.0);

    vec2 p = uv;
    for (int i = 0; i < 32; i++) {
        if (i >= iterCount) {
            break;
        }
        vec2 offset = frostPattern(p, scale, dirMix);
        p -= offset * stepStrength;
    }

    vec3 distorted = vec3(0.0);
    float total = 0.0;
    for (int i = 0; i < 5; i++) {
        float t = float(i) / 4.0;
        vec2 jitter = frostPattern(p + vec2(t, -t), scale * 1.3, dirMix);
        float weight = mix(1.0, exp(-t * 2.5), 0.5);
        distorted += frostSample(p + jitter * stepStrength * 4.0) * weight;
        total += weight;
    }
    distorted /= max(total, 1e-4);

    vec3 baseCol = frostSample(uv);
    vec3 finalCol = mix(baseCol, distorted, mixAmount);
    fragColor = vec4(finalCol, 1.0);
}
