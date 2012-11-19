//
//  TTGLMeshService.h
//  translatetest
//
//  Created by Andy on 16/11/2012.
//  Copyright (c) 2012 Venalicium Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTGLGlobals.h"

@class TTGLMesh;

@interface TTGLMeshService : NSObject

+ (id)sharedInstance;

- (TTGLMesh *)patchWithWidth:(GLuint)width andHeight:(GLuint)height;
- (void)activateMesh:(TTGLMesh *)mesh;

@end

@interface TTGLMesh : NSObject

@property (strong, nonatomic) NSString *key;

- (id)initPatchWithWidth:(GLuint)width andHeight:(GLuint)height;

- (void)activate;
- (void)render;

@end