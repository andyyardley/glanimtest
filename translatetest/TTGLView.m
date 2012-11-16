//
//  TTGLLayer.m
//  translatetest
//
//  Created by Andy on 11/11/2012.
//  Copyright (c) 2012 Venalicium Ltd. All rights reserved.
//

#import "TTGLView.h"
#import "TTGLPatchGrid.h"
#import "TTGLImage.h"
#import "TTShaderService.h"
#import "TTGLTextureFrameBuffer.h"
#import <GLKit/GLKit.h>

#define GRID_COUNT 80

//struct ColorGridImpl {
//    std::vector<TTGLPatchGrid*> list;
//};

@interface TTGLView ()
{
    GLfloat _pos;
    CFTimeInterval _lastTimestamp;
    GLfloat _dir;
    NSMutableArray *_grids;
    GLint _framebufferWidth, _framebufferHeight;
    float _start;
    float _end;
}

@property (strong, nonatomic) CAEAGLLayer   *eaglLayer;
@property (strong, nonatomic) EAGLContext   *eaglContext;

@property (assign, nonatomic) GLKMatrix4    projectionMatrix;
@property (assign, nonatomic) GLKMatrix4    viewMatrix;

@property (strong, nonatomic) TTGLPatchGrid *leftColorGrid;
@property (strong, nonatomic) TTGLPatchGrid *rightColorGrid;

@property (strong, nonatomic) TTGLPatchGrid *ledGrid;
@property (strong, nonatomic) TTGLPatchGrid *textureGrid;
@property (strong, nonatomic) TTGLPatchGrid *reflectionGrid;

@property (strong, nonatomic) TTGLImage     *leftAvatarGrid;
@property (strong, nonatomic) TTGLImage     *rightAvatarGrid;

@property (assign, nonatomic) GLuint        colorRenderBuffer;

@property (strong, nonatomic) TTGLTextureFrameBuffer *textureFrameBuffer;
@property (strong, nonatomic) TTGLTextureFrameBuffer *ledFrameBuffer;
@property (strong, nonatomic) TTGLTextureFrameBuffer *reflectionFrameBuffer;

@property (strong, nonatomic) CADisplayLink *displayLink;

// Data

@property (strong, nonatomic) NSMutableArray *playerNames;
@property (strong, nonatomic) NSMutableArray *playerScores;
@property (strong, nonatomic) NSMutableArray *playerImageNames;

@end

@implementation TTGLView

+ (Class)layerClass
{
	return [CAEAGLLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initialize];
    }
    return self;
}

- (void)awakeFromNib
{
    [self initialize];
}

- (void)initialize
{
    
    _dir = 1.0/60.0f;
    
    _start = 0.0f;
    _end = 0.5;
    
    _eaglLayer = (CAEAGLLayer *)self.layer;
//    _eaglLayer.contentsScale = [UIScreen mainScreen].scale;
    self.contentScaleFactor = [UIScreen mainScreen].scale;
//    self.layer.contentsScale = [UIScreen mainScreen].scale;
    
    _eaglLayer.opaque = NO;
    
    _eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:_eaglContext];
    
    [self setupRenderBuffer];
    [self setupFrameBuffer];
    
