/*
	深度を緑へ by あるる（きのもと 結衣）
	Depth to Green by KINOMOTO Yui @arlez80

	MIT License
*/

shader_type spatial;
render_mode unshaded, cull_disabled;

uniform float object_id : hint_range( 0.0, 1.0 ) = 0.0;
uniform float hide : hint_range( 0.0, 1.0 ) = 0.0;

void fragment( )
{
	ALBEDO = vec3( object_id, 1.0 - FRAGCOORD.z, hide );
}
