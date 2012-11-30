//
//  TTGLTextureFrameBuffer.m
//  translatetest
//
//  Created by Andy on 12/11/2012.
//  Copyright (c) 2012 Venalicium Ltd. All rights reserved.
//

#import "TTGLTextureFrameBuffer.h"

@interface TTGLTextureFrameBuffer ()
{
    GLfloat _width;
    GLfloat _height;
}

@property (assign, nonatomic) GLint oldFrameBuffer;
@property (assign, nonatomic) GLuint frameBuffer;
@property (assign, nonatomic) GLuint renderBuffer;

@end

@implementation TTGLTextureFrameBuffer

- (id)initWithWidth:(GLfloat)width height:(GLfloat)height
{
    
    if (self = [super init]) {
        
        _width = floor(width/2)*2;
        _height = floor(height/2)*2;
        
        [self createNew];
    
    }
    
    return self;
    
}

- (void)fillWithBlock:(void(^)(CGRect frame))executionBlock
{
    [self begin];
    if (executionBlock) executionBlock(CGRectMake(0, 0, _width, _height));
    [self end];
}

- (void)begin
{
    
    glGetIntegerv(GL_FRAMEBUFFER_BINDING, &_oldFrameBuffer);
    glBindTexture(GL_TEXTURE_2D, 0);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    
    glViewport(0, 0, _width, _height);

    glClearColor(0, 0, 0, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    
}

- (void)createNew
{
    
    _texture = [[TTGLTexture alloc] init];
    _texture.size = CGSizeMake(_width, _height);
    
    glGetIntegerv(GL_FRAMEBUFFER_BINDING, &_oldFrameBuffer);
    
    glGenFramebuffers(1, &_frameBuffer);
    glGenRenderbuffers(1, &_renderBuffer);
    glGenTextures(1, &_textureLocation);
    
    _texture.glTexture = _textureLocation;
    
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    glBindTexture(GL_TEXTURE_2D, _texture.glTexture);
    
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR); // Linear Filtering
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR); // Linear Filtering
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, _width, _height, 0, GL_RGB, GL_UNSIGNED_BYTE, NULL);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _texture.glTexture, 0);
    
    //        glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    //        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT, width, height);
    //        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _renderBuffer);
    
    glClearColor(1, 0, 0, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    
    GLuint status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (status != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"ERROR: %x", status);
        exit(0);
    }
    
    glBindTexture(GL_TEXTURE_2D, 0);
    glBindFramebuffer(GL_FRAMEBUFFER, _oldFrameBuffer);
    
}

- (void)end
{
//    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    glBindTexture(GL_TEXTURE_2D, _texture.glTexture);
    glBindFramebuffer(GL_FRAMEBUFFER, _oldFrameBuffer);
    
    GLint _framebufferWidth, _framebufferHeight;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_framebufferWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_framebufferHeight);
    
    glViewport(0, 0, _framebufferWidth, _framebufferHeight);
    
}

@end
