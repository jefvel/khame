precision mediump float;

attribute vec3 pos;
attribute vec2 uv;

uniform vec2 scale;
uniform vec2 spriteOrigin;
uniform vec3 offset;
uniform mat4 camera;
uniform mat4 perspective;

uniform float time;

varying vec3 worldPos;
varying vec2 UV;

void main() {
    UV = uv;
    vec4 wp = vec4(offset.xyz, 1.0);
    wp = camera * wp;
    wp.xy += (pos.xz - spriteOrigin) * scale.xy;
    
    gl_Position = perspective * wp;
}