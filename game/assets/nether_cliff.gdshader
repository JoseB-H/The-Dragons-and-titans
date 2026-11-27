shader_type spatial;
render_mode cull_disabled;
uniform bool turf = false;
varying vec3 wp;
float hash(vec3 p){return fract(sin(dot(p,vec3(127.1,311.7,74.7)))*43758.5453);}
float noise(vec3 p){vec3 i=floor(p);vec3 f=fract(p);f=f*f*(3.0-2.0*f);return mix(mix(mix(hash(i),hash(i+vec3(1,0,0)),f.x),mix(hash(i+vec3(0,1,0)),hash(i+vec3(1,1,0)),f.x),f.y),mix(mix(hash(i+vec3(0,0,1)),hash(i+vec3(1,0,1)),f.x),mix(hash(i+vec3(0,1,1)),hash(i+vec3(1,1,1)),f.x),f.y),f.z);}
void vertex(){wp=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;}
void fragment(){
 float broad=noise(wp*0.32);float grain=noise(wp*7.0);float veins=noise(wp*vec3(1.6,4.0,1.6));
 float crack=pow(1.0-abs(veins*2.0-1.0),18.0);
 vec3 rock=mix(vec3(.105,.13,.13),vec3(.38,.39,.31),broad);
 rock*=.65+grain*.55; rock*=1.0-crack*.3;
 float strata=smoothstep(.42,.48,fract(wp.y*.58+noise(wp*.4)*.25));
 rock*=.85+strata*.15;
 vec3 grass=mix(vec3(.10,.16,.035),vec3(.32,.41,.075),broad)*(.65+grain*.55);
 ALBEDO=turf ? grass : rock;
 ROUGHNESS=.96;
}
