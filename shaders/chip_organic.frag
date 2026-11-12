#version 460 core
#include <flutter/runtime_effect.glsl>

precision highp float;

uniform vec2 uCanvasSize;  // float 0-1
uniform vec4 uColor;       // float 2-5, straight RGBA
uniform float uRadius;     // float 6
uniform float uPadding;    // float 7
uniform float uProgress;   // float 8 (0..1)
uniform float uIntensity;  // float 9 (0..1)
uniform float uSeed;       // float 10, stable per interaction
uniform float uBloom;      // float 11 (0 = stretch, 1 = bloom)
uniform float uVertical;   // float 12 (0 = horizontal, 1 = vertical)
uniform vec2 uBloomOrigin; // float 13-14, normalized tap position

out vec4 fragColor;

float roundedBox(vec2 p, vec2 halfSize, float radius) {
  vec2 q = abs(p) - (halfSize - vec2(radius));
  return length(max(q, vec2(0.0))) + min(max(q.x, q.y), 0.0) - radius;
}

void main() {
  float t = clamp(uProgress, 0.0, 1.0);
  vec2 inner = max(uCanvasSize - vec2(2.0 * uPadding), vec2(0.01));
  float bloom = step(0.5, uBloom);
  vec2 pillSize = inner;
  float radius = uRadius;
  float alpha = 1.0;

  if (bloom > 0.5) {
    float maxDiameter = min(inner.x, inner.y);
    float minDiameter = min(maxDiameter, 4.0);
    if (t < 0.78) {
      float phase = t / 0.78;
      float diameter = mix(minDiameter, maxDiameter, phase * phase);
      pillSize = vec2(diameter);
      radius = diameter * 0.5;
    } else {
      float phase = (t - 0.78) / 0.22;
      phase = 1.0 - pow(1.0 - phase, 3.0);
      pillSize = mix(vec2(maxDiameter), inner, phase);
      radius = mix(maxDiameter * 0.5, uRadius, phase);
    }
    alpha = smoothstep(0.0, 0.12, t);
  }

  // Start the circular bloom under the pointer, then converge gently on the
  // exact center as the pill fills. At rest it has identical geometry.
  vec2 center = uCanvasSize * 0.5;
  if (bloom > 0.5) {
    vec2 tapCenter = vec2(uPadding) + inner * clamp(uBloomOrigin, 0.0, 1.0);
    float settle = t * t * (3.0 - 2.0 * t);
    center = mix(tapCenter, center, settle);
  }
  vec2 p = FlutterFragCoord().xy - center;
  float envelope = (t <= 0.0 || t >= 1.0)
      ? 0.0 : max(0.0, sin(3.14159265 * t));
  vec2 halfSize = pillSize * 0.5;
  radius = clamp(radius, 0.0, min(halfSize.x, halfSize.y));
  float sdf;

  if (bloom > 0.5) {
    // Keep the original irregular first-selection bloom unchanged. Noise
    // displaces its perimeter, not its pixels, and fades out at rest.
    sdf = roundedBox(p, halfSize, radius);
    float angle = atan(p.y, p.x);
    float wave =
        0.58 * sin(3.0 * angle + uSeed * 1.73 + t * 1.2) +
        0.29 * sin(5.0 * angle - uSeed * 2.11 - t * 0.7) +
        0.13 * sin(7.0 * angle + uSeed * 0.61 + t * 1.5);
    float amplitude = min(pillSize.y * 0.16, 7.0) * uIntensity * envelope;
    sdf += wave * amplitude;
  } else {
    // Stretch is deliberately symmetrical and predictable: gently pinch the
    // vertical profile ONLY across the straight middle of the capsule.
    // Beyond the start of either rounded end, coreWeight is exactly zero;
    // the original side caps are therefore preserved pixel for pixel.
    vec2 orientedPoint = uVertical > 0.5 ? p.yx : p;
    vec2 orientedHalf = uVertical > 0.5 ? halfSize.yx : halfSize;
    // A horizontal chip protects its rounded side caps. For a vertically
    // moving rail/drawer the cross-axis is the width; use the vertical
    // travel profile so even a short pill can compress its width centrally.
    float straightHalfWidth = uVertical > 0.5
        ? orientedHalf.x : max(0.0, orientedHalf.x - radius);
    float x = abs(orientedPoint.x) / max(straightHalfWidth, 0.001);
    float coreWeight = pow(max(0.0, 1.0 - x * x), 2.0);
    // A circle has no straight center to pinch. Gradually enable the waist
    // only once a genuine straight section develops during the stretch.
    coreWeight *= uVertical > 0.5 ? 1.0
        : smoothstep(0.0, 10.0, straightHalfWidth);
    float compression = 0.12 * uIntensity * envelope * coreWeight;
    vec2 shaped = vec2(orientedPoint.x, orientedPoint.y / (1.0 - compression));
    sdf = roundedBox(shaped, orientedHalf, radius);
  }

  float coverage = 1.0 - smoothstep(-0.85, 0.85, sdf);
  float a = uColor.a * coverage * alpha;
  fragColor = vec4(uColor.rgb * a, a);
}
