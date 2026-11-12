shader_type spatial;
render_mode cull_disabled, diffuse_burley;

uniform float wind : hint_range(0.0, 0.5) = 0.18;
uniform float glow : hint_range(0.0, 1.0) = 0.28;
uniform vec3 albedo_tint : source_color = vec3(1.0);

varying vec3 tint;
varying float v_height;

void vertex() {
	tint = COLOR.rgb * albedo_tint;
	v_height = max(VERTEX.y, 0.0);
	float h = v_height;
	float w1 = sin(TIME * 1.7 + VERTEX.x * 0.85 + VERTEX.z * 0.4) * wind * h;
	float w2 = cos(TIME * 1.25 + VERTEX.z * 0.6) * wind * 0.45 * h;
	VERTEX.x += w1;
	VERTEX.z += w2;
	VERTEX.y += sin(TIME * 0.9 + VERTEX.x) * 0.012 * h;
}

void fragment() {
	vec3 albedo = tint * (0.82 + v_height * 0.35);
	float var = fract(sin(dot(VERTEX.xz, vec2(12.9898, 78.233))) * 43758.5453);
	albedo = mix(albedo * 0.88, albedo * 1.12, var);
	ROUGHNESS = 0.52;
	SPECULAR = 0.28;
	float rim = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 2.3);
	vec3 light_dir = normalize(vec3(0.4, 0.85, 0.25));
	float sss = pow(max(dot(NORMAL, -light_dir), 0.0), 1.8) * 0.3;
	EMISSION = vec3(1.0, 0.8, 0.35) * rim * glow * max(tint.r, 0.2)
		+ albedo * sss * 0.4
		+ vec3(1.0, 0.92, 0.6) * smoothstep(0.6, 0.95, v_height) * glow * 0.5;
}
