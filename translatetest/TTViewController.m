//
//  TTViewController.m
//  translatetest
//
//  Created by Andy on 09/11/2012.
//  Copyright (c) 2012 Venalicium Ltd. All rights reserved.
//

#import "TTViewController.h"
#import "TTGLView.h"

#define kNumBars 320
#define kBarWidth 320 / kNumBars

@interface TTViewController ()
{
    float pos;
    float dir;
    float bars[kNumBars];
    UIView *views[kNumBars];
    TTGLView *_glView;
    CFTimeInterval _lastTimestamp;
    
    CALayer *_layer;
    
    float _start;
    float _end;
    
}

@property (strong, nonatomic) IBOutlet UILabel *fps;

@end

@implementation TTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{

    _glView = [[TTGLView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 280)];
    [self.view insertSubview:_glView belowSubview:_fps];
    
    _fps.textColor = [UIColor whiteColor];
    
    _glView.fps = _fps;
    
    [_glView startAnimation];
    
    return;

    dir = 0.01;
    pos = 0;
    _start = 0.0f;
    _end = 0.5f;
    
    for (int i=0; i<kNumBars; i++) {
        bars[i] = arc4random()%100;
    }
    
    for (int i=0; i<kNumBars; i++) {
        CGFloat height = sinf((M_PI/kNumBars)*i)*pos;//bars[i]
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(i * kBarWidth, 0, kBarWidth, height)];
        view.backgroundColor = [UIColor redColor];
        views[i] = view;
        [_containerView addSubview:view];
    }
    
//    [self setup];
//
    
    CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render:)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
}

- (void)render:(CADisplayLink*)displayLink
{

    CFTimeInterval delta = displayLink.timestamp - _lastTimestamp;
    _lastTimestamp = displayLink.timestamp;
    
    CGFloat fps = 1.0f / delta;
    
    _fps.text = [NSString stringWithFormat:@"%0.1f", fps];
    
//    if (pos>=10 || pos<0) dir *= -1;
    
    pos += dir;
    
    for (int i=0; i<kNumBars; i++) {
        
//        CGFloat y = [self end:0.5 time:pos x:(float)i];
        CGFloat y = 0;
        
        if (pos > 5) {
            pos = 0;
            _start = _end;
            _end = (float)(arc4random()%100) / 100.0f;
        }
        
        CGFloat y1 = [self start:_start end:_end time:pos-2.0f x:((float)i)/kNumBars];
        CGFloat y2 = [self start:_start end:_end time:pos-2.0f x:1.0 - (((float)i)/kNumBars)];

        y = (y1+y2)/2;
                
//        y = [self end:0.5f time:-4.0 x:((float)i)/kNumBars * 10] + 0.5;
        
//        CGFloat height = sinf((M_PI/kNumBars)*i)*pos;//bars[i]
//        height += sinf(((M_PI/2)*i) + (pos/5))*10;
        
//        y = [self end:0.5f time:pos x:i];
        
        CGFloat height = _containerView.bounds.size.height * y;
        
        views[i].frame = CGRectMake(i * kBarWidth, _containerView.bounds.size.height, kBarWidth, -height);
        
    }
    
}

- (float)start:(float)start endb:(float)end time:(float)time x:(float)x
{
    
    //    if (time<0) return 0;
    
    CGFloat damp = time > 1.0 ? 1.0 : time;
    
    x += time;
    
    if (x<0) x *= -1;
    
    x *= 2;
    
    x += M_PI/2;
    
    x -= M_PI/4;
    float graph;
    
    graph = (sin(x)/((x*x*x)+2));
    
    graph *= 10;
    
    return (graph + end) * damp;
    
}


- (float)start:(float)start end:(float)end time:(float)time x:(float)x
{
    
    if (time<0) return start;
    
    CGFloat damp = time > 1.0 ? 1.0 : time;
    
    x += time;
    
    x *= 2;
    
    x -= M_PI/4;
    float graph;
    
    graph = (sin(x)/((x*x*x*x)+2));
    
    graph *= 10;
    graph += end;
    graph *= damp;
    
    graph += start * (1.0 - damp);
    
    return graph;
    
}


