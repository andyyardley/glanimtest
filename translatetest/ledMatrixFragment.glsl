uniform highp vec2 TexSize;          //Size of the source texture
varying lowp vec2 TexCoordOut;
uniform sampler2D Texture;

varying lowp vec4 DestinationColor;

//uniform sampler2D Texture0;         //Texture used as source
//uniform ivec2 TexSize;          //Size of the source texture
//
//varying lowp vec2 vCoord0;
//varying lowp vec2 vPosition;

const lowp float ledsPerPixel = 1.0;
const lowp float ledRadiusSquared = 0.7 * 0.5 * 0.5;

const lowp vec4 nilColor = vec4(0.0, 0.0, 0.0, 0.0);
const lowp vec4 lightnessColor = vec4(0.45, 0.45, 0.45, 0.7);
const lowp vec4 darknessColor = vec4(0.45, 0.45, 0.45, 0.0);

//const highp float ledRadiusSquared = pow(ledRadius, 2.0);

void main()
{

    highp vec2 texCoordsStep = 1.0 / (TexSize * ledsPerPixel);
    highp vec2 texCoordsStepHalf = texCoordsStep / 2.0;

    //Find out how the location of this pixel within a led
    mediump vec2 pixelRegionCoords = fract(TexCoordOut.xy / texCoordsStep);

    //Figure out which color to grab (align to middle of the pixels)    
//    mediump vec2 pixelTexCoords = texCoordsStep * floor(TexCoordOut.xy / texCoordsStep) + texCoordsStepHalf;

    //mediump vec2 powers      = pow(abs(pixelRegionCoords - 0.5), vec2(2.0)) * 1.4;
    //mediump float lerp = smoothstep(0.0, ledRadiusSquared, ledRadiusSquared - (powers.x + powers.y));
    //gl_FragColor = mix(nilColor, texture2D(Texture, pixelTexCoords) + vec4(0.1, 0.1, 0.1, 0.0), lerp);

    lowp vec2 powers = abs(pixelRegionCoords - 0.5);
    lowp float radiusSquared = powers.x * powers.x + powers.y * powers.y;
//    gl_FragColor = (radiusSquared > ledRadiusSquared)? nilColor: texture2D(Texture, pixelTexCoords);
//    gl_FragColor = (radiusSquared > ledRadiusSquared)? nilColor: texture2D(Texture, TexCoordOut);

    highp vec4 color = (step(radiusSquared, ledRadiusSquared) * texture2D(Texture, TexCoordOut));
    
    gl_FragColor = color * ((0.75 - abs(TexCoordOut.x - 0.5)) * (0.75 - abs(TexCoordOut.y - 0.5)) * 3.0);

//    gl_FragColor = texture2D(Texture, TexCoordOut);
}