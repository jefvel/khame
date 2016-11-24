precision mediump float;

uniform float time;
varying vec3 worldPos;

void main() {
	vec4 color = vec4(0.0);
	color.r = 86.0 / 256.0;
	color.g = 86.0 / 256.0;
	color.b = 59.0 / 256.0;
	
	
	gl_FragColor = color;
}