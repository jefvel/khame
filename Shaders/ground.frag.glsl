precision mediump float;
#extension GL_OES_standard_derivatives : enable
varying vec3 BC;

uniform float time;

varying vec3 worldPos;

float edgeFactor(){
    vec3 d = fwidth(BC);
    vec3 a3 = smoothstep(vec3(0.0), d*(1.95 - sin(worldPos.z + time) * cos(worldPos.y - time * 2.0 + worldPos.z)), BC);
    return min(min(a3.x, a3.y), a3.z);
}

void main() {
    // Just output red color
    //gl_FragColor = vec4(0.0, 0.0, 0.0, (1.0-edgeFactor())*0.7);
    vec3 color = vec3(0.31, 0.55, 0.74);
    vec3 color2 = worldPos;
    color2 = vec3(1.0);
    gl_FragColor = vec4(mix(color,color2, edgeFactor()), 1.0);
}