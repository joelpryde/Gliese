//
//  SolidColor.vsh
//  jecTile
//
//  Created by Joel Pryde on 10/18/11.
//  Copyright 2011 Physipop. All rights reserved.
//

uniform mat4 projection;
attribute vec4 position;

void main()
{
    gl_Position = projection*position;
}
