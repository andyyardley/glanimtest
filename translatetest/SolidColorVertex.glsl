attribute vec4 Position;
attribute vec4 SourceColor;
uniform mat4 ModelView;
uniform mat4 ProjectionView;

void main(void) {
    gl_Position =  ProjectionView * ModelView * Position;
}