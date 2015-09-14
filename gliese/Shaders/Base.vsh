uniform mat4 projection;
attribute vec4 position;

void main()
{
    gl_Position = projection*position;
}
