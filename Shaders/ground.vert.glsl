precision mediump float;

attribute vec3 pos;
attribute vec3 barycentric;

uniform mat4 camera;
uniform mat4 perspective;

varying vec3 BC;

void main() {
    BC = barycentric;
    // Just output position
    gl_Position = perspective * camera * vec4(pos, 1.0);
}