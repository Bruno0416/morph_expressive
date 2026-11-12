#version 460 core
#include <flutter/runtime_effect.glsl>
precision highp float;

uniform vec2 uSize;        // floats 0-1
uniform float uProgress;   // float 2
uniform float uEdge;       // float 3, y of moving front
uniform float uOriginX;    // float 4, normalized pointer position
uniform float uTension;    // float 5, normalized transient strength
uniform vec4 uColor;      // floats 6-9, straight rgba

out vec4 fragColor;

void main() {
  vec2 p = FlutterFragCoord().xy;
  float width = max(uSize.x, 1.0);
  float dist = abs(p.y - uEdge);
  float glow = exp(-dist * dist / 64.0);
  float proximity = 0.7 + 0.3 *
      (1.0 - abs(p.x / width - clamp(uOriginX, 0.0, 1.0)));
  float alpha = clamp(uColor.a * 0.16 * uTension * glow * proximity, 0.0, 1.0);
  fragColor = vec4(uColor.rgb * alpha, alpha);
}
