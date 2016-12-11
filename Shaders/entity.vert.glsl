precision mediump float;

attribute vec3 pos;
attribute vec2 uv;

uniform vec2 scale;
uniform vec2 spriteOrigin;
uniform vec3 offset;
uniform mat4 camera;
uniform mat4 perspective;

uniform float time;

uniform float rotation;

varying vec3 worldPos;
varying vec2 UV;

void main() {
    mat3 rot = mat3(0.0);
    float cosR = cos(rotation);
    float sinR = sin(rotation);
    rot[0][0] = cosR;
    rot[1][1] = cosR;
    rot[1][0] = -sinR;
    rot[0][1] = sinR;
    
    UV = uv;
    vec4 wp = vec4(offset.xyz, 1.0);
    wp = camera * wp;
    wp.xy += (rot * vec3(pos.xz - spriteOrigin, 0.0)).xy * scale.xy;
    
    gl_Position = perspective * wp;
    gl_Position.z -= 0.005;
}