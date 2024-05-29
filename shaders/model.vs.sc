$input  a_position, a_normal, a_texcoord0
$output fs_normal, fs_texcoord0

#include <bgfx_shader.sh>

void main()
{
	fs_normal    = a_normal;
	fs_texcoord0 = a_texcoord0;

	gl_Position = vec4(a_position, 1.0);
}
