//
//  TTViewController.m
//  translatetest
//
//  Created by Andy on 09/11/2012.
//  Copyright (c) 2012 Venalicium Ltd. All rights reserved.
//

#import "TTViewController.h"

#define kNumBars 80
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
    _glView.delegate = self;
    
    _fps.textColor = [UIColor whiteColor];
    
    _glView.fps = _fps;
    
    [_glView start];

}

- (NSString *)detailView:(TTGLView *)detailView imageNameForPlayerAtIndex:(NSUInteger)index
{
    if (index == 0) return @"avatar"; else return @"avatar2";
}

- (NSString *)detailView:(TTGLView *)detailView nameForPlayerAtIndex:(NSUInteger)index
{
    return @"Player";
}

- (float)detailView:(TTGLView *)detailView scoreForPlayerAtIndex:(NSUInteger)index
{
    return arc4random()%5000;
}

@end
