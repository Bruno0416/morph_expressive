#version 460 core
#include <flutter/runtime_effect.glsl>
precision highp float;

uniform vec2 uSize;        // floats 0-1
uniform vec4 uColor;       // floats 2-5
uniform float uReveal;     // float 6
uniform float uLeftRadius; // float 7
uniform float uRightRadius;// float 8
uniform float uStretch;    // float 9, fraction of height contracted
out vec4 fragColor;

void main() {
  vec2 p = FlutterFragCoord().xy;
  // Contract only the cross-axis while the horizontal ink front travels.
  // The mask fills its exact original height again when uStretch reaches 0.
  float inset = 0.5 * uSize.y * clamp(uStretch, 0.0, 0.14);
  float top = inset;
  float bottom = uSize.y - inset;
  float halfHeight = (bottom - top) * 0.5;
  float lh = clamp(uLeftRadius, 0.0, halfHeight);
  float rh = clamp(uRightRadius, 0.0, halfHeight);
  float d = max(top - p.y, p.y - bottom);
  // Round only the exterior ends of each week and of the selected range.
  if (lh > 0.0 && p.x < lh) {
    d = max(d, length(p - vec2(lh, uSize.y * 0.5)) - lh);
  }
  if (rh > 0.0 && p.x > uSize.x - rh) {
    d = max(d, length(p - vec2(uSize.x - rh, uSize.y * 0.5)) - rh);
  }
  float coverage = 1.0 - smoothstep(-0.8, 0.8, d);
  // Feather only the moving front. Once a day is fully revealed, a
  // feathered right edge would leave a dark one-pixel seam at each day.
  float edge = 1.0;
  if (uReveal < 1.0) {
    edge = 1.0 - smoothstep(uReveal * uSize.x - 0.9,
                            uReveal * uSize.x + 0.9, p.x);
  }
  float a = uColor.a * coverage * edge;
  fragColor = vec4(uColor.rgb * a, a);
}
