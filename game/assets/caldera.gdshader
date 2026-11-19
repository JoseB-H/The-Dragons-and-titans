shader_type spatial;

varying vec2 world_xz;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1, 0)), u.x),
		mix(hash(i + vec2(0, 1)), hash(i + vec2(1)), u.x), u.y);
}

void vertex() {
	world_xz = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xz;
}

void fragment() {
	vec2 p = world_xz;
	vec2 cliff = abs(p);
	float coast = (cliff.x / 14.0) * (cliff.x / 14.0) + (cliff.y / 15.0) * (cliff.y / 15.0);
	if (coast > 1.22 + noise(p * 0.54) * 0.16 && max(cliff.x, cliff.y) > 11.7) {
		discard;
	}
	float terrain = noise(p * 0.42) * 0.67 + noise(p * 2.8) * 0.33;
	vec3 basalt = mix(vec3(0.105, 0.085, 0.086), vec3(0.38, 0.27, 0.21), terrain);
	float grain = noise(p * 33.0);
	float fissure = abs(noise(p * 1.7 + terrain * 1.5) - 0.51);
	basalt *= (0.78 + 0.39 * grain) * mix(0.46, 1.0, smoothstep(0.008, 0.037, fissure));
	float rim = abs(p.x + 0.7 * sin(p.y * 0.49));
	float seam = smoothstep(9.8, 12.8, rim);
	float edge = 0.56 + 0.44 * noise(p * 3.0 + vec2(0.0, TIME * 0.45));
	float channels = smoothstep(0.53, 0.77, noise(p * 1.9 + terrain * 2.0));
	vec3 lava = mix(vec3(0.32, 0.045, 0.012), vec3(1.0, 0.34, 0.055), edge * channels);
	ALBEDO = mix(basalt, lava * 0.55, seam);
	EMISSION = lava * seam * (0.25 + edge * channels * 0.9);
	ROUGHNESS = 0.91;
}
