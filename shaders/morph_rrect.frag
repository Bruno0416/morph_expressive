#version 460 core
#include <flutter/runtime_effect.glsl>
uniform vec2 uSize;
uniform float uRadius;
uniform vec4 uPremultipliedColor;
uniform float uDpr;
out vec4 fragColor;
// Exact signed distance to a rounded rectangle centered at the origin.
float sdRoundBox(vec2 p, vec2 halfSize, float r) {
  vec2 q = abs(p) - halfSize + r;
  return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}
void main() {
  vec2 p = FlutterFragCoord().xy - uSize * 0.5;
  float r = clamp(uRadius, 0.0, min(uSize.x, uSize.y) * 0.5);
  float d = sdRoundBox(p, uSize * 0.5, r);
  // Coverage band of one physical pixel, in logical units.
  float coverage = 1.0 - smoothstep(-0.5 / uDpr, 0.5 / uDpr, d);
  fragColor = uPremultipliedColor * coverage;
}
