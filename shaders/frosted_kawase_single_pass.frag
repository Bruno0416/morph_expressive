#version 460 core
#include <flutter/runtime_effect.glsl>
precision highp float;

// This is ONE pass. It is not the multipass/downsampled ZenithBlur pipeline.
// ImageFilter.shader sets the first vec2 and the first sampler automatically.
uniform vec2 u_size;
uniform float u_step;
uniform sampler2D u_backdrop;

out vec4 fragColor;

void main() {
  vec2 uv = FlutterFragCoord().xy / max(u_size, vec2(1.0));
#ifdef IMPELLER_TARGET_OPENGLES
  uv.y = 1.0 - uv.y;
#endif
  vec2 delta = vec2(max(u_step, 0.0)) / max(u_size, vec2(1.0));
  // Bilinear diagonal Kawase footprint, 5 texture reads (not Gaussian parity).
  vec4 sum = 4.0 * texture(u_backdrop, uv);
  sum += texture(u_backdrop, uv + vec2( delta.x,  delta.y));
  sum += texture(u_backdrop, uv + vec2(-delta.x,  delta.y));
  sum += texture(u_backdrop, uv + vec2( delta.x, -delta.y));
  sum += texture(u_backdrop, uv + vec2(-delta.x, -delta.y));
  fragColor = sum * 0.125;
}
