varying lowp vec4 DestinationColor;
 
varying lowp vec2 TexCoordOut;
uniform sampler2D Texture;

uniform highp vec2 TexSize;          //Size of the source texture

void main(void) {

    highp float darkness = ((1.0 - TexCoordOut.y) * 0.5) + 0.5;

    gl_FragColor =  vec4(0.15 * darkness, 0.15 * darkness, 0.15 * darkness, 1.0) + (texture2D(Texture, TexCoordOut) * vec4(0.33, 0.33, 0.33, 1.0));
    
}
