shader_type canvas_item;

void fragment() {
	vec4 pixel_colour = texture(TEXTURE, UV*2);
	COLOR = pixel_colour;
}
