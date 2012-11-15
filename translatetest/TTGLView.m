//
//  TTGLLayer.m
//  translatetest
//
//  Created by Andy on 11/11/2012.
//  Copyright (c) 2012 Venalicium Ltd. All rights reserved.
//

#import "TTGLView.h"
#import "TTGLColorGrid.h"
#import "TTShaderService.h"
#import "TTGLTextureFrameBuffer.h"
#import <vector>

#define GRID_COUNT 80

struct ColorGridImpl {
    std::vector<TTGLColorGrid*> list;
};

@interface TTGLView ()
{
    GLfloat _pos;
    CFTimeInterval _lastTimestamp;
    GLfloat _dir;
    NSMutableArray *_grids;
    GLint _framebufferWidth, _framebufferHeight;
}

@property (strong, nonatomic) CAEAGLLayer   *eaglLayer;
@property (strong, nonatomic) EAGLContext   *eaglContext;

@property (assign, nonatomic) GLKMatrix4    projectionMatrix;
@property (assign, nonatomic) GLKMatrix4    viewMatrix;

@property (strong, nonatomic) TTGLColorGrid *leftColorGrid;
@property (strong, nonatomic) TTGLColorGrid *rightColorGrid;

@property (strong, nonatomic) TTGLColorGrid *textureGrid;

@property (assign, nonatomic) GLuint        colorRenderBuffer;

@property (strong, nonatomic) TTGLTextureFrameBuffer *textureFrameBuffer;

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
        
        _dir = 0.01f;
        
        _eaglLayer = (CAEAGLLayer *)self.layer;
        _eaglLayer.contentsScale = 2.0f;//[UIScreen mainScreen].scale;
        
        self.contentScaleFactor = 2.0f;//[UIScreen mainScreen].scale;
        self.layer.contentsScale = [UIScreen mainScreen].scale;
        
        _eaglLayer.opaque = NO;
        
        _eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        [EAGLContext setCurrentContext:_eaglContext];
        
        [self setupRenderBuffer];
        [self setupFrameBuffer];
        
        GLfloat size = frame.size.height / frame.size.width;
        
        _projectionMatrix = GLKMatrix4MakeOrtho(-1.0f, 1.0f, -0.0f, 1.0f, 0.01f, 1000.0f);
//        _projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), size, 0.01f, 1000.0f);

        _projectionMatrix = GLKMatrix4Multiply(_projectionMatrix, GLKMatrix4MakeLookAt(0, 0, 10, 0, 0, 0, 0, 1, 0));
   
        // Create and register shader
        TTShaderProgram *colorBlendShader  = [TTShaderService createColorBlendShader];
        [[TTShaderService sharedInstance] registerShader:colorBlendShader forKey:kColorBlendShader];
        TTShaderProgram *simpleTextureShader  = [TTShaderService createSimpleTextureShader];
        [[TTShaderService sharedInstance] registerShader:simpleTextureShader forKey:kSimpleTextureShader];
        TTShaderProgram *ledMatrixShader  = [TTShaderService createLedMatrixShader];
        [[TTShaderService sharedInstance] registerShader:ledMatrixShader forKey:kLedMatrixShader];
        TTShaderProgram *solidBlackShader  = [TTShaderService createSolidBlackShader];
        [[TTShaderService sharedInstance] registerShader:solidBlackShader forKey:kSolidBlackShader];
        
        _grids = [NSMutableArray array];
        
        for (int i=0; i<GRID_COUNT; i++) {
            [_grids addObject:[[TTGLColorGrid alloc] initWithShaderName:kSolidBlackShader]];
        }
        
        _leftColorGrid = [[TTGLColorGrid alloc] initWithShaderName:kColorBlendShader];
        _rightColorGrid = [[TTGLColorGrid alloc] initWithShaderName:kColorBlendShader];

        _textureGrid = [[TTGLColorGrid alloc] initWithShaderName:kLedMatrixShader];
//        _textureGrid = [[TTGLColorGrid alloc] initWithShaderName:kSimpleTextureShader];
        
        _textureFrameBuffer = [[TTGLTextureFrameBuffer alloc] initWithWidth:80 height:80];
        
        CADisplayLink *mFrameLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render:)];
//        mFrameLink.frameInterval = 2;
        [mFrameLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        
    }
    return self;
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

- (void)render:(CADisplayLink*)displayLink
{
    
    CFTimeInterval delta = displayLink.timestamp - _lastTimestamp;
    if (!_lastTimestamp) delta = _dir;
    _lastTimestamp = displayLink.timestamp;
    
    CGFloat fps = 1.0f / delta;
    _fps.text = [NSString stringWithFormat:@"%0.1f", fps];

    if (_pos > 5) _dir = -0.01f;
    if (_pos < -0) _dir = 0.01f;
    
    _pos += _dir * (delta / (1.0f/60.0f));
    
    _pos = MAX(-0.01, MIN(5.01, _pos));
    
    [_textureFrameBuffer begin];
    glClearColor(1.0f, 204.0/255.0, 55.0/255.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    _leftColorGrid.position = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(-1.0f, 0.0f, 0.0f), GLKMatrix4MakeScale(1.0f, 1.0f, 1.0f));
    [_leftColorGrid renderWithProjectionMatrix:_projectionMatrix];
    _rightColorGrid.position = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(0.0f, 0.0f, 0.0f), GLKMatrix4MakeScale(1.0f, 1.0f, 1.0f));
    [_rightColorGrid renderWithProjectionMatrix:_projectionMatrix];
    
    for (int i=0; i<GRID_COUNT; i++) {
        
        TTGLColorGrid *grid = [_grids objectAtIndex:i];
        
        CGFloat x = 0;
        
        if (i<(GRID_COUNT/2)) {
            x = (((float)i)/GRID_COUNT) * 2;
        } else {
            x = ((((float)i)/GRID_COUNT) * 2) - 1.0;
        }
        
        CGFloat y1 = [self start:0.0f end:0.5f time:_pos-2.0f x:x];
        CGFloat y2 = [self start:0.0f end:0.5f time:_pos-2.0f x:1.0 - x];
        
        CGFloat y = (y1+y2)/2;
        y = 1.0f - y;
        y = MAX(0.0f, y);
        
        grid.position = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(((1.0f / GRID_COUNT) * i * 2) - 1.0f, 1.0 - y, 0), GLKMatrix4MakeScale((1.0f / GRID_COUNT) * 2.0f, y, 1.0f));
        [grid renderWithProjectionMatrix:_projectionMatrix];
        
    }
    
    [_textureFrameBuffer end];
    
    glViewport(0, 0, _framebufferWidth, _framebufferHeight);
    glClearColor(0.0f, 255.0f/255.0f, 0.0f/255.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
//    glEnable(GL_BLEND);
//    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    
    _textureGrid.texture = _textureFrameBuffer.texture;
    _textureGrid.position = GLKMatrix4MakeScale(2.0f, -1.0f, 2.0f);
    _textureGrid.position = GLKMatrix4Translate(_textureGrid.position, -0.5f, -1.0f, 0);
    [_textureGrid renderWithProjectionMatrix:_projectionMatrix];

    [_eaglContext presentRenderbuffer:GL_RENDERBUFFER];
    
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

@end
