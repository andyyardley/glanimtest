varying lowp vec4 DestinationColor;
 
varying lowp vec2 TexCoordOut;
uniform sampler2D Texture;
uniform mediump float Alpha;

void main(void) {
    mediump vec4 color = texture2D(Texture, TexCoordOut);
    color = vec4(color.r * Alpha, color.g * Alpha, color.b * Alpha, color.a * Alpha);
    gl_FragColor = color;
}
