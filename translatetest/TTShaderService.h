//
//  TTShaderServer.h
//  translatetest
//
//  Created by Andy on 10/11/2012.
//  Copyright (c) 2012 Venalicium Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TTShaderProgram;

static NSString *kPositionAttribute     = @"Position";
static NSString *kColorAttribute        = @"SourceColor";
static NSString *kViewUniform           = @"ModelView";
static NSString *kProjectionUniform     = @"ProjectionView";
static NSString *kTextureCoordAttribute = @"TexCoordIn";
static NSString *kTextureUniform        = @"Texture";

static NSString *kColorBlendShader      = @"ColorBlendShader";
static NSString *kSimpleTextureShader   = @"SimpleTextureShader";
static NSString *kLedMatrixShader       = @"LedMatrixShader";
static NSString *kSolidBlackShader       = @"SolidBlackShader";

@interface TTShaderService : NSObject

+ (id)sharedInstance;

- (void)registerShader:(TTShaderProgram *)shader forKey:(NSString *)key;
- (TTShaderProgram *)shaderForKey:(NSString *)key;
- (TTShaderProgram *)activateShaderForKey:(NSString *)key;

+ (TTShaderProgram *)createColorBlendShader;
+ (TTShaderProgram *)createSolidBlackShader;
+ (TTShaderProgram *)createSimpleTextureShader;
+ (TTShaderProgram *)createLedMatrixShader;

@end

@interface TTShaderProgram : NSObject

@property (nonatomic, assign) GLuint            program;

- (id)initWithVertexShaderFile:(NSString *)vertexShaderFile fragmentShaderFile:(NSString *)fragmentShaderFile;
- (GLuint)attributeForName:(NSString *)name;
- (GLuint)uniformForName:(NSString *)name;
- (void)activate;
- (NSString *)vertexShaderLog;
- (NSString *)fragmentShaderLog;
- (NSString *)programLog;

@end