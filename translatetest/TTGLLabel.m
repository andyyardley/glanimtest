//
//  TTGLLabel.m
//  translatetest
//
//  Created by Nick Lockwood on 16/11/2012.
//  Copyright (c) 2012 Venalicium Ltd. All rights reserved.
//

#import "TTGLLabel.h"
#import "TTShaderService.h"
#import "TTGLTextureService.h"

@implementation TTGLLabel

+ (TTGLLabel *)labelWithText:(NSString *)text andFont:(UIFont *)font
{
    // Create label with simple texture shader
    TTGLLabel *label = [[TTGLLabel alloc] initWithShaderName:kSimpleTextureShader];
    label.font = font;
    label.text = text;
    
    return label;
}

- (id)init
{
    if ((self = [super initWithShaderName:kSimpleTextureShader]))
    {
        [self setNeedsUpdate];
    }
    return self;
}

- (void)setNeedsUpdate
{
    self.texture = nil;
}

- (TTGLTexture *)texture
{
    if (super.texture)
    {
        CGSize size = _size;
        if (CGSizeEqualToSize(size, CGSizeZero))
        {
            size = [_text sizeWithFont:_font];
        }
        self.texture = [[TTGLTexture alloc] initWithSize:size drawingBlock:^(CGContextRef context) {
            
            [_color ?: [UIColor blackColor] setFill];
            [_text drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height) withFont:_font];
        }];
    }
    return super.texture;
}

- (void)setText:(NSString *)text
{
    _text = text;
    [self setNeedsUpdate];
}

- (void)setFont:(UIFont *)font
{
    _font = font;
    [self setNeedsUpdate];
}

@end
