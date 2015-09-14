precision highp float;
uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;
uniform sampler2D audioBuffer;
uniform sampler2D backBuffer;

float audio(float val) { return texture2D(audioBuffer, vec2(val, 0)).x; }
vec4 back(vec2 val) { return texture2D(backBuffer, val); }

/* Template */

void main() 
{
    gl_FragColor = draw(gl_FragCoord.xy/resolution);
}