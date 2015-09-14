//
//  BasicTextureShader.fsh
//  jecTile
//
//  Created by Joel Pryde on 10/18/11.
//  Copyright 2011 Physipop. All rights reserved.
//

#extension GL_OES_standard_derivatives : enable
precision highp float;

uniform lowp vec2 params;

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;

void main( void ) 
{
    vec2 pp = tan(time) * (-1.0 + 2.0 * gl_FragCoord.xy / resolution.xy);
    vec2 p = vec2( sin(pp.x), pp.y*resolution.y/resolution.x);
	
    float sx = sign(p.x)* sin(time);
    float sy = sign(p.y)* sin(time);
    float sd = sign(distance(p, vec2(0.0,0.0)));
	
    float c = mod(p.x * sx  +p.y *sy -time/25.0 *sd, 0.25) >0.05 ? 0.0: 1.0;
    gl_FragColor = vec4(c,c,c,1.0);
}