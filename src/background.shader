shader_type canvas_item;



uniform vec4 transparent : hint_color;
uniform vec4 inner : hint_color;
uniform vec4 outer : hint_color;

uniform float inner_threshold = 0.03;
uniform float outer_threshold = 0.4;
uniform float soft_edge = 0.9;

uniform vec2 center = vec2(0.5, 0.8);
uniform int OCTAVES = 6;

float rand(vec2 coord){
	return fract(sin(dot(coord, vec2(12.9898, 78.233)))* 43758.5453123);
}

float noise(vec2 coord){
	vec2 i = floor(coord);
	vec2 f = fract(coord);

	// 4 corners of a rectangle surrounding our point
	float a = rand(i);
	float b = rand(i + vec2(1.0, 0.0));
	float c = rand(i + vec2(0.0, 1.0));
	float d = rand(i + vec2(1.0, 1.0));

	vec2 cubic = f * f * (3.0 - 2.0 * f);

	return mix(a, b, cubic.x) + (c - a) * cubic.y * (1.0 - cubic.x) + (d - b) * cubic.x * cubic.y;
}

float fbm(vec2 coord){
	float value = 0.0;
	float scale = 0.5;

	for(int i = 0; i < OCTAVES; i++){
		value += noise(coord) * scale;
		coord *= 2.0;
		scale *= 0.5;
	}
	return value;
}

float overlay(float base, float top) {
	if (base < 0.5) {
		return 2.0 * base * top;
	} else {
		return 1.0 - 2.0 * (1.0 - base) * (1.0 - top);
	}
}


void fragment() {
	vec2 coord = UV * 8.0;
	vec2 fbmcoord = coord / 6.0;

	float noise1 = noise(coord + vec2(TIME * 0.05, TIME * 0.05));
	float noise2 = noise(coord + vec2(TIME * 0.025, TIME * 0.08));
	float combined_noise = (noise1 + noise2) / 2.0;

	float fbm_noise = fbm(fbmcoord + vec2(0.0, TIME * 3.0));
	fbm_noise = overlay(fbm_noise, UV.y);

	float everything_combined = combined_noise;
	if (everything_combined < outer_threshold) {
		COLOR = transparent;
	} else if (everything_combined < outer_threshold + soft_edge) {
		COLOR = mix(transparent, outer, (everything_combined - outer_threshold) / soft_edge);
	} else if (everything_combined < inner_threshold) {
		COLOR = outer;
	} else if (everything_combined < inner_threshold + soft_edge) {
		COLOR = mix(outer, inner, (everything_combined - inner_threshold) / soft_edge);
	} else {
		COLOR = mix(outer, inner, (everything_combined - inner_threshold) / soft_edge);
	}
}