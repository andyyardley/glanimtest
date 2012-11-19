//
//  TTGLColorGrid.h
//  translatetest
//
//  Created by Andy on 11/11/2012.
//  Copyright (c) 2012 Venalicium Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTGLGlobals.h"
#import "TTGLTextureService.h"
#import "TTGLMeshService.h"

@interface TTGLPatchGrid : NSObject

@property (strong, nonatomic) TTGLTexture   *texture;
@property (strong, nonatomic) TTGLMesh      *mesh;

@property (strong, nonatomic) NSString *shaderName;
@property (assign, nonatomic) GLKMatrix4 scale;
@property (assign, nonatomic) GLKMatrix4 position;
@property (assign, nonatomic) GLKMatrix4 rotation;
@property (assign, nonatomic) float         alpha;
@property (assign, nonatomic) GLKVector4 color;

- (id)initWithShaderName:(NSString *)shaderName;

- (void)renderWithProjectionMatrix:(GLKMatrix4)projectionMatrix;

//- (void)setVertices:(Vertex3D *)vertices count:(GLuint)count;
//- (void)setIndices:(GLushort *)indices count:(GLuint)count;
//- (void)setupVBOs;

@end
