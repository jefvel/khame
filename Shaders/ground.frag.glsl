precision mediump float;

#extension GL_OES_standard_derivatives : enable
varying vec3 BC;

uniform float time;
varying vec3 worldPos;

float edgeFactor(){
    vec3 d = fwidth(BC);
    vec3 a3 = smoothstep(vec3(0.0), d*(1.95 - sin(worldPos.z + time) * cos(time * 2.0 + worldPos.z)), BC);
    return min(min(a3.x, a3.y), a3.z);
}

void main() {
    vec3 color = vec3(0.31, 0.55, 0.74);
    vec3 color2 = vec3(1.0);
    
    float dx = 1.0 / 3.0 - BC.x;
    float dy = 1.0 / 3.0 - BC.y;
    float dz = 1.0 / 3.0 - BC.z;
    
    float dist = sqrt(dx * dx + dy * dy + dz * dz);
    
    gl_FragColor = vec4(mix(color, color2, 0.5 + sin(dist * 20.0 + time) * 0.5), 1.0);
    gl_FragColor = vec4(mix(gl_FragColor.rgb, color2, edgeFactor()), 1.0);
}