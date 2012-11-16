//
//  TTGLMeshService.m
//  translatetest
//
//  Created by Andy on 16/11/2012.
//  Copyright (c) 2012 Venalicium Ltd. All rights reserved.
//

#import "TTGLMeshService.h"
#import "TTGLGlobals.h"

static TTGLMeshService *instance = nil;

@interface TTGLMeshService ()

@property (strong, nonatomic) NSMutableDictionary *meshes;

@end

@implementation TTGLMeshService

+ (id)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
        [instance initialize];
    });
    
    return instance;
}

- (void)initialize
{
    _meshes = [NSMutableDictionary dictionary];
}

- (void)createPatchGridWithWidth:(GLuint)width andHeight:(GLuint)height forKey:(NSString *)key
{
    
    int nIndex = 0;
    
    Vertex3D *_vertices = (Vertex3D *)malloc(width * height * sizeof(Vertex3D));
    GLushort *_indices = (GLushort *)malloc((width-1) * (height-1) * 6 * sizeof(GLushort));
    
    float red = 0.0f, green = 0.0f, blue = 0.0f;
    
    for (int y = 0; y < height; y++) {
        
        red = 0.0f, green = 0.0f, blue = 0.0f;
        
        if (y <= 1) {
            red = 1.0f;
        } else if (y >= 3) {
            green = 1.0f;
        } else {
            green = 1.0f;
            red = 1.0f;
        }
        
        for (int x = 0; x < width; x++) {
            _vertices[nIndex].position[0] = x; // X
            _vertices[nIndex].position[1] = y; // Y
            _vertices[nIndex].position[2] = 0; // Z
            _vertices[nIndex].color[0] = red; // Red
            _vertices[nIndex].color[1] = green; // Green
            _vertices[nIndex].color[2] = 0.0f; // Blue
            _vertices[nIndex].color[3] = 1.0f; // Alpha
            _vertices[nIndex].texcoord[0] = (float)x / (width - 1); // U
            _vertices[nIndex].texcoord[1] = (float)y / (height - 1); // V
            nIndex ++;
        }
    }
    
    nIndex = 0;
    
    for (int y = 0; y < height-1; y++) {
        for (int x = 0; x < width-1; x++) {
            
            _indices[nIndex] = (GLushort)(y * width) + x;
            nIndex++;
            _indices[nIndex] = (GLushort)(y * width) + x + 1;
            nIndex++;
            _indices[nIndex] = (GLushort)(y * width) + x + width;
            nIndex++;
            
            //// 2ND FACE
            
            _indices[nIndex] = (GLushort)(y * width) + x + 1;
            nIndex++;
            _indices[nIndex] = (GLushort)(y * width) + x + width + 1;
            nIndex++;
            _indices[nIndex] = (GLushort)(y * width) + x + width;
            nIndex++;
            
        }
    }
    
}

@end

@implementation TTGLMesh


@end
