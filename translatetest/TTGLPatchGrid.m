//
//  TTGLColorGrid.m
//  translatetest
//
//  Created by Andy on 11/11/2012.
//  Copyright (c) 2012 Venalicium Ltd. All rights reserved.
//

#import "TTGLPatchGrid.h"
#import "TTShaderService.h"

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

@interface TTGLPatchGrid ()
{
    GLuint _vertexCount;
    Vertex3D *_vertices;
    GLuint _indexCount;
    GLushort *_indices;
    GLuint _tex;
}

@property (assign, nonatomic) GLuint vertexBuffer;
@property (assign, nonatomic) GLuint indexBuffer;

@property (assign, nonatomic) GLuint positionSlot;
@property (assign, nonatomic) GLuint colorSlot;
@property (assign, nonatomic) GLuint textureSlot;

@property (assign, nonatomic) GLuint viewUniform;
@property (assign, nonatomic) GLuint projectionUniform;

@property (assign, nonatomic) GLuint texCoordSlot;
@property (assign, nonatomic) GLuint textureUniform;

@property (assign, nonatomic) GLKMatrix4 viewMatrix;

@end

@implementation TTGLPatchGrid

- (id)initWithShaderName:(NSString *)shaderName
{
    
    if (self = [super init]) {
        
        _viewMatrix = GLKMatrix4Identity;
        _position   = GLKMatrix4Identity;
        _rotation   = GLKMatrix4Identity;
        _scale      = GLKMatrix4Identity;
        
        _vertexCount = 4;
        _indexCount = 6;
        
        _vertices = (Vertex3D *)malloc(sizeof(Vertex3D)*4);
        memcpy(_vertices, __vertices, sizeof(Vertex3D)*4);
        
        _indices = (GLushort *)malloc(sizeof(GLushort)*6);
        memcpy(_indices, __indices, sizeof(GLushort)*6);
        
        _shaderName = shaderName;
        [self setupVBOs];
        [self setupShader];

    }
    
    return self;
    
}

- (void)setVertices:(Vertex3D *)vertices count:(GLuint)count
{
    _vertexCount = count;
    _vertices = (Vertex3D*)malloc(sizeof(Vertex3D)*count);
    memcpy(_vertices, vertices, sizeof(Vertex3D)*count);
}

- (void)setIndices:(GLushort *)indices count:(GLuint)count
{
    _indexCount = count;
    _indices = (GLushort *)malloc(sizeof(GLushort)*count);
    memcpy(_indices, indices, sizeof(GLushort)*count);
}

- (void)setupVBOs
{
    
    if (!_vertexBuffer) glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, _vertexCount * sizeof(Vertex3D), _vertices, GL_STATIC_DRAW);
    
    if (!_indexBuffer) glGenBuffers(1, &_indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, _indexCount * sizeof(GLushort), _indices, GL_STATIC_DRAW);
    
}

- (void)setShaderName:(NSString *)shaderName
{
    _shaderName = shaderName;
    [self setupShader];
}

- (void)setupShader
{
    
    TTShaderProgram *shaderProgram = [[TTShaderService sharedInstance] activateShaderForKey:_shaderName];
    
    _viewUniform = [shaderProgram uniformForName:kViewUniform];
    _projectionUniform = [shaderProgram uniformForName:kProjectionUniform];
    _textureUniform = [shaderProgram uniformForName:kTextureUniform];
    
    _positionSlot = [shaderProgram attributeForName:kPositionAttribute];
    _colorSlot = [shaderProgram attributeForName:kColorAttribute];
    _texCoordSlot = [shaderProgram attributeForName:kTextureCoordAttribute];
    
    glEnableVertexAttribArray(_positionSlot);
    glEnableVertexAttribArray(_colorSlot);
    glEnableVertexAttribArray(_texCoordSlot);
    
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex3D), 0);
    glVertexAttribPointer(_colorSlot, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex3D), (GLvoid*) (sizeof(GLfloat) * 3));
    glVertexAttribPointer(_texCoordSlot, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex3D), (GLvoid*) (sizeof(GLfloat) * 7));
    
}

- (void)renderWithProjectionMatrix:(GLKMatrix4)projectionMatrix
{
    
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    
    _viewMatrix = GLKMatrix4Identity;
    _viewMatrix = GLKMatrix4Multiply(_position, _viewMatrix);
    
    TTShaderProgram *shaderProgram = [[TTShaderService sharedInstance] activateShaderForKey:_shaderName];
    
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex3D), 0);
    glVertexAttribPointer(_colorSlot, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex3D), (GLvoid*) (sizeof(GLfloat) * 3));
    glVertexAttribPointer(_texCoordSlot, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex3D), (GLvoid*) (sizeof(GLfloat) * 7));
    
    glUniformMatrix4fv(_viewUniform, 1, GL_FALSE, _viewMatrix.m);

    glUniformMatrix4fv(_projectionUniform, 1, GL_FALSE, projectionMatrix.m);

    if (_texture) {
        glEnable(GL_BLEND);
        glBlendFunc(GL_ONE, GL_SRC_COLOR);
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, _texture.glTexture);
        glUniform1i(_textureUniform, 0);
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR); // Linear Filtering
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR); // Linear Filtering
        glEnable(GL_TEXTURE0);
        glUniform2f([shaderProgram uniformForName:@"TexSize"], _texture.size.width, _texture.size.height);
    }
    
    glDrawElements(GL_TRIANGLES, _indexCount, GL_UNSIGNED_SHORT, 0);

}

@end
