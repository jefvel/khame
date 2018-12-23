#version 450
precision mediump float;

in vec2 pos;
in vec2 uv;

uniform vec2 scale;
uniform vec2 spriteOrigin;
uniform vec3 offset;
uniform mat4 camera;
uniform mat4 perspective;

uniform vec4 screenData;

uniform float rotation;

uniform vec2 screenRes;
uniform vec2 pixelSize;

out vec3 worldPos;
out vec2 UV;

void main() {
    // Construct 2d rotation matrix (around z axis)
    mat3 rot = mat3(0.0);
    float cosR = cos(rotation);
    float sinR = sin(rotation);
    rot[0][0] =  cosR;
    rot[1][1] =  cosR;
    rot[1][0] = -sinR;
    rot[0][1] =  sinR;
    
    UV = uv;
    
    // Sprite position in world
    vec4 wp = vec4(offset.xyz, 1.0);
    
    // Transform to camera space -> perspective space
    wp = camera * wp;
    wp = perspective * wp;
    
    // Set the pos for billboard
    vec2 w_pos = pos.xy - spriteOrigin;
    
    // Rotate
    w_pos = (rot * vec3(w_pos, 0.0)).xy;
    
    // Scale according to screen size
    w_pos *= scale.xy;
    w_pos *= wp.w * 2.0; // Clip space = -1 to 1
    w_pos /= screenData.xy;
    
    wp.xy += w_pos;
    
    // Nudge a bit closer to camera to prevent clipping with 3d objects
    wp.z -= 0.01;
    
    gl_Position = wp;
}