#include <flutter/runtime_effect.glsl>

// Rainy Glass – clean core (drops + trail + refraction + bokeh)

#define S(a,b,t) smoothstep(a,b,t)

uniform vec2 resolution;     // widget size in pixels (local render target)
uniform float time;          // elapsed time in seconds
uniform float rainAmount;    // 0..1 amount of rain
uniform float maxBlur;       // maximum blur radius (px)
uniform float minBlur;       // minimum blur radius (px)
uniform float refractPx;     // refraction strength (px)
uniform vec2 screenSize;     // full screen size in pixels
uniform vec2 widgetOrigin;   // this layer's top-left in screen pixels
uniform float screenSpaceDrops; // 1: lock drops to screen, 0: local widget

layout(binding = 0) uniform sampler2D image; // captured child content

out vec4 fragColor;

vec3 N13(float p){ vec3 p3=fract(vec3(p)*vec3(.1031,.11369,.13787));
p3+=dot(p3,p3.yzx+19.19); return fract(vec3((p3.x+p3.y)*p3.z,(p3.x+p3.z)*p3.y,(p3.y+p3.z)*p3.x)); }
float N(float t){ return fract(sin(t*12345.564)*7658.76); }
float Saw(float b,float t){ return S(0.,b,t)*S(1.,b,t); }

vec2 DropLayer2(vec2 uv,float t){
    vec2 UV=uv;
    uv.y+=t*0.75;
    vec2 a=vec2(6.,1.), grid=a*2.;
    vec2 id=floor(uv*grid);
    float colShift=N(id.x); uv.y+=colShift;
    id=floor(uv*grid);
    vec3 n=N13(id.x*35.2+id.y*2376.1);
    vec2 st=fract(uv*grid)-vec2(.5,0.);
    float x=n.x-.5;
    float y=UV.y*20.; float wiggle=sin(y+sin(y));
    x+=wiggle*(.5-abs(x))*(n.z-.5); x*=.7;
    float ti=fract(t+n.z); y=(Saw(.85,ti)-.5)*.9+.5;
    vec2 p=vec2(x,y);
    float d=length((st-p)*a.yx);
    float mainDrop=S(.4,.0,d);

    float r=sqrt(S(1.,y,st.y));
    float cd=abs(st.x-x);
    float trail=S(.23*r,.15*r*r,cd);
    float trailFront=S(-.02,.02,st.y-y);
    trail*=trailFront*r*r;

    // micro droplets on trail
    float y2=fract(UV.y*10.)+(st.y-.5);
    float dd=length(st-vec2(x,y2));
    float droplets=S(.3,0.,dd);

    float m = mainDrop + droplets*r*trailFront;
    return vec2(m, trail);
}

float StaticDrops(vec2 uv,float t){
    uv*=40.; vec2 id=floor(uv); uv=fract(uv)-.5;
    vec3 n=N13(id.x*107.45+id.y*3543.654);
    vec2 p=(n.xy-.5)*.7; float d=length(uv-p);
    float fade=Saw(.025,fract(t+n.z));
    return S(.3,0.,d)*fract(n.z*10.)*fade;
}

vec2 Drops(vec2 uv,float t,float l0,float l1,float l2){
    float s=StaticDrops(uv,t)*l0;
    vec2  m1=DropLayer2(uv,t)*l1;
    vec2  m2=DropLayer2(uv*1.85,t)*l2;
    float c=s+m1.x+m2.x; c=S(.3,1.,c);
    return vec2(c, max(m1.y*l0, m2.y*l1));
}

vec3 sampleRainBlur(vec2 uv, vec2 res, float radiusPx) {
    float radius = max(radiusPx, 0.0);
    if (radius < 0.5) {
        return texture(image, clamp(uv, 0.0, 1.0)).rgb;
    }
    vec2 px = vec2(radius) / res;
    float sigma = max(radius * 0.35, 0.001);
    float invSigma2 = 1.0 / (sigma * sigma * 2.0);
    vec3 acc = vec3(0.0);
    float wsum = 0.0;
    for (int x = -2; x <= 2; x++) {
        for (int y = -2; y <= 2; y++) {
            vec2 offs = vec2(float(x), float(y));
            float dist2 = dot(offs, offs);
            float w = exp(-dist2 * invSigma2);
            vec2 sampleUv = clamp(uv + offs * px, 0.0, 1.0);
            acc += texture(image, sampleUv).rgb * w;
            wsum += w;
        }
    }
    return acc / max(wsum, 1e-4);
}

void main() {
    vec2 resLocal = resolution;
    vec2 resScreen = screenSize;
    vec2 fragCoordLocal = FlutterFragCoord().xy;
    vec2 fragCoordScreen = fragCoordLocal + widgetOrigin;

    // Local (widget) uv
    vec2 uvLocal = (fragCoordLocal - 0.5 * resLocal) / resLocal.y;   // aspect-correct
    vec2 UVLocal = fragCoordLocal / resLocal;

    // Screen-anchored uv (does not move when widget scrolls)
    vec2 uvScreen = (fragCoordScreen - 0.5 * resScreen) / resScreen.y;

    // Choose which space to generate the drop field in
    vec2 uv = mix(uvLocal, uvScreen, clamp(screenSpaceDrops, 0.0, 1.0));

    float T = time;

    float staticDrops = S(-.5, 1., rainAmount)*2.;
    float layer1      = S(.25, .75, rainAmount);
    float layer2      = S(.0 , .5 , rainAmount);

    float dropTime = -T * 0.2;
    vec2 c = Drops(uv, dropTime, staticDrops, layer1, layer2);

    // gradient → normal (kecilkan & skala resolusi biar halus)
    vec2 resBase = mix(resLocal, resScreen, clamp(screenSpaceDrops, 0.0, 1.0));
    vec2 e = vec2(1.0/resBase.x, 1.0/resBase.y);
    float cx = Drops(uv + vec2(e.x,0.), dropTime, staticDrops, layer1, layer2).x;
    float cy = Drops(uv + vec2(0.,e.y), dropTime, staticDrops, layer1, layer2).x;
    vec2 n2 = vec2(cx - c.x, cy - c.x);
    float lenN = length(n2) + 1e-5;
    // Compute pixel-space offset from the gradient, then convert to local-uv
    vec2 offsetPx = (n2 / lenN) * refractPx;
    vec2 offset = offsetPx / resLocal;

    // focus blur: luar blur, di tetes/trail lebih tajam
    float focus = mix(maxBlur - c.y, minBlur, S(.1,.2,c.x));

    vec2 sampleUv = clamp(UVLocal + offset, 0.0, 1.0);
    vec3 col = sampleRainBlur(sampleUv, resLocal, focus);

    // sedikit rim-highlight
    float rim = smoothstep(.0,.02, abs(c.x - 0.5)) * 0.08;
    col += rim;

    // vignette ringan
    vec2 d = UVLocal - 0.5; col *= 1.0 - 0.6*dot(d,d);

    fragColor = vec4(col,1.0);
}
