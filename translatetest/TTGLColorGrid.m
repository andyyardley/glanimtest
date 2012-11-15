//
//  TTGLColorGrid.m
//  translatetest
//
//  Created by Andy on 11/11/2012.
//  Copyright (c) 2012 Venalicium Ltd. All rights reserved.
//

#import "TTGLColorGrid.h"
#import "TTShaderService.h"

typedef struct {
    GLfloat position[3];
    GLfloat color[4];
    GLfloat texcoord[2];
} Vertex3D;

const Vertex3D __vertices[] = {
    {{0, 0, 0}, {1, 0, 0, 1}, {0, 1}},
    {{0, 1, 0}, {0, 0, 1, 1}, {0, 0}},
    {{1, 1, 0}, {0, 1, 0, 1}, {1, 0}},
    {{1, 0, 0}, {0, 1, 0, 1}, {1, 1}}
};

const GLushort _indices[] = {
    0, 1, 2,
    2, 3, 0
};

@interface TTGLColorGrid ()
{
    Vertex3D *_vertices;
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

@implementation TTGLColorGrid

- (id)initWithShaderName:(NSString *)shaderName
{
    
    if (self = [super init]) {
        
        _viewMatrix = GLKMatrix4Identity;
        _position   = GLKMatrix4Identity;
        _rotation   = GLKMatrix4Identity;
        _scale      = GLKMatrix4Identity;
        
        _vertices = (Vertex3D*)malloc(sizeof(Vertex3D)*4);
        memcpy(_vertices, __vertices, sizeof(Vertex3D)*4);
        
        _shaderName = shaderName;
        [self setupShader];
        [self setupVBOs];
        
    }
    
    return self;
    
}

- (void)setupVBOs
{
    
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, 4 * sizeof(Vertex3D), _vertices, GL_STATIC_DRAW);
    
    glGenBuffers(1, &_indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(_indices), _indices, GL_STATIC_DRAW);
    
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
    
//    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
//    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    
    _viewMatrix = GLKMatrix4Identity;
    _viewMatrix = GLKMatrix4Multiply(_position, _viewMatrix);
    
    TTShaderProgram *shaderProgram = [[TTShaderService sharedInstance] activateShaderForKey:_shaderName];
    
    glUniformMatrix4fv(_viewUniform, 1, GL_FALSE, _viewMatrix.m);

    glUniformMatrix4fv(_projectionUniform, 1, GL_FALSE, projectionMatrix.m);

    if (_texture) {
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, _texture);
        glUniform1i(_textureUniform, 0);
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR); // Linear Filtering
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR); // Linear Filtering
        glEnable(GL_TEXTURE0);
        
        glUniform2i([shaderProgram uniformForName:@"TexSize"], 80, 80);
    }

    glDrawElements(GL_TRIANGLES, sizeof(_indices)/sizeof(_indices[0]), GL_UNSIGNED_SHORT, 0);

}

- (GLuint)setupTexture:(NSString *)fileName
{
    
    CGImageRef spriteImage = [UIImage imageNamed:fileName].CGImage;
    
    if (!spriteImage) {
        NSLog(@"Failed to load image %@", fileName);
        exit(1);
    }
    
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    
    GLubyte * spriteData = (GLubyte *) calloc(width*height*4, sizeof(GLubyte));
    
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4, CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
    
    CGContextRelease(spriteContext);
    
    GLuint texName;
    glGenTextures(1, &texName);
    glBindTexture(GL_TEXTURE_2D, texName);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_SHORT, spriteData);
    
    free(spriteData);
    return texName;
    
}

@end
