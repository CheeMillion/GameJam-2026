shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float blur_radius = 2.5;
uniform vec4 dim_tint : source_color = vec4(0.035, 0.025, 0.05, 0.3);

void fragment() {
	vec2 step_uv = SCREEN_PIXEL_SIZE * blur_radius;
	vec3 blurred = texture(screen_texture, SCREEN_UV).rgb * 0.2;
	blurred += texture(screen_texture, SCREEN_UV + vec2(step_uv.x, 0.0)).rgb * 0.1;
	blurred += texture(screen_texture, SCREEN_UV - vec2(step_uv.x, 0.0)).rgb * 0.1;
	blurred += texture(screen_texture, SCREEN_UV + vec2(0.0, step_uv.y)).rgb * 0.1;
	blurred += texture(screen_texture, SCREEN_UV - vec2(0.0, step_uv.y)).rgb * 0.1;
	blurred += texture(screen_texture, SCREEN_UV + step_uv).rgb * 0.1;
	blurred += texture(screen_texture, SCREEN_UV - step_uv).rgb * 0.1;
	blurred += texture(screen_texture, SCREEN_UV + vec2(step_uv.x, -step_uv.y)).rgb * 0.1;
	blurred += texture(screen_texture, SCREEN_UV + vec2(-step_uv.x, step_uv.y)).rgb * 0.1;
	COLOR = vec4(mix(blurred, dim_tint.rgb, dim_tint.a), 1.0);
}
