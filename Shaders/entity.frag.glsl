#version 450
precision mediump float;

uniform float time;
in vec3 worldPos;

uniform sampler2D tex;
uniform vec4 tileData;

in vec2 UV;

out vec4 FragColor;

void main() {
	vec4 color = vec4(0.0);
	color = texture(tex, vec2(tileData.xy) + vec2(tileData.zw) * UV + vec2(0.00001));
	
	/*
	if(length(mod(gl_FragCoord.xy, vec2(2.0))) < 1.0) {
		discard;
	}
	*/
	if(color.a < 1.0) {
		discard;
	}

	FragColor = color;
	FragColor.rg = UV;
	
	FragColor = color;
}