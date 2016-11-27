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
varying vec3 NC;

void main() {
    NC = normal;
    BC = barycentric;
    
    vec4 wp = vec4(pos, 1.0);
    wp.xy += offset;
    
    worldPos = wp.xyz;
    
    gl_Position = perspective * camera * wp;
    
}