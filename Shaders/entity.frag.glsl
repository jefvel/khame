precision mediump float;

uniform float time;
varying vec3 worldPos;

void main() {
	vec4 color = vec4(0.0);
	color.a = 0.4;
	color.r = 0.4;
	color.g = 0.6;
	
	if(mod(gl_FragCoord.x, 2.0) > 1.0) {
		if(mod(gl_FragCoord.y, 2.0) > 1.0) {
			discard;
		}
	}
	
	gl_FragColor = color;
}