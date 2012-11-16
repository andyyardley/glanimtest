//
//  TTGLImage.m
//  translatetest
//
//  Created by Andy on 16/11/2012.
//  Copyright (c) 2012 Venalicium Ltd. All rights reserved.
//

#import "TTGLImage.h"
#import "TTShaderService.h"

@implementation TTGLImage

- (id)init
{
    if ((self = [super initWithShaderName:kSimpleTextureShader])) {
        
    }
    return self;
}

+ (TTGLImage *)imageNamed:(NSString *)name
{

    // Create Image
    TTGLImage *image = [[TTGLImage alloc] init];
    
    // Set Texture
    image.texture = [[TTGLTextureService sharedInstance] textureForName:name];
    
    return image;

}

@end