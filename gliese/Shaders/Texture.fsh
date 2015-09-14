//
//  BasicTextureShader.fsh
//  jecTile
//
//  Created by Joel Pryde on 10/18/11.
//  Copyright 2011 Physipop. All rights reserved.
//

#extension GL_OES_standard_derivatives : enable
precision highp float;

varying lowp vec2 v_texcoord;
uniform lowp vec2 params;
uniform sampler2D s_texture;

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;

void main()
{
    //gl_FragColor = vec4(v_texcoord.x,v_texcoord.y,0,1);
    gl_FragColor = texture2D(s_texture, v_texcoord);
    //vec4(0,1,0,1);//texture2D(s_texture, v_texcoord);
}
