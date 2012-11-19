//
//  TTGLLayer.h
//  translatetest
//
//  Created by Andy on 11/11/2012.
//  Copyright (c) 2012 Venalicium Ltd. All rights reserved.
//

//
//  TTGLLayer.h
//  translatetest
//
//  Created by Andy on 11/11/2012.
//  Copyright (c) 2012 Venalicium Ltd. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TTGLGlobals.h"

@class TTGLView;

@protocol DuelDetailViewDelegate

- (NSString *)detailView:(TTGLView *)detailView imageNameForPlayerAtIndex:(NSUInteger)index;
- (NSString *)detailView:(TTGLView *)detailView nameForPlayerAtIndex:(NSUInteger)index;
- (float)detailView:(TTGLView *)detailView scoreForPlayerAtIndex:(NSUInteger)index;

@end

@interface TTGLView : UIView

@property (strong, nonatomic) CAEAGLLayer   *eaglLayer;
@property (strong, nonatomic) EAGLContext   *eaglContext;
@property (assign, nonatomic) GLuint        colorRenderBuffer;

@property (strong, nonatomic) id<DuelDetailViewDelegate> delegate;

@property (assign, nonatomic) GLKMatrix4    projectionMatrix;

- (void)start;
- (void)update;
- (void)stop;

- (void)setupFrameBuffer;
- (void)initialize;
- (void)render:(GLfloat)currentFrame;

@end
