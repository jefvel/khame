precision mediump float;

#extension GL_OES_standard_derivatives : enable
varying vec3 BC;

uniform float time;

varying vec3 worldPos;
uniform vec3 cursorPos;

float edgeFactor(){
    vec3 d = fwidth(BC);
    vec3 a3 = smoothstep(vec3(0.0), d*(1.95 - sin(worldPos.z + time) * cos(time * 2.0 + worldPos.z)), BC);
    return min(min(a3.x, a3.y), a3.z);
}

vec3 stuff(){
    vec3 color = vec3(0.31, 0.55, 0.74);
    vec3 color2 = vec3(1.0);
    return mix(color, color2, edgeFactor() + (sin(20.0 * (worldPos.x + worldPos.y * 1.2) + time) + 1.0) * 0.5);
}

void main() {
    vec3 color = vec3(0.31, 0.55, 0.74);
    //color = vec3(240.0 / 255.0, 0.0, 120.0 / 255.0);
    vec3 color2 = vec3(0.0);
    
    float dx = 1.0 / 3.0 - BC.x;
    float dy = 1.0 / 3.0 - BC.y;
    float dz = 1.0 / 3.0 - BC.z;
    
    float dist = sqrt(dx * dx + dy * dy + dz * dz);
    
    float t = sin(dist * 20.0 + time) * 0.5;
    t = smoothstep(-0.15, 0.15, t);
    t -= 0.5;
    
    vec3 c = mix(color, color2, 0.5 + t);
    c = vec3(0.5);
    gl_FragColor = vec4(mix(c * vec3(1.4), vec3(241.0 / 256.0, 238.0 / 256.0, 238.0 / 256.0), edgeFactor()), 1.0);
    gl_FragColor.rgb -= vec3(smoothstep(0.8, 0.0, min(distance(cursorPos, worldPos), 1.0))) * 0.5;
}