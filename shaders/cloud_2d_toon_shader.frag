#include <flutter/runtime_effect.glsl>

// Toon-style cloud shader adapted for Flutter runtime effects.

#define TAU 6.28318530718

uniform vec2 resolution;
uniform float time;
uniform float windSpeed;
uniform vec3 backColor;
uniform vec3 cloudColor;
uniform float blurScale;
uniform float opacity;

out vec4 fragColor;

float Func(float pX) {
  return 0.6 * (0.5 * sin(0.1 * pX) + 0.5 * sin(0.553 * pX) + 0.7 * sin(1.2 * pX));
}

float FuncR(float pX) {
  return 0.5 + 0.25 * (1.0 + sin(mod(40.0 * pX, TAU)));
}

float Layer(vec2 pQ, float pT) {
  vec2 Qt = 3.5 * pQ;
  pT *= 0.5;
  Qt.x += pT;

  float Xi = floor(Qt.x);
  float Xf = Qt.x - Xi - 0.5;

  vec2 C;
  float Yi;
  float D = 1.0 - step(Qt.y, Func(Qt.x));

  Yi = Func(Xi + 0.5);
  C = vec2(Xf, Qt.y - Yi);
  D = min(D, length(C) - FuncR(Xi + pT / 80.0));

  Yi = Func(Xi + 1.0 + 0.5);
  C = vec2(Xf - 1.0, Qt.y - Yi);
  D = min(D, length(C) - FuncR(Xi + 1.0 + pT / 80.0));

  Yi = Func(Xi - 1.0 + 0.5);
  C = vec2(Xf + 1.0, Qt.y - Yi);
  D = min(D, length(C) - FuncR(Xi - 1.0 + pT / 80.0));

  return min(1.0, D);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  vec2 res = max(resolution, vec2(1.0));
  vec2 centered = fragCoord - res * 0.5;
  float minDim = min(res.x, res.y);
  vec2 UV = 2.0 * centered / max(minDim, 1.0);

  vec3 Color = backColor;

  for (int step = 0; step <= 5; ++step) {
    float J = float(step) * 0.2;
    float Lt = (time * windSpeed) * (0.5 + 2.0 * J) * (1.0 + 0.1 * sin(226.0 * J)) + 17.0 * J;
    vec2 Lp = vec2(0.0, 0.3 + 1.5 * (J - 0.5));
    float L = Layer(UV + Lp, Lt);

    float blur = 4.0 * (0.5 * abs(2.0 - 5.0 * J)) / (11.0 - 5.0 * J);
    blur *= blurScale;

    float V = mix(0.0, 1.0, 1.0 - smoothstep(0.0, 0.01 + 0.2 * blur, L));
    vec3 Lc = mix(cloudColor, vec3(1.0), J);

    Color = mix(Color, Lc, V);
  }

  fragColor = vec4(Color, opacity);
}