//    GLfloat size = self.frame.size.height / self.frame.size.width;
//    _projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), size, 0.01f, 1000.0f);
    
    _projectionMatrix = GLKMatrix4MakeOrtho(-1.0f, 1.0f, -0.0f, 1.0f, 0.01f, 1000.0f);
    
    _projectionMatrix = GLKMatrix4Multiply(_projectionMatrix, GLKMatrix4MakeLookAt(0, 0, 10, 0, 0, 0, 0, 1, 0));
    
    // Create and register shader
    [[TTShaderService sharedInstance] loadShader:@"ColorBlend" forKey:kColorBlendShader];
    [[TTShaderService sharedInstance] loadShader:@"LedMatrix" forKey:kLedMatrixShader];
    [[TTShaderService sharedInstance] loadShader:@"SolidBlack" forKey:kSolidBlackShader];
    [[TTShaderService sharedInstance] loadShader:@"SimpleTexture" forKey:kSimpleTextureShader];
    [[TTShaderService sharedInstance] loadShader:@"BlurTexture" forKey:kBlurTextureShader];
    
    _grids = [NSMutableArray array];
    
    for (int i=0; i<GRID_COUNT; i++) {
        [_grids addObject:[[TTGLPatchGrid alloc] initWithShaderName:kSolidBlackShader]];
    }
    
    _leftColorGrid = [[TTGLPatchGrid alloc] initWithShaderName:kColorBlendShader];
    _rightColorGrid = [[TTGLPatchGrid alloc] initWithShaderName:kColorBlendShader];

    _ledGrid = [[TTGLPatchGrid alloc] initWithShaderName:kLedMatrixShader];
    _textureGrid = [[TTGLPatchGrid alloc] initWithShaderName:kSimpleTextureShader];
    _reflectionGrid = [[TTGLPatchGrid alloc] initWithShaderName:kBlurTextureShader];
    
    [self setupGradientPatchGrid];
    [self setupTexturePatchGrid];
    
    _reflectionFrameBuffer = [[TTGLTextureFrameBuffer alloc] initWithWidth:self.frame.size.width / 4 height:(self.frame.size.height * 0.1) / 2];
    _textureFrameBuffer = [[TTGLTextureFrameBuffer alloc] initWithWidth:80 height:70];
    _ledFrameBuffer = [[TTGLTextureFrameBuffer alloc] initWithWidth:self.frame.size.width * self.contentScaleFactor height:self.frame.size.height * self.contentScaleFactor];
//    _textureFrameBuffer = [[TTGLTextureFrameBuffer alloc] initWithWidth:self.frame.size.width * self.contentScaleFactor height:self.frame.size.height * self.contentScaleFactor];
    
}

- (void)stop
{
    [_displayLink invalidate];
}

- (void)start
{
    
    _playerNames = [NSMutableArray array];
    _playerScores = [NSMutableArray array];
    _playerImageNames = [NSMutableArray array];
    
    for (int i=0; i < 2; i++) {
        [_playerNames addObject:[self.delegate detailView:self nameForPlayerAtIndex:i]];
        [_playerScores addObject:[NSNumber numberWithFloat:[self.delegate detailView:self scoreForPlayerAtIndex:i]]];
        [_playerImageNames addObject:[self.delegate detailView:self imageNameForPlayerAtIndex:i]];
    }
    
    _leftAvatarGrid = [TTGLImage imageNamed:[_playerImageNames objectAtIndex:0]];
    _rightAvatarGrid = [TTGLImage imageNamed:[_playerImageNames objectAtIndex:1]];
    
//    _leftAvatarGrid.texture = [[TTGLTextureService sharedInstance] textureForName:[_playerImageNames objectAtIndex:0]];
//    _rightAvatarGrid.texture = [[TTGLTextureService sharedInstance] textureForName:[_playerImageNames objectAtIndex:1]];
    
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render:)];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
}

- (void)dealloc
{
    [_displayLink invalidate];
}

- (void)setupRenderBuffer
{
    
    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    [_eaglContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
    
}

- (void)setupFrameBuffer
{
    
    GLuint framebuffer;
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer);
    
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_framebufferWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_framebufferHeight);
    
    glViewport(0, 0, _framebufferWidth, _framebufferHeight);
    
}

- (CGFloat)easeInOut:(CGFloat)time
{
    return (time < 0.5f)? 0.5f * powf(time * 2.0f, 3.0f): 0.5f * powf(time * 2.0f - 2.0f, 3.0f) + 1.0f;
}

