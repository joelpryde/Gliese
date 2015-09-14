//
//  Mapping
//  jecTile
//
//  Created by Joel Pryde on 10/18/11.
//  Copyright 2011 Physipop. All rights reserved.
//

varying lowp vec2 v_texcoord;
uniform sampler2D s_texture;
uniform bool selected;

void main()
{
    gl_FragColor = texture2D(s_texture, vec2(v_texcoord.x,1.0-v_texcoord.y));
    if (selected)
    {
        gl_FragColor += vec4(0,0.2,0.2,0);
    }
}
