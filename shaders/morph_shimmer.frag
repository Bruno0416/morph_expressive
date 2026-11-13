#include <flutter/runtime_effect.glsl>
precision highp float;
uniform vec2 uSize;
uniform vec2 uOrigin;
uniform vec2 uGroupSize;
uniform float uPhase;
uniform float uDirection;
uniform float uIntensity;
uniform vec4 uBase;
uniform vec4 uHighlight;
uniform float uRadius;
uniform float uDpr;
uniform float uAngle; // radians, band tilt; 0 = original axis-aligned band
out vec4 fragColor;
void main() {
  vec2 p = FlutterFragCoord().xy;
  vec2 g = p + uOrigin;
  bool horizontal = uDirection < 1.5;
  // Band normal: the axis-aligned normal rotated by uAngle (clockwise on screen).
  vec2 n = horizontal ? vec2(cos(uAngle), sin(uAngle)) : vec2(-sin(uAngle), cos(uAngle));
  float len = max(1., abs(n.x) * uGroupSize.x + abs(n.y) * uGroupSize.y);
  float umin = min(0., n.x * uGroupSize.x) + min(0., n.y * uGroupSize.y);
  float axis = (dot(g, n) - umin) / len;
  if (uDirection == 1. || uDirection == 3.) axis = 1.-axis;
  // Visual band width stays .2 of the un-tilted axis extent, whatever the angle.
  float baseExtent = max(1., horizontal ? uGroupSize.x : uGroupSize.y);
  float edge = clamp(.2 * baseExtent / len, .02, .45);
  float light = (1.-smoothstep(0., edge, abs(axis - (uPhase*1.6-.3)))) * uIntensity;
  vec4 color = mix(uBase,uHighlight,light);
  vec2 q = abs(p-uSize*.5) - uSize*.5 + uRadius;
  float dist = length(max(q,0.)) + min(max(q.x,q.y),0.) - uRadius;
  float coverage = 1.-smoothstep(-.5/uDpr,.5/uDpr,dist);
  fragColor = vec4(color.rgb * color.a, color.a) * coverage;
}
