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

@property (strong, nonatomic) NSMutableDictionary   *meshes;
@property (strong, nonatomic) NSString              *activeMeshKey;

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

- (TTGLMesh *)patchWithWidth:(GLuint)width andHeight:(GLuint)height
{
    
    // This is not ideal but will work for now";
    NSString *key = [NSString stringWithFormat:@"%ix%i", width, height];
    
    TTGLMesh *mesh = [_meshes objectForKey:key];
    
    // If this mesh exists return the mesh
    if (mesh != nil) return mesh;
    
    // It doesn't exist so create it
    mesh = [[TTGLMesh alloc] initPatchWithWidth:width andHeight:height];
    mesh.key = key;
    [_meshes setObject:mesh forKey:key];
    
    return mesh;
    
}

- (void)activateMesh:(TTGLMesh *)mesh
{
    
    if (_activeMeshKey == mesh.key) return;
    
//    TTGLMesh *mesh = [_meshes objectForKey:key];
    [mesh activate];
    
    _activeMeshKey = mesh.key;
    
}

@end

@interface TTGLMesh ()
{
    
    GLuint _vertexCount;
    Vertex3D *_vertices;
    GLuint _indexCount;
    GLushort *_indices;
    
}

@property (assign, nonatomic) GLuint vertexBuffer;
@property (assign, nonatomic) GLuint indexBuffer;

@end

@implementation TTGLMesh

const Vertex3D __vertices[] = {
    {{0, 0, 0}, {1, 0, 0, 1}, {0, 0}},
    {{1, 0, 0}, {0, 0, 1, 1}, {1, 0}},
    {{0, 1, 0}, {0, 1, 0, 1}, {0, 1}},
    {{1, 1, 0}, {0, 1, 0, 1}, {1, 1}}
};

const GLushort __indices[] = {
    0, 1, 2,
    1, 3, 2
};

- (id)initPatchWithWidth:(GLuint)width andHeight:(GLuint)height
{
    
    if (self = [super init]) {
        
        _vertexCount = 4;
        _indexCount = 6;
        
        float xStep = 1.0f/width;
        float yStep = 1.0f/height;
        
        width ++;
        height ++;
        
        _vertices = (Vertex3D *)malloc(sizeof(Vertex3D)*4);
        memcpy(_vertices, __vertices, sizeof(Vertex3D)*4);
        
        _indices = (GLushort *)malloc(sizeof(GLushort)*6);
        memcpy(_indices, __indices, sizeof(GLushort)*6);
        
        int nIndex = 0;
        
        _vertices = (Vertex3D *)malloc(width * height * sizeof(Vertex3D));
        _indices = (GLushort *)malloc((width-1) * (height-1) * 6 * sizeof(GLushort));
        _indexCount = (width-1)*(height-1)*6;
        _vertexCount = width*height;
        
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
                _vertices[nIndex].position[0] = x * xStep; // X
                _vertices[nIndex].position[1] = y * yStep; // Y
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
        
        [self setupVBOs];
    
    }
    
    return self;
        
}

//- (void)setVertices:(Vertex3D *)vertices count:(GLuint)count
//{
//    _vertexCount = count;
//    _vertices = (Vertex3D*)malloc(sizeof(Vertex3D)*count);
//    memcpy(_vertices, vertices, sizeof(Vertex3D)*count);
//}
//
//- (void)setIndices:(GLushort *)indices count:(GLuint)count
//{
//    _indexCount = count;
//    _indices = (GLushort *)malloc(sizeof(GLushort)*count);
//    memcpy(_indices, indices, sizeof(GLushort)*count);
//}

- (void)setupVBOs
{
    
    if (!_vertexBuffer) glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, _vertexCount * sizeof(Vertex3D), _vertices, GL_STATIC_DRAW);
    
    if (!_indexBuffer) glGenBuffers(1, &_indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, _indexCount * sizeof(GLushort), _indices, GL_STATIC_DRAW);
    
}

- (void)activate
{
    
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
//    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex3D), 0);
//    glVertexAttribPointer(_colorSlot, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex3D), (GLvoid*) (sizeof(GLfloat) * 3));
//    glVertexAttribPointer(_texCoordSlot, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex3D), (GLvoid*) (sizeof(GLfloat) * 7));
    
}

- (void)render
{
    
    glDrawElements(GL_TRIANGLES, _indexCount, GL_UNSIGNED_SHORT, 0);
    
}

@end
