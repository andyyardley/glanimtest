//uniform mat4 modelViewProjectionMatrix;
//
//varying vec2 vCoord0;
//attribute vec2 TexCoord0;
//attribute lowp	vec4 	position;

attribute vec4 Position;
attribute vec4 SourceColor;
uniform mat4 ModelView;
uniform mat4 ProjectionView;

varying vec4 DestinationColor;

attribute vec2 TexCoordIn;
varying vec2 TexCoordOut;

void main (void)
{   
    DestinationColor = SourceColor;
    TexCoordOut = TexCoordIn.xy;
    gl_Position = ProjectionView * ModelView * Position;
}
