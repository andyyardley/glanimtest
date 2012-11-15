//
//  TTGLTextureFrameBuffer.h
//  translatetest
//
//  Created by Andy on 12/11/2012.
//  Copyright (c) 2012 Venalicium Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTGLTextureFrameBuffer : NSObject

@property (assign, nonatomic) GLuint texture;

- (id)initWithWidth:(GLfloat)width height:(GLfloat)height;
- (void)begin;
- (void)end;

@end