- (float)end:(float)end time:(float)time x:(float)x
{
    
    if (time<0) return 0;
    
    CGFloat damp = time > 1.0 ? 1.0 : time;
    
    x += time;
    
    x *= 2;
    
    x -= M_PI/4;
    float graph;
    
    graph = (sin(x)/((x*x*x)+2));

    graph *= 10;
    
    return (graph + end) * damp;
    
}

- (float)bend:(float)end time:(float)time x:(float)x
{

    
//    float start = sinf((M_PI/kNumBars)*x);

    float middle = 0;//1-sinf((M_PI/kNumBars)*x);
    
    float offset = sinf(M_PI * time);

    float phase1 = 0;
    float phase2 = 0;
    
    if (time>0.5) {
        
        float adjTime = (time-0.5)*2;
        
        phase1 = (sinf( (( (M_PI*2) /kNumBars)*x) - (M_PI/2) )+1) * (1.0 - adjTime);
        
//        phase1 = sinf((M_PI/kNumBars)*x) * (1.0 - adjTime);
//        phase2 = 0;//- sinf((M_PI/kNumBars)*x) * ((time-0.5)*2);
    } else {
        
        float adjTime = time*2;
        
        float offset2 = sinf(M_PI * adjTime);
        
        phase1 = (sinf( (( (M_PI*2) /kNumBars)*x) - (M_PI/2) )+1) * adjTime;
        phase2 = sinf((M_PI/kNumBars)*x) * 0;
        
        phase1 = offset2; //1.0 - ((1.0 - phase1) * (1.0 - offset2));
        
    }
    
    float start = sinf((M_PI/kNumBars)*x) * offset;
    
    
    
//float end = sinf((M_PI/kNumBars)*x)/10;
    
    return MIN(1, MAX(0, phase1 + phase2));
    
}

- (float)egnd:(float)end time:(float)time x:(float)x
{
    
    float timing = 2.0f;
    
    if (time>0.0f) {
        timing = 1.0f;
    } else {
        
    }
    
    time *= timing;

    float startOffset = 1-sinf((M_PI/kNumBars)*x);
    
    float endOffset = sinf((M_PI/kNumBars)*x)/50;
    
    float origEnd = end;
    
    end -= endOffset;
    
    float y = time - startOffset;
    
    float max = 1.0f + startOffset;
    
    y = MIN(max, y);
    
    if (time > max+(max-end)) {
        y = end;
        float off = max+(max-end);
        float offset = origEnd - end;
        float ease = [self easeInOut:time - off];
        ease = MIN(1, ease);
        y += offset * ease;
    } else if (time > max) {
        float offset = (max - end);
        float ease = 1 - [self easeInOut:(time - max) / (max - end)];
        y = end + (offset * ease);
//        y = MAX(end, y);
    } else {
        float ease = [self easeInOut:time/max];
        y *= ease;
    }
    
    return MIN(1, MAX(0, y));
    
}

- (CGFloat)easeInOut:(CGFloat)time
{
    return (time < 0.5f)? 0.5f * powf(time * 2.0f, 3.0f): 0.5f * powf(time * 2.0f - 2.0f, 3.0f) + 1.0f;
}

