precision mediump float;

#extension GL_OES_standard_derivatives : enable
varying vec3 BC;
varying vec3 NC;

uniform float time;

varying vec3 worldPos;
uniform vec3 cursorPos;

float edgeFactor(){
    vec3 d = fwidth(BC);
    //d *= (.95 - sin(worldPos.z + time) * cos(time * 2.0 + worldPos.z));
    d *= 0.5;
    vec3 a3 = smoothstep(vec3(0.0), d, BC);
    return min(min(a3.x, a3.y), a3.z);
}

vec3 stuff(){
    vec3 color = vec3(0.31, 0.55, 0.74);
    vec3 color2 = vec3(1.0);
    return mix(color, color2, edgeFactor() + (sin(20.0 * (worldPos.x + worldPos.y * 1.2) + time) + 1.0) * 0.5);
}

void main() {
    vec3 color = vec3(0.81, 0.95, 0.74);
    //color = vec3(240.0 / 255.0, 0.0, 120.0 / 255.0);
    vec3 color2 = vec3(0.9);
    
    float dx = 1.0 / 3.0 - BC.x;
    float dy = 1.0 / 3.0 - BC.y;
    float dz = 1.0 / 3.0 - BC.z;
    
    float dist = sqrt(dx * dx + dy * dy + dz * dz);
    
    float t = sin(dist * 20.0 + time) * 0.5;
    t = smoothstep(-0.15, 0.15, t);
    t -= 0.5;
    
    vec3 c = mix(color, color2, 0.5 + t);
    c = vec3(0.8, 0.86, 0.96);
    gl_FragColor = vec4(mix(c, vec3(241.0 / 256.0, 238.0 / 256.0, 238.0 / 256.0), edgeFactor()), 1.0);
    vec3 lightDirection = -normalize(vec3(-1, -1, -1));
    gl_FragColor.rgb = mix(gl_FragColor.rgb, vec3(78.0 / 256.0, 142.0 / 256.0 , 190.0 / 256.0), 0.1 + smoothstep(dot(lightDirection, NC), 0.1, 0.5) * 0.8);
    
    float d = distance(cursorPos, worldPos);
    d -= 0.8 + sin(time * 2.0) * 0.1;
    d *= 50.0;
    d = min(1.0, max(d, -1.0));
    d = 1.0 - abs(d);

    gl_FragColor.rgb -= vec3(0.5) * d;
}