shader_type spatial;

render_mode unshaded, cull_disabled;

uniform sampler2D black_hole_texture : source_color;

void fragment()
{
	vec2 uv = UV;
	vec2 center = vec2(0.5);

	// Imaginea originala
	vec4 base = texture(black_hole_texture, uv);

	// Pozitia fata de gaura neagra
	vec2 p = uv - center;

	float x = p.x;
	float y = p.y;

	// =====================================================
	// DISC ORIZONTAL
	// =====================================================

	float disk = 1.0 - smoothstep(
		0.025,
		0.13,
		abs(y)
	);

	// Eliminam zona centrala a gaurii negre
	float center_mask = smoothstep(
		0.07,
		0.16,
		length(p)
	);

	disk *= center_mask;

	// =====================================================
	// FLUX LUMINOS 1
	// =====================================================

	float flow1 = sin(
		x * 45.0
		- TIME * 5.0
		+ sin(x * 12.0) * 2.0
	);

	flow1 = smoothstep(
		0.35,
		0.95,
		flow1
	);

	// =====================================================
	// FLUX LUMINOS 2
	// =====================================================

	float flow2 = sin(
		x * 80.0
		+ TIME * 8.0
		+ y * 35.0
	);

	flow2 = smoothstep(
		0.55,
		0.95,
		flow2
	);

	// =====================================================
	// FLUX CURBAT
	// =====================================================

	float curve =
		sin(
			x * 18.0
			- TIME * 3.0
		) * 0.035;

	float curved_band =
		1.0 - smoothstep(
			0.018,
			0.055,
			abs(y - curve)
		);

	// =====================================================
	// COMBINAM FLUXURILE
	// =====================================================

	float energy =
		flow1 * 0.65 +
		flow2 * 0.35 +
		curved_band * 0.8;

	energy *= disk;

	// =====================================================
	// STRALUCIRE PORTOCALIE
	// =====================================================

	vec3 glow_color = vec3(
		1.0,
		0.25,
		0.02
	);

	vec3 bright_color = vec3(
		1.0,
		0.85,
		0.35
	);

	vec3 energy_color =
		mix(
			glow_color,
			bright_color,
			flow2
		);

	// =====================================================
	// ADAUGAM ENERGIA PESTE IMAGINE
	// =====================================================

	vec3 final_color =
		base.rgb +
		energy_color * energy * 1.8;

	ALBEDO = final_color;

	// Glow puternic
	EMISSION = final_color * 1.4;

	ALPHA = base.a;
}