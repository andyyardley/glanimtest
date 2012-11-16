//
//  TTGLLabel.h
//  translatetest
//
//  Created by Nick Lockwood on 16/11/2012.
//  Copyright (c) 2012 Venalicium Ltd. All rights reserved.
//

#import "TTGLPatchGrid.h"
#import <UIKit/UIKit.h>

@interface TTGLLabel : TTGLPatchGrid

+ (TTGLLabel *)labelWithText:(NSString *)text andFont:(UIFont *)font;

@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, assign) CGSize size;

@end
