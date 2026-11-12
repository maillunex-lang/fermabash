shader_type canvas_item;
render_mode unshaded;

void fragment() {
	vec2 uv = UV - vec2(0.5);
	float vig = smoothstep(0.12, 0.72, length(uv));
	COLOR = vec4(0.03, 0.07, 0.06, vig * 0.55);
}
