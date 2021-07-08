shader_type canvas_item;

uniform float amount = 6.0;
uniform float speed = 2.0;

void vertex() {
	VERTEX = VERTEX + vec2(sin(TIME / speed + VERTEX.x)) * amount;
}