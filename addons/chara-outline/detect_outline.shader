/*
	アウトライン検出シェーダー by あるる（きのもと 結衣）
	Detect Outline Shader by KINOMOTO Yui @arlez80

	MIT License
*/

shader_type canvas_item;
render_mode unshaded, skip_vertex_transform, blend_disabled;

float check_priority( in vec3 center, in vec3 pixel )
{
	float priority = 0.0;

	if( 0.0 < pixel.b ) {
		// 比較対象が隠しの場合
		if( pixel.g < center.g ) {
			priority = float( 0.0 < center.r );
		}
	}else if( 0.0 < center.b ) {
		// 自分が隠しの場合
		if( center.g < pixel.g ) {
			priority = float( 0.0 < pixel.r );
		}
	}else {
		priority = float( center.r != pixel.r );
	}

	return priority;
}

void fragment( )
{
	/*
		入力：
			R: 物体ID
				ここが違うとアウトラインとして抽出される。なにもない所は0
			G: 深度（DEPTH_TEXTUREと違って手前が1.0）
			B: 線分隠し用オブジェクトか？
	*/

	vec3 color = texture( SCREEN_TEXTURE, SCREEN_UV ).rgb;

	vec2 plus_x_uv = SCREEN_UV + vec2( 1.0, 0.0 ) * SCREEN_PIXEL_SIZE;
	vec2 plus_y_uv = SCREEN_UV + vec2( 0.0, 1.0 ) * SCREEN_PIXEL_SIZE;
	vec3 plus_x = texture( SCREEN_TEXTURE, plus_x_uv ).rgb;
	vec3 plus_y = texture( SCREEN_TEXTURE, plus_y_uv ).rgb;

	vec3 x = - color + plus_x;
	vec3 y = - color + plus_y;
	float line_detect = sqrt( x.r * x.r + y.r * y.r );
	float priority = (
		check_priority( color, plus_x )
	+	check_priority( color, plus_y )
	);

	/*
		出力：
			R: アウトライン検出
			G: なし
			B: なし
	*/
	COLOR = vec4( float( 0.0 < line_detect ) * float( 0.0 < priority ), 0.0, 0.0, 1.0 );
}
