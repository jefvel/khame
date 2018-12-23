#version 450
precision mediump float;

in vec3 pos;
in vec3 normal;
in vec3 barycentric;

uniform vec2 offset;
uniform mat4 camera;
uniform mat4 perspective;

uniform float time;

out vec3 worldPos;
out vec3 BC;
out vec3 NC;

void main() {
    NC = normal;
    BC = barycentric;
    
    vec4 wp = vec4(pos, 1.0);
    wp.xy += offset;
    
    worldPos = wp.xyz;
    
    gl_Position = perspective * camera * wp;
}