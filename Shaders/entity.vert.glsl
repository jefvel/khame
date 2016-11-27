precision mediump float;

attribute vec3 pos;
attribute vec2 uv;

uniform vec2 scale;
uniform vec3 offset;
uniform mat4 camera;
uniform mat4 perspective;

uniform float time;

varying vec3 worldPos;
varying vec2 UV;

void main() {
    UV = uv;
    vec4 wp = vec4(pos, 1.0);
    wp.xz *= scale;
    
    wp.x += offset.x;
    wp.y += offset.y;
    wp.z += offset.z;
    
    wp = camera * wp;
    worldPos = pos;
    
    gl_Position = perspective * wp;
}