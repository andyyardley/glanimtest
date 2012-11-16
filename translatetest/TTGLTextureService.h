//
//  TTGLTextureService.h
//  translatetest
//
//  Created by Andy on 15/11/2012.
//  Copyright (c) 2012 Venalicium Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TTGLTexture;

@interface TTGLTextureService : NSObject

+ (id)sharedInstance;

- (TTGLTexture *)textureForName:(NSString *)fileName;

@end

@interface TTGLTexture : NSObject

@property (assign, nonatomic) GLuint glTexture;
@property (assign, nonatomic) CGSize size;
@property (strong, nonatomic) NSString *fileName;

- (id)initWithName:(NSString *)fileName;

@end