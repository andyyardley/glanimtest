//
//  TTGLTextureService.m
//  translatetest
//
//  Created by Andy on 15/11/2012.
//  Copyright (c) 2012 Venalicium Ltd. All rights reserved.
//

#import "TTGLTextureService.h"

static TTGLTextureService *instance = nil;

@interface TTGLTextureService ()

@property (strong, nonatomic) NSMutableDictionary *textures;

@end

@implementation TTGLTextureService

+ (id)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
        [instance initialize];
    });
    
    return instance;
}

- (id)init
{
    if (self = [super init]) {
    }
    return self;
}

- (void)initialize
{
    _textures = [NSMutableDictionary dictionary];
}

- (TTGLTexture *)textureForName:(NSString *)fileName
{
    
    TTGLTexture *texture = [_textures objectForKey:fileName];
    if (texture != nil) return texture;
    
    texture = [[TTGLTexture alloc] initWithName:fileName];
    
    [_textures setObject:texture forKey:fileName];

    return texture;
    
}

@end

@implementation TTGLTexture

- (id)initWithName:(NSString *)fileName
{
    
    if (self = [super init]) {

        _fileName = fileName;
        
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
        
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
        
        free(spriteData);
        
        _glTexture = texName;
        _size = CGSizeMake(width, height);
    
    }
    
    return self;
    
}

@end
