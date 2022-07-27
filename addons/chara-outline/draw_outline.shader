/*
	アウトライン描画シェーダー by あるる（きのもと 結衣）
	Draw Outline Shader by KINOMOTO Yui @arlez80

	MIT License
*/

shader_type canvas_item;
render_mode unshaded, skip_vertex_transform;

uniform sampler2D source_texture : hint_black;
uniform vec4 line_color : hint_color = vec4( 0.0, 0.0, 0.0, 1.0 );

void fragment( )
{
	vec2 uv = vec2( SCREEN_UV.x, 1.0 - SCREEN_UV.y );
	vec3 rgb_center = texture( source_texture, uv ).rgb;
	vec3 rgb_up = texture( source_texture, uv + vec2( 0, -1 ) * SCREEN_PIXEL_SIZE ).rgb;
	vec3 rgb_down = texture( source_texture, uv + vec2( 0, 1 ) * SCREEN_PIXEL_SIZE ).rgb;
	vec3 rgb_left = texture( source_texture, uv + vec2( -1, 0 ) * SCREEN_PIXEL_SIZE ).rgb;
	vec3 rgb_right = texture( source_texture, uv + vec2( 1, 0 ) * SCREEN_PIXEL_SIZE ).rgb;

	float line_width = max(
		rgb_center.r,
		max( max( rgb_up.r, rgb_down.r ), max( rgb_left.r, rgb_right.r ) )
	);
	float luma = rgb_center.r + ( rgb_up.r + rgb_down.r + rgb_left.r + rgb_right.r ) / ( line_width * 3.0 );

	COLOR = vec4(
		line_color.rgb
	,	clamp(
			line_color.a * luma
		,	0.0
		,	1.0
		)
	);
}
