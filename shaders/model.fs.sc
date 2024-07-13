$input fs_normal, fs_texcoord0

#include <bgfx_shader.sh>

void main()
{
	gl_FragColor = vec4(fs_normal, 1);
}

