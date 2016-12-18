precision mediump float;

uniform float time;
varying vec3 worldPos;

uniform sampler2D tex;
uniform vec4 tileData;

varying vec2 UV;

void main() {
	vec4 color = vec4(0.0);
	color = texture2D(tex, vec2(tileData.xy) + vec2(tileData.zw) * UV + vec2(0.00001));
	
	/*
	if(length(mod(gl_FragCoord.xy, vec2(2.0))) < 1.0) {
		discard;
	}
	*/
	if(color.a < 1.0) {
		discard;
	}

	gl_FragColor = color;
	gl_FragColor.rg = UV;
	
	gl_FragColor = color;
}