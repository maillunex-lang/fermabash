shader_type spatial;
render_mode diffuse_burley;

varying vec3 tint;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

void vertex() {
	tint = COLOR.rgb;
}

void fragment() {
	float grain = noise(VERTEX.xz * 1.8);
	float detail = noise(VERTEX.xz * 5.5);
	vec3 albedo = tint * (0.86 + grain * 0.18 + detail * 0.08);
	ALBEDO = albedo;
	float wet = smoothstep(0.25, 0.55, tint.r) * (1.0 - tint.g * 0.7);
	ROUGHNESS = mix(0.88, 0.35, clamp(wet, 0.0, 1.0));
	SPECULAR = mix(0.05, 0.35, clamp(wet, 0.0, 1.0));
}
