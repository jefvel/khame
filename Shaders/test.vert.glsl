uniform vec4 pos;
uniform sampler2D texture;

void main() {
    gl_Position = texture2D(texture, vec2(0.4, 0.6));
}