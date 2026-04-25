// wobbly_screen.gdshader
// Post-processing shader applied to a full-screen ColorRect in a high-layer CanvasLayer.
// Samples the screen texture and applies:
//   • Wobbly/wavy edge distortion (hand-drawn aesthetic)
//   • Subtle CRT scanlines
//   • Soft vignette darkening at corners
//   • Minimal chromatic aberration (RGB split)

shader_type canvas_item;

uniform float wobble_strength    : hint_range(0.0, 0.02)  = 0.004;
uniform float wobble_speed       : hint_range(0.0, 10.0)  = 2.0;
uniform float scanline_intensity : hint_range(0.0, 0.5)   = 0.07;
uniform float vignette_strength  : hint_range(0.0, 1.0)   = 0.25;
uniform float chroma_aberration  : hint_range(0.0, 0.01)  = 0.002;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec2 uv = SCREEN_UV;

	// ── Wobbly distortion ───────────────────────────────────────────────────
	uv.x += sin(uv.y * 28.0 + TIME * wobble_speed)       * wobble_strength;
	uv.y += sin(uv.x * 22.0 + TIME * wobble_speed * 0.8) * wobble_strength * 0.55;

	// ── Chromatic aberration (RGB channel split) ────────────────────────────
	float r = texture(screen_texture, uv + vec2( chroma_aberration, 0.0)).r;
	float g = texture(screen_texture, uv).g;
	float b = texture(screen_texture, uv + vec2(-chroma_aberration, 0.0)).b;
	float a = texture(screen_texture, uv).a;
	vec4 color = vec4(r, g, b, a);

	// ── CRT scanlines ───────────────────────────────────────────────────────
	float line  = sin(uv.y * 600.0) * 0.5 + 0.5;
	color.rgb  -= line * scanline_intensity;

	// ── Vignette ─────────────────────────────────────────────────────────────
	vec2  vig_uv  = uv * 2.0 - 1.0;
	float vignette = 1.0 - dot(vig_uv, vig_uv) * vignette_strength;
	color.rgb *= clamp(vignette, 0.0, 1.0);

	COLOR = color;
}
