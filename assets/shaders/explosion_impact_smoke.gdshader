/*
	爆破シェーダー for Godot Engine by あるる（きのもと 結衣） @arlez80
	Explode Shader for Godot Engine by Yui Kinomoto @arlez80

	MIT License
*/

shader_type spatial;
render_mode depth_draw_opaque, shadows_disabled, skip_vertex_transform;

uniform vec2 tex_speed = vec2( 0.0, 0.1 );
uniform vec2 shift = vec2( 10.0, 10.0 );

uniform float smoke_power : hint_range( 0.0, 10.0 ) = 1.0;
uniform float smoke_aperture : hint_range( 0.0, 3.0 ) = 0.45;
uniform vec4 smoke_color : source_color = vec4( 0.185, 0.185, 0.185, 1.0 );

void vertex( )
{
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0],INV_VIEW_MATRIX[1],INV_VIEW_MATRIX[2],MODEL_MATRIX[3]);
	VERTEX = ( MODELVIEW_MATRIX * vec4( VERTEX, 1.0 ) ).xyz;
}

float random( vec2 pos )
{ 
	return fract(sin(dot(pos, vec2(12.9898,78.233))) * 43758.5453);
}

float value_noise( vec2 pos )
{
	vec2 p = floor( pos );
	vec2 f = fract( pos );

	float v00 = random( p + vec2( 0.0, 0.0 ) );
	float v10 = random( p + vec2( 1.0, 0.0 ) );
	float v01 = random( p + vec2( 0.0, 1.0 ) );
	float v11 = random( p + vec2( 1.0, 1.0 ) );

	vec2 u = f * f * ( 3.0 - 2.0 * f );

	return mix( mix( v00, v10, u.x ), mix( v01, v11, u.x ), u.y );
}

float noise_tex( vec2 uv )
{
	return (
		value_noise( uv * 0.984864 ) * 0.5
	+	value_noise( uv * 2.543 ) * 0.25
	+	value_noise( uv * 9.543543 ) * 0.125
	+	value_noise( uv * 21.65436 ) * 0.0625
	+	value_noise( uv * 42.0 ) * 0.03125
	+	value_noise( uv * 87.135148 ) * 0.015625
	+	value_noise( uv * 340.66534654 ) * 0.0078125
	);
}

void fragment( )
{
	float p[9];

	for( int y = 0; y < 3; y ++ ) {
		for( int x = 0; x < 3; x ++ ) {
			p[y*3 + x] = noise_tex( UV * 2.0 + tex_speed * TIME + shift * vec2( float(x - 1), float(y - 1) ) );
		}
	}

	float smoke = clamp( ( 1.0 - length( vec2( 0.5, 0.5 ) - UV ) * 2.0 ) * smoke_power, 0.0, 1.0 );
	float smoke_noise = smoke * ( ( ( smoke + smoke_aperture ) * p[4] - smoke_aperture ) * 75.0 );

	ALBEDO = smoke_color.rgb;
	ALPHA = clamp( smoke_noise, 0.0, 1.0 );
	NORMAL = normalize( vec3( ( p[3] - p[5] ) * smoke, 0.1, ( p[1] - p[7] ) * smoke ) - VERTEX * 0.01 );
}
