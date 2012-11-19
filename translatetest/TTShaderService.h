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
static NSString *kAlphaUniform          = @"Alpha";
static NSString *kSolidColorUniform     = @"SolidColor";

static NSString *kColorBlendShader          = @"ColorBlendShader";
static NSString *kSimpleTextureShader       = @"SimpleTextureShader";
static NSString *kLedMatrixShader           = @"LedMatrixShader";
static NSString *kSolidColorShader          = @"SolidColorShader";
static NSString *kHorizBlurTextureShader    = @"HorizBlurTextureShader";
static NSString *kVertBlurTextureShader     = @"VertBlurTextureShader";
static NSString *kReflectionTextureShader   = @"ReflectionTextureShader";

@interface TTShaderService : NSObject

+ (id)sharedInstance;

- (void)registerShader:(TTShaderProgram *)shader forKey:(NSString *)key;
- (TTShaderProgram *)shaderForKey:(NSString *)key;
- (TTShaderProgram *)activateShaderForKey:(NSString *)key;

- (void)loadShader:(NSString *)fileName forKey:(NSString *)key;

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