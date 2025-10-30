#include <flutter/runtime_effect.glsl>

// Simple motion blur along the per-frame velocity vector.

uniform vec2  resolution;       // widget size in pixels
uniform vec2  velocity;         // per-frame motion in pixels (x,y)

layout(binding = 0) uniform sampler2D image; // sampled content

out vec4 fragColor;

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv = fragCoord / resolution;

    // Convert pixel velocity into UV space. The sign convention here means
    // we sample along the opposite direction (trailing blur).
    vec2 velUV = velocity / max(resolution, vec2(1.0));

    // Number of taps. Keep modest for performance.
    const int kSamples = 24;

    // Accumulate samples along the path from the current pixel back to where
    // it was in the previous frame. Alpha-aware accumulation avoids boxy
    // artifacts at transparent edges.
    vec3 rgbAcc = vec3(0.0);
    float aAcc = 0.0;
    for (int i = 0; i < kSamples; i++) {
        float t = float(i) / float(kSamples - 1); // 0..1
        // Sample from current (t=0) back along velocity (t=1).
        vec2 offs = -velUV * t;
        // Slightly bias weights towards current pixel to reduce ghosting.
        float w = mix(1.0, 0.4, t);
        vec4 s = texture(image, clamp(uv + offs, 0.0, 1.0));
        float aw = w * s.a; // weight by alpha to reduce bleeding
        rgbAcc += s.rgb * aw; // premultiplied accumulation
        aAcc += aw;
    }

    if (aAcc > 1e-5) {
        vec3 rgb = rgbAcc / aAcc;
        fragColor = vec4(rgb, clamp(aAcc, 0.0, 1.0));
    } else {
        fragColor = vec4(0.0);
    }
}


