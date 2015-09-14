//
//  BasicTextureShader.vsh
//  jecTile
//
//  Created by Joel Pryde on 10/18/11.
//  Copyright 2011 Physipop. All rights reserved.
//

//uniform mat4 texprojection;
uniform mat4 projection;

attribute vec4 position;  
attribute vec2 texcoord;

varying lowp vec2 v_texcoord;

void main()
{
    gl_Position = projection*position;
    v_texcoord = texcoord;
}
