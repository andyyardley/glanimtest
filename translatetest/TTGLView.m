//
//  TTGLLayer.m
//  translatetest
//
//  Created by Andy on 11/11/2012.
//  Copyright (c) 2012 Venalicium Ltd. All rights reserved.
//

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
#import "TTGLLabel.h"
#import "TTShaderService.h"
#import "TTGLTextureFrameBuffer.h"
#import <GLKit/GLKit.h>

//struct ColorGridImpl {
//    std::vector<TTGLPatchGrid*> list;
//};

@interface TTGLView ()
{
    GLfloat _pos;
    CFTimeInterval _lastTimestamp;
}

@property (assign, nonatomic) GLKMatrix4    viewMatrix;

@property (strong, nonatomic) CADisplayLink *displayLink;

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
    
    self.eaglLayer = (CAEAGLLayer *)self.layer;
    self.contentScaleFactor = [UIScreen mainScreen].scale;

    self.eaglLayer.opaque = NO;
    
    self.eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:self.eaglContext];
    
    [self setupRenderBuffer];
    [self setupFrameBuffer];
    
//    GLfloat size = self.frame.size.height / self.frame.size.width;
//    _projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), size, 0.01f, 1000.0f);
    
    self.projectionMatrix = GLKMatrix4MakeOrtho(-1.0f, 1.0f, -0.0f, 1.0f, 0.01f, 1000.0f);
    self.projectionMatrix = GLKMatrix4Multiply(_projectionMatrix, GLKMatrix4MakeLookAt(0, 0, 10, 0, 0, 0, 0, 1, 0));
    
}

- (void)stop
{
    [self.displayLink invalidate];
}

- (void)start
{

    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLink:)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
}

- (void)update
{
    
}

- (void)dealloc
{
    [self.displayLink invalidate];
}

- (void)setupRenderBuffer
{
    
    GLuint colorRenderBuffer;
    glGenRenderbuffers(1, &colorRenderBuffer);
    self.colorRenderBuffer = colorRenderBuffer;
    glBindRenderbuffer(GL_RENDERBUFFER, self.colorRenderBuffer);
    [self.eaglContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.eaglLayer];
    
}

- (void)setupFrameBuffer
{
    
    GLuint framebuffer;
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, self.colorRenderBuffer);
    
    GLint framebufferWidth, framebufferHeight;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &framebufferWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &framebufferHeight);
    glViewport(0, 0, framebufferWidth, framebufferHeight);
    
    glClearColor(0.0f, 0.0f/255.0f, 0.0f/255.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
}

- (void)displayLink:(CADisplayLink*)displayLink
{
    
    CFTimeInterval step = 1.0f/60.0f;
    
    CFTimeInterval delta = displayLink.timestamp - _lastTimestamp;
    if (!_lastTimestamp) delta = step;
    _lastTimestamp = displayLink.timestamp;
    
    _pos += step * (delta / step);
    
    if (_pos > 5) {
        _pos = 0;
    }
    
    GLint framebufferWidth, framebufferHeight;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &framebufferWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &framebufferHeight);

    glViewport(0, 0, framebufferWidth, framebufferHeight);
    glClearColor(0.0f, 0.0f/255.0f, 0.0f/255.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    [self render:_pos];
    
    [self.eaglContext presentRenderbuffer:GL_RENDERBUFFER];
        
}

- (void)render:(GLfloat)currentFrame
{
    

}

@end
