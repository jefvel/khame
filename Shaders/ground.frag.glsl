precision mediump float;
#extension GL_OES_standard_derivatives : enable
varying vec3 BC;

float edgeFactor(){
    vec3 d = fwidth(BC);
    vec3 a3 = smoothstep(vec3(0.0), d*0.9, BC);
    return min(min(a3.x, a3.y), a3.z);
}

void main() {
    // Just output red color
    //gl_FragColor = vec4(0.0, 0.0, 0.0, (1.0-edgeFactor())*0.7);
    gl_FragColor = vec4(mix(vec3(0.31, 0.55, 0.74), vec3(1.0), edgeFactor()), 1.0);
}