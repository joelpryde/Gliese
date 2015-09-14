precision highp float;
uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;
uniform sampler2D backBuffer;
uniform sampler2D audioBuffer;

float audio(float val) { return texture2D(audioBuffer, vec2(val, 0)).x; }
vec4 back(vec2 val) { return texture2D(audioBuffer, val); }

vec4 draw(vec2 p)
{
    float val = texture2D(audioBuffer, vec2(p.x, 0)).x;
    return vec4(val,0,0,1);
}

void main() 
{
    gl_FragColor = draw(gl_FragCoord.xy/resolution);
}