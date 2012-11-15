uniform ivec2 TexSize;          //Size of the source texture
varying lowp vec2 TexCoordOut;
uniform sampler2D Texture;

varying lowp vec4 DestinationColor;

//uniform sampler2D Texture0;         //Texture used as source
//uniform ivec2 TexSize;          //Size of the source texture
//
//varying lowp vec2 vCoord0;
//varying lowp vec2 vPosition;

const highp float ledsPerPixel = 1.0;
const highp float ledRadius = 0.7;

const lowp vec4 nilColor = vec4(0.0, 0.0, 0.0, 0.0);
const lowp vec4 lightnessColor = vec4(0.45, 0.45, 0.45, 0.7);
const lowp vec4 darknessColor = vec4(0.45, 0.45, 0.45, 0.0);

const highp float ledRadiusSquared = pow(ledRadius, 2.0);

void main()
{

//    gl_FragColor = DestinationColor + texture2D(Texture, TexCoordOut);

    highp vec2 fTexSize = vec2(float(TexSize.x), float(TexSize.y));
    highp vec2 texCoordsStep = 1.0 / (fTexSize * ledsPerPixel);
    highp vec2 texCoordsStepHalf = texCoordsStep / 2.0;

    //Find out how the location of this pixel within a led
    mediump vec2 pixelRegionCoords = fract(TexCoordOut.xy / texCoordsStep);

    //Figure out which color to grab (align to middle of the pixels)    
    mediump vec2 pixelTexCoords = texCoordsStep * floor(TexCoordOut.xy / texCoordsStep) + texCoordsStepHalf;

    //vCoord0 = vec2(1.0 - vCoord0.x, vCoord0.y); flip coordinates to test in rendermonkey

    mediump vec2 powers      = pow(abs(pixelRegionCoords - 0.5), vec2(2.0)) * 1.4;
//    mediump vec2 powersLight = pow(abs(pixelRegionCoords - 0.55), vec2(2.0)) * 1.4;
//    mediump vec2 powersDark  = pow(abs(pixelRegionCoords - 0.45), vec2(2.0)) * 1.5;

    mediump float lerp = smoothstep(0.0, ledRadiusSquared, ledRadiusSquared - (powers.x + powers.y));
    gl_FragColor = mix(nilColor, texture2D(Texture, pixelTexCoords) + vec4(0.1, 0.1, 0.1, 0.0), lerp);

    //lerp = smoothstep(0.0, ledRadiusSquared, ledRadiusSquared - (powersLight.x + powersLight.y));
    //gl_FragColor += mix(nilColor, lightnessColor, lerp);
    //lerp = smoothstep(0.0, ledRadiusSquared, ledRadiusSquared - (powersDark.x + powersDark.y));
    //gl_FragColor -= mix(nilColor, darknessColor, lerp);
    
}