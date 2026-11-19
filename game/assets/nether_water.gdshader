shader_type spatial;
render_mode unshaded;
varying vec2 world_xz;
void vertex() { world_xz = (MODEL_MATRIX * vec4(VERTEX,1.)).xz; }
void fragment() {
	vec2 p = world_xz;
	float ripple = sin(p.y * 3.7 + sin(p.x * 1.5 + TIME) + TIME * 1.7);
	float streak = pow(max(0.,ripple), 14.) * smoothstep(.1,1.,sin(p.x*.64+p.y*.31));
	float swell = .5+.5*sin(p.x*.17+p.y*.22+TIME*.35);
	ALBEDO = mix(vec3(.027,.059,.079),vec3(.063,.14,.16),swell) + streak*vec3(.10,.16,.16);
}
