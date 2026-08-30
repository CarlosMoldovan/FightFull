shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;

uniform float distortion_strength : hint_range(0.0, 1.0) = 0.0;
uniform vec2 distortion_center = vec2(0.5, 0.5);


void fragment() {

	vec2 uv = SCREEN_UV;

	vec2 direction = uv - distortion_center;

	float distance_from_center = length(direction);

	float distortion = distortion_strength *
		(1.0 - smoothstep(0.0, 0.7, distance_from_center));

	uv -= direction * distortion;

	COLOR = texture(screen_texture, uv);
}