//- (void)setup
//{
//    
//    _layer = [CALayer layer];
//    _layer.frame = CGRectMake(0, 0, 320, 220);
//    _layer.backgroundColor = [UIColor redColor].CGColor;
//    [self.view.layer addSublayer:_layer];
//    [self.view.layer addSublayer:_containerView.layer];
//    
//    _layer.position = CGPointMake(0.5, 0.5);
//
////    self.view.frame = CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/2, self.view.frame.size.width, self.view.frame.size.height);
//    
//    self.view.layer.position = CGPointMake(self.view.frame.size.width, self.view.frame.size.height);
//    
//    _containerView.layer.position = CGPointMake(0.5, 0.5);
//    
//    GLfloat size = self.view.frame.size.height / self.view.frame.size.width;
////    _projectionMatrix = GLKMatrix4MakeOrtho(-size+0.5, size-0.5, -size/size, size/size, 0.01f, 1000.0f);
//    GLKMatrix4 projectionMatrix = GLKMatrix4MakeFrustum(-size+0.5, size-0.5, -size/size, size/size, 0.01f, 100000.0f);
//    
////    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(0.5f), 1.0f, 0.1f, 1000.0f);
//    CATransform3D layerTransform = [self GLToCA:GLKMatrix4Multiply(projectionMatrix, GLKMatrix4Identity)];
//    _layer.transform = layerTransform;
//    
//    GLKMatrix4 matrix = GLKMatrix4Identity;
////    matrix = GLKMatrix4Multiply(GLKMatrix4MakeRotation(M_PI, 1.0f, 0.0f, 0.0f), matrix);
//    
//    matrix = GLKMatrix4Multiply(projectionMatrix, matrix);
// 
//    
//    CGFloat ScreenScale = [[UIScreen mainScreen] scale];
//    float xscl = self.view.bounds.size.width/ScreenScale/2;
//    float yscl = self.view.bounds.size.height/ScreenScale/2;
//    
//    //The open GL perspective matrix projects onto a 2x2x2 cube.  To get it onto the
//    //device screen it needs to be scaled to the correct size but
//    //maintaining the aspect ratio specified by the open GL window.
//    GLKMatrix4 scalingMatrix = {xscl,0   ,0,0,
//        0,   yscl,0,0,
//        0,   0   ,1,0,
//        0,   0   ,0,1};
//    
//    matrix = GLKMatrix4Multiply(scalingMatrix, matrix);
//    
//    [self OutputMatrix:matrix];
//    
//    CATransform3D transform = CATransform3DIdentity;
////    transform = CATransform3DRotate(transform, M_PI, 1.0f, 0.0f, 0.0f);
//    transform = CATransform3DTranslate(transform, -10, 10, 0);
//    
//    [self OutputTransform:transform];
//    
//}
//
//- (CATransform3D)GLToCA:(GLKMatrix4)matrix
//{
//    
//    CATransform3D transform = CATransform3DIdentity;
//    
//    transform.m11 = matrix.m00;
//    transform.m12 = matrix.m01;
//    transform.m13 = matrix.m02;
//    transform.m14 = matrix.m03;
//    transform.m21 = matrix.m10;
//    transform.m22 = matrix.m11;
//    transform.m23 = matrix.m12;
//    transform.m24 = matrix.m13;
//    transform.m31 = matrix.m20;
//    transform.m32 = matrix.m21;
//    transform.m33 = matrix.m22;
//    transform.m34 = matrix.m23;
//    transform.m41 = matrix.m30;
//    transform.m42 = matrix.m31;
//    transform.m43 = matrix.m32;
//    transform.m44 = matrix.m33;
//    
//    return transform;
//    
//}
//
//- (GLKMatrix4)CAToGL:(CATransform3D)transform
//{
//    
//    GLKMatrix4 matrix = GLKMatrix4Identity;
//    
//    matrix.m00 = transform.m11;
//    matrix.m01 = transform.m12;
//    matrix.m02 = transform.m13;
//    matrix.m03 = transform.m14;
//    matrix.m10 = transform.m21;
//    matrix.m11 = transform.m22;
//    matrix.m12 = transform.m23;
//    matrix.m13 = transform.m24;
//    matrix.m20 = transform.m31;
//    matrix.m21 = transform.m32;
//    matrix.m22 = transform.m33;
//    matrix.m23 = transform.m34;
//    matrix.m30 = transform.m41;
//    matrix.m31 = transform.m42;
//    matrix.m32 = transform.m43;
//    matrix.m33 = transform.m44;
//    
////    transform.m12 = matrix.m01;
////    transform.m13 = matrix.m02;
////    transform.m14 = matrix.m03;
////    transform.m21 = matrix.m10;
////    transform.m22 = matrix.m11;
////    transform.m23 = matrix.m12;
////    transform.m24 = matrix.m13;
////    transform.m31 = matrix.m20;
////    transform.m32 = matrix.m21;
////    transform.m33 = matrix.m22;
////    transform.m34 = matrix.m23;
////    transform.m41 = matrix.m30;
////    transform.m42 = matrix.m31;
////    transform.m43 = matrix.m32;
////    transform.m44 = matrix.m33;
//    
//    return matrix;
//    
//}
//
//- (void)OutputTransform:(CATransform3D)transform
//{
//    
//    NSLog(@"%f %f %f %f\n%f %f %f %f\n%f %f %f %f\n%f %f %f %f\n",
//          transform.m11, transform.m12, transform.m13, transform.m14,
//          transform.m21, transform.m22, transform.m23, transform.m24,
//          transform.m31, transform.m32, transform.m33, transform.m34,
//          transform.m41, transform.m42, transform.m43, transform.m44);
//    
//}
//
//- (void)OutputMatrix:(GLKMatrix4)matrix
//{
//    
//    NSLog(@"%f %f %f %f\n%f %f %f %f\n%f %f %f %f\n%f %f %f %f\n",
//          matrix.m00, matrix.m01, matrix.m02, matrix.m03,
//          matrix.m10, matrix.m11, matrix.m12, matrix.m13,
//          matrix.m20, matrix.m21, matrix.m22, matrix.m23,
//          matrix.m30, matrix.m31, matrix.m32, matrix.m33);
//    
//}
//
//- (void)render:(CADisplayLink*)displayLink
//{
//    
//    if (pos < 100.0f) pos += 0.01f;
//    
//    float width = _containerView.bounds.size.width;
//    float height = _containerView.bounds.size.height;
//    
//    GLKMatrix4 matrix = GLKMatrix4Identity;
//    
//    CATransform3D defaultTransform = CATransform3DIdentity;
//    defaultTransform.m34 = 1/500;
//    
////    GLKMatrix4 projectionMatrix = [self CAToGL:defaultTransform];
//    
//    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(0.5f), 1.0f, 0.1f, 1000.0f);
////    GLKMatrix4 projectionMatrix = GLKMatrix4MakeFrustum(0.5, -0.5, 0.5, -0.5, 0.1f, 1000.0f);
//    
////    matrix = GLKMatrix4Multiply(GLKMatrix4MakeRotation(-pos, 1.0f, 0.0f, 0.0f), GLKMatrix4MakeTranslation(0.0f, -(height/2), 0));
////    matrix = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(0.0f, (height/2), 0), matrix);
////    matrix = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(0.0f, 0, -1030.0f), matrix);
//
//    GLfloat size = self.view.frame.size.height / self.view.frame.size.width;
////    GLKMatrix4 projectionMatrix = GLKMatrix4MakeFrustum(-size+0.5, size-0.5, -size/size, size/size, 0.01f, 100000.0f);
//
//    matrix = GLKMatrix4Multiply(GLKMatrix4MakeRotation(-pos, 1.0f, 0.0f, 0.0f), matrix);
//    
//    matrix = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(0, 0, -1030), matrix);
//    
//    matrix = GLKMatrix4Multiply(projectionMatrix, matrix);
//    
//    CGFloat ScreenScale = [[UIScreen mainScreen] scale];
//    float xscl = self.view.bounds.size.width/ScreenScale/2;
//    float yscl = self.view.bounds.size.height/ScreenScale/2;
//    
//    //The open GL perspective matrix projects onto a 2x2x2 cube.  To get it onto the
//    //device screen it needs to be scaled to the correct size but
//    //maintaining the aspect ratio specified by the open GL window.
//    GLKMatrix4 scalingMatrix = {xscl,0   ,0,0,
//        0,   yscl,0,0,
//        0,   0   ,1,0,
//        0,   0   ,0,1};
//    
////    matrix = GLKMatrix4Multiply(scalingMatrix, matrix);
//    
////    [self OutputMatrix:matrix];
//    
//    CATransform3D transform = [self GLToCA:matrix];
//    
//    GLKMatrix4 layerMatrix = GLKMatrix4Multiply(projectionMatrix, GLKMatrix4MakeTranslation(0.0f, 0.0f, -1030.0f));
////    layerMatrix = GLKMatrix4Multiply(scalingMatrix, layerMatrix);
//    CATransform3D layerTransform = [self GLToCA:layerMatrix];
//
//    [CATransaction begin];
//    [CATransaction setAnimationDuration:0.0f];
//    _containerView.layer.transform = transform;
//    _layer.transform = layerTransform;
//    [CATransaction commit];
//    
//    
//    
//    
//}

@end
