//
//  BasicTextureShader.vsh
//  jecTile
//
//  Created by Joel Pryde on 10/18/11.
//  Copyright 2011 Physipop. All rights reserved.
//

uniform vec2 Pt1, Pt2, Pt3, Pt4;
uniform mat4 projection;

attribute vec4 position;  
attribute vec2 texcoord; 

varying lowp vec2 v_texcoord;

void main()
{
    // transform from QC object coords to 0...1
	vec2 p = vec2(position.x, position.y);
    
    // interpolate top edge x coordinate
	vec2 x2 = mix(Pt1, Pt2, p.x);
 
	// interpolate bottom edge x coordinate
	vec2 x1 = mix(Pt3, Pt4, p.x);
 
	// interpolate y position
	p = mix(x1, x2, p.y);
 
	// transform from 0...1 to QC screen coords
	//p = (p  - 0.5) * renderSize;
 
	gl_Position = projection*vec4(p.x,1.0-p.y,position.z,position.w);
	v_texcoord = texcoord;  
}
