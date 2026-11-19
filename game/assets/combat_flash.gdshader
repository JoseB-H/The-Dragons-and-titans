shader_type spatial;
render_mode unshaded, blend_add, cull_disabled, depth_draw_never, shadows_disabled, fog_disabled;

uniform vec4 tint : source_color = vec4(1.0, 0.54, 0.15, 1.0);
uniform float progress : hint_range(0.0, 1.0) = 0.0;

void vertex() {
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(
		vec4(INV_VIEW_MATRIX[0].xyz, 0.0),
		vec4(INV_VIEW_MATRIX[1].xyz, 0.0),
		vec4(INV_VIEW_MATRIX[2].xyz, 0.0),
		MODEL_MATRIX[3]);
}

void fragment() {
	vec2 center = UV * 2.0 - 1.0;
	float radius = length(center);
	float pulse = mix(0.19, 0.81, progress);
	float ring = 1.0 - smoothstep(0.025, 0.105, abs(radius - pulse));
	float hot = exp(-radius * radius * 15.0) * (1.0 - smoothstep(0.0, 0.58, progress));
	float edge = (1.0 - smoothstep(0.72, 0.97, radius)) * (1.0 - progress);
	ALBEDO = mix(tint.rgb, vec3(1.0, 0.96, 0.79), hot);
	ALPHA = edge * (hot * 0.93 + ring * 0.51);
}
