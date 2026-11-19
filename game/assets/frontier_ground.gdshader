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

float distance_to_route(vec2 p, vec2 origin, vec2 destination) {
	vec2 span = destination - origin;
	float t = clamp(dot(p - origin, span) / dot(span, span), 0.0, 1.0);
	return length(p - origin - span * t);
}

void fragment() {
	vec2 p = world_xz;
	float heat = smoothstep(-8.0, 8.0, p.x + 4.0 * sin(p.y * 0.2));
	float stone = noise(p * .47);
	float grain = noise(p * 15.0);
	vec3 snow = mix(vec3(.19,.25,.33), vec3(.52,.65,.76), smoothstep(.27,.64,stone));
	vec3 ash = mix(vec3(.14,.09,.12), vec3(.36,.20,.17), stone);
	vec2 folded = abs(p);
	float lane = min(abs(p.y), abs(abs(p.y) - 15.0));
	float link = distance_to_route(folded, vec2(40.0, 0.0), vec2(35.0, 15.0));
	float road = 1.0 - smoothstep(2.3, 3.4, min(lane, link));
	float base = 1.0 - smoothstep(9.0, 11.0, length(vec2(abs(p.x)-40.0,p.y)));
	float pavement = max(road,base);
	vec2 tile = fract(vec2(p.x*.63 + floor(p.y*.58)*.5, p.y*.58));
	float grout = smoothstep(.014,.054,min(min(tile.x,1.-tile.x),min(tile.y,1.-tile.y)));
	vec3 cobble = mix(vec3(.37,.45,.53),vec3(.32,.21,.20),heat) * (.60+.4*grout);
	float seam = 1.0 - smoothstep(.010,.039,abs(noise(p*.75)-.49));
	ALBEDO = mix(mix(snow,ash,heat),cobble,pavement) * (.84+.27*grain);
	EMISSION = vec3(1.,.18,.02) * heat * seam * (1.0-pavement) * (.45+.26*sin(TIME*1.7+stone*6.));
	ROUGHNESS = .88;
}
