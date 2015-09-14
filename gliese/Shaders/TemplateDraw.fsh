vec4 draw(vec2 p)
{
    float val = texture2D(audioBuffer, vec2(p.x, 0)).x;
    return vec4(val,0,0,1);
}