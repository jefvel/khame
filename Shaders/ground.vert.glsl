precision mediump float;

attribute vec3 pos;
attribute vec3 barycentric;

uniform mat4 camera;
uniform mat4 perspective;

uniform float time;

varying vec3 worldPos;
varying vec3 BC;

void main() {
    BC = barycentric;
    // Just output position
    vec4 wp = camera * vec4(pos, 1.0);
    worldPos = pos;
    
    gl_Position = perspective * wp;
}