- (void)render:(CADisplayLink*)displayLink
{
    
    CFTimeInterval delta = displayLink.timestamp - _lastTimestamp;
    if (!_lastTimestamp) delta = _dir;
    _lastTimestamp = displayLink.timestamp;
    
    CGFloat fps = 1.0f / delta;
    _fps.text = [NSString stringWithFormat:@"%0.1f", fps];
    
    _pos += _dir * (delta / (1.0f/60.0f));
    
    float _animPos = [self easeInOut:MAX(0.0f, MIN(1.0f, (_pos - 1.0f) / 2.0f))];
    
    glViewport(0, 0, _framebufferWidth, _framebufferHeight);
    glClearColor(0.0f, 0.0f/255.0f, 0.0f/255.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    if (_pos > 5) {
        _pos = 0;
        _start = _end;
        _end = (float)(arc4random()%100) / 100.0f;
    }
    
    [_textureFrameBuffer begin];
    
    _leftColorGrid.position = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(-1.0f, MIN(0, -1.5f + ((MAX(0, _pos-1) / 4) * 1.5)), 0.0f), GLKMatrix4MakeScale(1.0f, 1.0f, 1.0f));
    [_leftColorGrid renderWithProjectionMatrix:_projectionMatrix];
    _rightColorGrid.position = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(0.0f, MAX(-3.0, -1.5f - ((MAX(0, _pos-1) / 4) * 1.5)), 0.0f), GLKMatrix4MakeScale(1.0f, 1.0f, 1.0f));
    [_rightColorGrid renderWithProjectionMatrix:_projectionMatrix];
    
    for (int i=0; i<GRID_COUNT; i++) {
        
        TTGLPatchGrid *grid = [_grids objectAtIndex:i];
        
        CGFloat x = 0;
        
        if (i<(GRID_COUNT/2)) {
            x = ((float)i/GRID_COUNT) * 2;
        } else {
            x = (((float)i/GRID_COUNT) * 2) - 1.0;
        }
        
        float y = [self amplitudeForOffset:x timeshift:_pos-1.0f];
        
        grid.position = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(((1.0f / GRID_COUNT) * i * 2) - 1.0f, 1.0 - y, 0), GLKMatrix4MakeScale((1.0f / GRID_COUNT) * 2.0f, y, 1.0f));
        [grid renderWithProjectionMatrix:_projectionMatrix];
        
    }
    
    [_textureFrameBuffer end];
    
    
    
    
    [_ledFrameBuffer begin];

    TTGLTexture *texture = _textureFrameBuffer.texture;
    
    _ledGrid.texture = texture;
    
    _ledGrid.position = GLKMatrix4MakeScale(1.0f/(320/4), 1.0f/(280/4), 0);
    //    _textureGrid.position = GLKMatrix4Multiply(GLKMatrix4MakeScale(2.0f, 0.9f, 1.0f), _textureGrid.position);
    //    _textureGrid.position = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(-1.0f, 0.1f, 0), _textureGrid.position);
    _ledGrid.position = GLKMatrix4Multiply(GLKMatrix4MakeScale(2.0f, 1.0f, 1.0f), _ledGrid.position);
    _ledGrid.position = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(-1.0f, 0.0f, 0), _ledGrid.position);
    [_ledGrid renderWithProjectionMatrix:_projectionMatrix];
    
    _leftAvatarGrid.position = GLKMatrix4Identity;
    _leftAvatarGrid.position = GLKMatrix4Multiply(GLKMatrix4MakeScale(-0.5f, -0.25f, 1.0f), _leftAvatarGrid.position);
    _leftAvatarGrid.position = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(1.75f - _animPos, 0.3f, 0), _leftAvatarGrid.position);
    [_leftAvatarGrid renderWithProjectionMatrix:_projectionMatrix];
    
    _rightAvatarGrid.position = GLKMatrix4Identity;
    _rightAvatarGrid.position = GLKMatrix4Multiply(GLKMatrix4MakeScale(-0.5f, -0.25f, 1.0f), _rightAvatarGrid.position);
    //    _rightAvatarGrid.position = GLKMatrix4Multiply(GLKMatrix4MakeScale(-1.0f, -1.0f, 1.0f), _rightAvatarGrid.position);
    _rightAvatarGrid.position = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(-1.25f + _animPos, 0.3f, 0), _rightAvatarGrid.position);
    [_rightAvatarGrid renderWithProjectionMatrix:_projectionMatrix];

    [_ledFrameBuffer end];

    texture = _ledFrameBuffer.texture;
    _textureGrid.texture = texture;
    
    [_reflectionFrameBuffer begin];
    _textureGrid.position = GLKMatrix4Identity;
    _textureGrid.position = GLKMatrix4Multiply(GLKMatrix4MakeScale(2.0f, 1.0f, 1.0f), _textureGrid.position);
    _textureGrid.position = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(-1.0f, 0.0f, 0), _textureGrid.position);
    [_textureGrid renderWithProjectionMatrix:_projectionMatrix];
    [_reflectionFrameBuffer end];
    
    _textureGrid.position = GLKMatrix4Identity;
    _textureGrid.position = GLKMatrix4Multiply(GLKMatrix4MakeScale(2.0f, 0.9f, 1.0f), _textureGrid.position);
    _textureGrid.position = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(-1.0f, 0.1f, 0), _textureGrid.position);
    [_textureGrid renderWithProjectionMatrix:_projectionMatrix];
    
    texture = _reflectionFrameBuffer.texture;
    _reflectionGrid.texture = texture;
    
    _reflectionGrid.position = GLKMatrix4Identity;
    _reflectionGrid.position = GLKMatrix4Multiply(GLKMatrix4MakeScale(2.0f, -0.1f, 1.0f), _reflectionGrid.position);
    _reflectionGrid.position = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(-1.0f, 0.1f, 0), _reflectionGrid.position);
    [_reflectionGrid renderWithProjectionMatrix:_projectionMatrix];
    
    [_eaglContext presentRenderbuffer:GL_RENDERBUFFER];
    
}

