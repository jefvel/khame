precision mediump float;

attribute vec3 pos;
attribute vec3 normal;
attribute vec3 barycentric;

uniform vec2 offset;
uniform mat4 camera;
uniform mat4 perspective;

uniform float time;

varying vec3 worldPos;
varying vec3 BC;

void main() {
    BC = barycentric;
    vec4 wp = vec4(pos, 1.0);
    
    wp.x += offset.x;
    wp.y += offset.y;
    
    worldPos = wp.xyz;
    
    wp = camera * wp;
    
    gl_Position = perspective * wp;
}