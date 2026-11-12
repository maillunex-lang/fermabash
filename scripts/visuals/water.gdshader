shader_type spatial;
render_mode blend_mix, cull_disabled, depth_draw_opaque, diffuse_burley;

uniform vec3 deep : source_color = vec3(0.04, 0.20, 0.26);
uniform vec3 shallow : source_color = vec3(0.26, 0.55, 0.46);

void fragment() {
	vec2 uv = UV * 8.0;
	float w1 = sin(uv.x * 3.6 + TIME * 1.5);
	float w2 = cos(uv.y * 2.8 - TIME * 1.1);
	float ripple = w1 * w2;
	float fresnel = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 2.8);
	ALBEDO = mix(deep, shallow, 0.32 + ripple * 0.1);
	ROUGHNESS = 0.06;
	METALLIC = 0.15;
	SPECULAR = 0.72;
	vec3 sun = vec3(1.0, 0.88, 0.55);
	float spec = pow(max(dot(reflect(-vec3(0.4, 0.85, 0.2), NORMAL), VIEW), 0.0), 32.0);
	EMISSION = sun * spec * 0.55 + vec3(0.65, 0.85, 0.75) * fresnel * 0.35;
	ALPHA = 0.88;
}