- (CGFloat)amplitudeForOffset:(float)x timeshift:(NSTimeInterval)shift
{
    
    CGFloat y1 = [self start:_start end:_end time:shift-0.0f x:x];
    CGFloat y2 = [self start:_start end:_end time:shift-0.0f x:1.0 - x];
    
    CGFloat y = (y1+y2)/2;
    y = 1.0f - y;
    
    CGFloat amplitude = y;
    NSTimeInterval _noisePhase = shift * 5;
    
    float angle = 4.0 * M_PI * (x/2);
    float scale = MAX(0.0f, amplitude - 1.0f * 0.5f);
    amplitude += (sinf(angle * 4) + 1.0f) * (1.5f + scale);
    amplitude += (sinf(angle + _noisePhase * 0.5f) + 1.0f) * (0.5f + scale);
    amplitude += (sinf(angle * 15 + _noisePhase) + 1.0f) * (2.0f + scale);
    
    y += (amplitude / 50);
    
    y = MAX(0.0f, y);
    
    return y;
    
}

- (float)start:(float)start end:(float)end time:(float)time x:(float)x
{
    
    if (time<0) return start;
    
    CGFloat damp = time > 1.0 ? 1.0 : time;
    
    x += time;
    
    x *= 2;
    
    x -= M_PI/4;
    float graph;
    
    graph = (sin(x)/((x*x*x*x)+2));
    
    graph *= 10;
    graph += end;
    graph *= damp;
    
    graph += start * (1.0 - damp);
    
    return graph;
    
}

