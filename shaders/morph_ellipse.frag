#version 460 core
#include <flutter/runtime_effect.glsl>
uniform vec2 uSize;
uniform vec2 uRadii;
uniform vec4 uPremultipliedColor;
uniform float uDpr;
out vec4 fragColor;
void main() {
  vec2 p = FlutterFragCoord().xy - uSize * 0.5;
  vec2 q = p / uRadii;
  float f = length(q) - 1.0;
  // Implicit ellipse gradient converts the edge function to logical pixels.
  float gradient = max(length(q / uRadii), 0.000001);
  float distanceToEdge = f / gradient;
  float coverage = 1.0 - smoothstep(-0.5 / uDpr, 0.5 / uDpr, distanceToEdge);
  fragColor = uPremultipliedColor * coverage;
}
