shader_type spatial;
render_mode unshaded, cull_disabled;

varying vec2 landscape;

float hash(vec2 point) {
	return fract(sin(dot(point, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 point) {
	vec2 cell = floor(point);
	vec2 edge = fract(point);
	edge = edge * edge * (3.0 - 2.0 * edge);
	return mix(mix(hash(cell), hash(cell + vec2(1, 0)), edge.x),
		mix(hash(cell + vec2(0, 1)), hash(cell + vec2(1)), edge.x), edge.y);
}

void vertex() {
	landscape = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xz;
}

void fragment() {
	vec2 drift = vec2(TIME * 0.11, -TIME * 0.075);
	float cloud = noise(landscape * 0.12 + drift) * 0.70;
	cloud += noise(landscape * 0.26 - drift * 0.6) * 0.23;
	cloud += noise(landscape * 0.55 + drift) * 0.07;
	ALBEDO = mix(vec3(0.12, 0.18, 0.28), vec3(0.58, 0.69, 0.76), smoothstep(0.18, 0.83, cloud));
}