- (void)setupGradientPatchGrid
{
    
    //    return;
    
    int width = 2;
    int height = 5;
    int nIndex = 0;
    
    Vertex3D *_vertices = (Vertex3D *)malloc(width * height * sizeof(Vertex3D));
    GLushort *_indices = (GLushort *)malloc((width-1) * (height-1) * 6 * sizeof(GLushort));
    
    float red, green, blue;
    
    for (int y = 0; y < height; y++) {
        
        float red = 0.0f, green = 0.0f, blue = 0.0f;
        if (y <= 1) {
            red = 1.0f;
        } else if (y >= 3) {
            green = 1.0f;
        } else {
            green = 1.0f;
            red = 1.0f;
        }
        
        for (int x = 0; x < width; x++) {
            _vertices[nIndex].position[0] = x; // X
            _vertices[nIndex].position[1] = y; // Y
            _vertices[nIndex].position[2] = 0; // Z
            _vertices[nIndex].color[0] = red; // Red
            _vertices[nIndex].color[1] = green; // Green
            _vertices[nIndex].color[2] = 0.0f; // Blue
            _vertices[nIndex].color[3] = 1.0f; // Alpha
            _vertices[nIndex].texcoord[0] = (float)x / (width - 1); // U
            _vertices[nIndex].texcoord[1] = (float)y / (height - 1); // V
            nIndex ++;
        }
    }
    
    nIndex = 0;
    
    for (int y = 0; y < height-1; y++) {
        for (int x = 0; x < width-1; x++) {
            
            _indices[nIndex] = (GLushort)(y * width) + x;
            nIndex++;
            _indices[nIndex] = (GLushort)(y * width) + x + 1;
            nIndex++;
            _indices[nIndex] = (GLushort)(y * width) + x + width;
            nIndex++;
            
            //// 2ND FACE
            
            _indices[nIndex] = (GLushort)(y * width) + x + 1;
            nIndex++;
            _indices[nIndex] = (GLushort)(y * width) + x + width + 1;
            nIndex++;
            _indices[nIndex] = (GLushort)(y * width) + x + width;
            nIndex++;
            
        }
    }
    
    [_leftColorGrid setVertices:_vertices count:width*height];
    [_leftColorGrid setIndices:_indices count:(width-1)*(height-1)*6];
    [_leftColorGrid setupVBOs];
    
    [_rightColorGrid setVertices:_vertices count:width*height];
    [_rightColorGrid setIndices:_indices count:(width-1)*(height-1)*6];
    [_rightColorGrid setupVBOs];
    
}


- (void)setupTexturePatchGrid
{
    
    //    return;
    
    int width = 320/4;
    int height = 280/4;
    int nIndex = 0;
    
    width++;
    height++;
    
    Vertex3D *_vertices = (Vertex3D *)malloc(width * height * sizeof(Vertex3D));
    GLushort *_indices = (GLushort *)malloc((width-1) * (height-1) * 6 * sizeof(GLushort));
    
    float red, green, blue;
    
    for (int y = 0; y < height; y++) {
        
        float red = 0.0f, green = 0.0f, blue = 0.0f;
        if (y <= 1) {
            red = 1.0f;
        } else if (y >= 3) {
            green = 1.0f;
        } else {
            green = 1.0f;
            red = 1.0f;
        }
        
        for (int x = 0; x < width; x++) {
            _vertices[nIndex].position[0] = x; // X
            _vertices[nIndex].position[1] = y; // Y
            _vertices[nIndex].position[2] = 0; // Z
            _vertices[nIndex].color[0] = red; // Red
            _vertices[nIndex].color[1] = green; // Green
            _vertices[nIndex].color[2] = 0.0f; // Blue
            _vertices[nIndex].color[3] = 1.0f; // Alpha
            _vertices[nIndex].texcoord[0] = (float)x / (width - 1); // U
            _vertices[nIndex].texcoord[1] = (float)y / (height - 1); // V
            nIndex ++;
        }
    }
    
    nIndex = 0;
    
    for (int y = 0; y < height-1; y++) {
        for (int x = 0; x < width-1; x++) {
            
            _indices[nIndex] = (GLushort)(y * width) + x;
            nIndex++;
            _indices[nIndex] = (GLushort)(y * width) + x + 1;
            nIndex++;
            _indices[nIndex] = (GLushort)(y * width) + x + width;
            nIndex++;
            
            //// 2ND FACE
            
            _indices[nIndex] = (GLushort)(y * width) + x + 1;
            nIndex++;
            _indices[nIndex] = (GLushort)(y * width) + x + width + 1;
            nIndex++;
            _indices[nIndex] = (GLushort)(y * width) + x + width;
            nIndex++;
            
        }
    }
    
//    [_textureGrid setVertices:_vertices count:width*height];
//    [_textureGrid setIndices:_indices count:(width-1)*(height-1)*6];
//    [_textureGrid setupVBOs];
    
    [_ledGrid setVertices:_vertices count:width*height];
    [_ledGrid setIndices:_indices count:(width-1)*(height-1)*6];
    [_ledGrid setupVBOs];
    
}

@end
