$input fs_normal, fs_texcoord0

#include <bgfx_shader.sh>

SAMPLER2D(diffuse_tex, 0);

void main()
{
	// gl_FragColor = vec4(fs_normal, 1);
	gl_FragColor = texture2D(diffuse_tex, fs_texcoord0);
}

