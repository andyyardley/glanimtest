varying lowp vec4 DestinationColor;
 
varying lowp vec2 TexCoordOut;
uniform sampler2D Texture;

void main(void) {

//    lowp vec4 color1 = texture2D(Texture, TexCoordOut+1.0);
//    lowp vec4 color2 = texture2D(Texture, TexCoordOut+1.0);
//    lowp vec4 color3 = texture2D(Texture, TexCoordOut+1.0);
//    lowp vec4 color4 = texture2D(Texture, TexCoordOut+1.0);

    gl_FragColor = texture2D(Texture, TexCoordOut);//(texture2D(Texture, TexCoordOut) * 0.22) + (color1 * 0.11) + (color2 * 0.11) + (color3 * 0.11) + (color4 * 0.11);
}
