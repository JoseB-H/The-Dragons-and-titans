shader_type spatial;
render_mode unshaded;
varying vec2 world_xz;
void vertex() { world_xz = (MODEL_MATRIX * vec4(VERTEX,1.)).xz; }
void fragment() {
	vec2 p = world_xz;
	float ripple = sin(p.y * 7.7 + sin(p.x * 3.5 + TIME) + TIME * 1.7);
	float streak = pow(max(0.,ripple), 28.) * smoothstep(.5,1.,sin(p.x*2.64+p.y*1.31));
	float swell = .5+.5*sin(p.x*.17+p.y*.22+TIME*.35);
	ALBEDO = mix(vec3(.022,.036,.044),vec3(.05,.09,.105),swell) + streak*vec3(.045,.055,.06);
}

