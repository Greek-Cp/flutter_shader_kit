#include <flutter/runtime_effect.glsl>

// Reeded / Fluted Glass dengan Blur (Flutter Runtime Effect version)
// Kiri = kaca (refraksi + blur), kanan = gambar asli.

uniform vec2  resolution;       // ukuran widget (px)
uniform float frequency;        // jumlah ridge vertikal
uniform float amplitudePx;      // kekuatan refraksi (px)
uniform float splitPosition;    // batas kiri/kanan [0..1]
uniform float feather;          // pelunakan batas
uniform float blurRadiusPx;     // 0 = tanpa blur, 2..20 umum
uniform float blurStrength;     // 0 = hanya refraksi, 1 = full blur

layout(binding = 0) uniform sampler2D image; // konten child yang di-blur

out vec4 fragColor;

void main() {
    vec2 res = resolution;
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv = fragCoord / res;

    float freq = max(frequency, 1e-4);
    float ampPx = amplitudePx;
    float split = clamp(splitPosition, 0.0, 1.0);
    float featherWidth = max(feather, 1e-5);
    float blurRadius = max(blurRadiusPx, 0.0);
    float blendStrength = clamp(blurStrength, 0.0, 1.0);
    float widthPx = max(res.x, 1e-3);

    vec3 baseCol = texture(image, uv).rgb;

    // ----- Profil kaca reeded (setengah lingkaran berulang) -----
    float sx = fract(uv.x * freq);
    float s = sx * 2.0 - 1.0;

    float h = sqrt(max(1e-4, 1.0 - s * s));
    float dhds = -s / max(1e-3, h);
    float dsdx = (2.0 * freq) / widthPx;
    float dhdx = dhds * dsdx;

    // Offset refraksi (px -> uv)
    float offsetPx = ampPx * dhdx;
    vec2 uvGlass = uv + vec2(offsetPx / widthPx, 0.0);
    uvGlass = clamp(uvGlass, 0.0, 1.0);

    // Sampel dasar (refraksi tanpa blur)
    vec3 refrCol = texture(image, uvGlass).rgb;

    // ----- Blur 1D (horizontal) untuk meniru frosted/anisotropic -----
    vec3 blurCol = refrCol;
    if (blurRadius > 0.0) {
        float sigma = max(0.001, blurRadius * 0.5);
        vec3 acc = vec3(0.0);
        float wsum = 0.0;

        // Blur sepanjang sumbu-X (tegak lurus ridge)
        for (int i = -5; i <= 5; i++) {
            float x = float(i);
            float w = exp(-0.5 * (x * x) / (sigma * sigma));
            vec2 offs = vec2((x * (blurRadius / 5.0)) / widthPx, 0.0);
            vec2 u = clamp(uvGlass + offs, 0.0, 1.0);
            acc += texture(image, u).rgb * w;
            wsum += w;
        }
        blurCol = acc / max(wsum, 1e-4);
    }

    // Campur refraksi vs blur sesuai strength
    vec3 glassCol = mix(refrCol, blurCol, blendStrength);

    // Kiri = efek kaca, kanan = asli
    float maskRight = smoothstep(split, split + featherWidth, uv.x);
    vec3 col = mix(glassCol, baseCol, maskRight);

    fragColor = vec4(col, 1.0);
}
