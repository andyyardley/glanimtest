//
//  TTGLColorGrid.h
//  translatetest
//
//  Created by Andy on 11/11/2012.
//  Copyright (c) 2012 Venalicium Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTGLColorGrid : NSObject

@property (assign, nonatomic) GLuint texture;
@property (strong, nonatomic) NSString *shaderName;
@property (assign, nonatomic) GLKMatrix4 scale;
@property (assign, nonatomic) GLKMatrix4 position;
@property (assign, nonatomic) GLKMatrix4 rotation;

- (id)initWithShaderName:(NSString *)shaderName;

- (void)renderWithProjectionMatrix:(GLKMatrix4)projectionMatrix;

@end
