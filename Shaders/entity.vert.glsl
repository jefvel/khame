precision mediump float;

attribute vec3 pos;

uniform vec2 scale;
uniform vec3 offset;
uniform mat4 camera;
uniform mat4 perspective;

uniform float time;

varying vec3 worldPos;

void main() {
    vec4 wp = vec4(pos, 1.0);
    wp.xy *= scale;
    
    wp.x += offset.x;
    wp.y += offset.y;
    wp.z += offset.z;
    
    wp = camera * wp;
    worldPos = pos;
    
    gl_Position = perspective * wp;
}