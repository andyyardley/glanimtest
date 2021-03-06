attribute vec4 Position;
attribute vec4 SourceColor;
uniform mat4 ModelView;
uniform mat4 ProjectionView;
 
varying vec4 DestinationColor;
 
attribute vec2 TexCoordIn;
varying vec2 TexCoordOut;
 
void main(void) {
    DestinationColor = SourceColor;
    gl_Position =  ProjectionView * ModelView * Position;
    TexCoordOut = TexCoordIn;
}