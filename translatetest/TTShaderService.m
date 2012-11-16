//
//  TTShaderServer.m
//  translatetest
//
//  Created by Andy on 10/11/2012.
//  Copyright (c) 2012 Venalicium Ltd. All rights reserved.
//

#import "TTShaderService.h"

@interface TTShaderService ()

@property (strong, nonatomic) NSMutableDictionary   *programs;
@property (strong, nonatomic) NSString              *activeProgramKey;
@property (strong, nonatomic) TTShaderProgram       *activeProgram;

@end

static TTShaderService *instance = nil;

@implementation TTShaderService

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
    _programs = [NSMutableDictionary dictionary];
}

- (void)loadShader:(NSString *)fileName forKey:(NSString *)key
{
    TTShaderProgram *shader = [[TTShaderProgram alloc] initWithVertexShaderFile:[NSString stringWithFormat:@"%@Vertex", fileName] fragmentShaderFile:[NSString stringWithFormat:@"%@Fragment", fileName]];
    [self registerShader:shader forKey:key];
}

- (void)registerShader:(TTShaderProgram *)shader forKey:(NSString *)key
{
    [_programs setObject:shader forKey:key];
}

- (TTShaderProgram *)shaderForKey:(NSString *)key
{
    TTShaderProgram *program = [_programs objectForKey:key];
    NSAssert(program != nil, @"Missing Shader Program");
    return program;
}

- (TTShaderProgram *)activateShaderForKey:(NSString *)key
{
    if (key != _activeProgramKey) {
        TTShaderProgram *program = [self shaderForKey:key];
        _activeProgram = program;
        _activeProgramKey = key;
        [program activate];
    }
    return _activeProgram;
}

@end

@interface TTShaderProgram()

@property (nonatomic, assign) GLuint            fragShader;
@property (nonatomic, assign) GLuint            vertShader;
@property (nonatomic, assign) NSMutableArray    *attributes;
@property (nonatomic, assign) NSMutableArray    *uniforms;

@end

@implementation TTShaderProgram

#pragma mark -  OpenGL ES 2 shader compilation

- (id)initWithVertexShaderFile:(NSString *)vertexShaderFile fragmentShaderFile:(NSString *)fragmentShaderFile;
{
  
    if (self = [super init]) {
    
//        return self;
        
        // Create shader program.
        _program = glCreateProgram();

        // Create and compile vertex shader.
        NSString *vertShaderPathname = [[NSBundle mainBundle] pathForResource:vertexShaderFile ofType:@"glsl"];
        if (![self compileShader:&_vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
            NSLog(@"Failed to compile vertex shader");
            return NO;
        }

        // Create and compile fragment shader.
        NSString *fragShaderPathname = [[NSBundle mainBundle] pathForResource:fragmentShaderFile ofType:@"glsl"];
        if (![self compileShader:&_fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
            GLchar messages[256];
            glGetShaderInfoLog(_fragShader, sizeof(messages), 0, &messages[0]);
            NSLog(@"Failed to compile fragment shader\n%@", [NSString stringWithUTF8String:messages]);
            return NO;
        }

        // Attach vertex shader to program.
        glAttachShader(_program, _vertShader);

        // Attach fragment shader to program.
        glAttachShader(_program, _fragShader);
    
        [self link];
        
    }
    
    return self;
    
}
- (GLuint)attributeForName:(NSString *)name
{
    return glGetAttribLocation(_program, [name UTF8String]);
}

- (GLuint)uniformForName:(NSString *)name
{
    return glGetUniformLocation(_program, [name UTF8String]);
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    
    NSString *data = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    
    const GLchar *source = [[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load shader file %@ %@", data, file);
        return NO;
    }
    
    GLuint prog = glCreateShader(type);
    int shaderStringLength = [data length];
    glShaderSource(prog, 1, &source, &shaderStringLength);
    glCompileShader(prog);
    
    [self logProgram:prog step:@"compile"];
    
    GLint status;
    glGetShaderiv(prog, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(prog);
        return NO;
    }
    
    *shader = prog;
    return YES;
}

- (void)activate
{
    
    glUseProgram(_program);
    
}

- (BOOL)link
{
    
    GLint status;
    
    glLinkProgram(_program);
    glValidateProgram(_program);
    
    glGetProgramiv(_program, GL_LINK_STATUS, &status);
    
    if (status == GL_FALSE) return NO;
    
    if (_vertShader) glDeleteShader(_vertShader);
    if (_fragShader) glDeleteShader(_fragShader);
    
    return YES;
    
}

- (BOOL)linkProgram:(GLuint)prog
{
    
    glLinkProgram(prog);
    
    [self logProgram:prog step:@"link"];
    
    GLint status;
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
    
}

- (BOOL)validateProgram:(GLuint)prog
{
    glValidateProgram(prog);
    
    [self logProgram:prog step:@"validate"];
    
    GLint status;
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (void)logProgram:(GLuint)prog step:(NSString*)step
{
//#if defined(DEBUG)
//    GLint logLength;
//    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
//    if (logLength > 0) {
//        GLchar *log = (GLchar *)malloc(logLength);
//        glGetProgramInfoLog(prog, logLength, &logLength, log);
//        NSLog(@"Program %@ log:\n%s", step, log);
//        free(log);
//    }
//#endif
}

@end
