//
//  SolidColor.fsh
//  jecTile
//
//  Created by Joel Pryde on 10/18/11.
//  Copyright 2011 Physipop. All rights reserved.
//

precision mediump float;

uniform vec4 color;

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;

void main()
{
    gl_FragColor = color;
}
