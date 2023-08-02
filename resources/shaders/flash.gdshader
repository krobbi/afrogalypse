shader_type canvas_item;

uniform vec3 flash_color : source_color;
uniform float flash_amount : hint_range(0.0, 1.0);

void fragment() {
	vec4 texel = texture(TEXTURE, UV);
	COLOR = vec4(mix(texel.rgb, flash_color, flash_amount), texel.a);
}
