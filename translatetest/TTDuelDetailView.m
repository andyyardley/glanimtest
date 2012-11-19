//
//  TTDuelDetailView.m
//  translatetest
//
//  Created by Andy on 18/11/2012.
//  Copyright (c) 2012 Venalicium Ltd. All rights reserved.
//

#import "TTDuelDetailView.h"
#import "TTGLPatchGrid.h"
#import "TTGLImage.h"
#import "TTGLLabel.h"
#import "TTGLTextureFrameBuffer.h"
#import "TTShaderService.h"

#define GRID_COUNT 80

@interface TTDuelDetailView ()
{
    NSMutableArray *_grids;
    GLint _framebufferWidth, _framebufferHeight;
    float _start;
    float _end;
    float *_eq;
}

@property (strong, nonatomic) TTGLPatchGrid *leftColorGrid;
@property (strong, nonatomic) TTGLPatchGrid *rightColorGrid;

@property (strong, nonatomic) TTGLPatchGrid *ledGrid;
@property (strong, nonatomic) TTGLPatchGrid *textureGrid;
@property (strong, nonatomic) TTGLPatchGrid *reflectionGrid;

@property (strong, nonatomic) TTGLImage     *leftAvatarGrid;
@property (strong, nonatomic) TTGLImage     *rightAvatarGrid;

@property (strong, nonatomic) TTGLLabel     *leftScore;
@property (strong, nonatomic) TTGLLabel     *rightScore;

@property (strong, nonatomic) TTGLTextureFrameBuffer *textureFrameBuffer;
@property (strong, nonatomic) TTGLTextureFrameBuffer *ledFrameBuffer;
@property (strong, nonatomic) TTGLTextureFrameBuffer *reflectionFrameBuffer;

// Data
@property (strong, nonatomic) NSMutableArray *playerNames;
@property (strong, nonatomic) NSMutableArray *playerScores;
@property (strong, nonatomic) NSMutableArray *playerImageNames;

@end

@implementation TTDuelDetailView

- (void)initialize
{
    
    [super initialize];
 
    _eq = (float*)malloc(GRID_COUNT * sizeof(float));
    
    // Load shaders
    [[TTShaderService sharedInstance] loadShader:@"ColorBlend" forKey:kColorBlendShader];
    [[TTShaderService sharedInstance] loadShader:@"ledMatrix" forKey:kLedMatrixShader];
    [[TTShaderService sharedInstance] loadShader:@"SolidBlack" forKey:kSolidBlackShader];
    [[TTShaderService sharedInstance] loadShader:@"SimpleTexture" forKey:kSimpleTextureShader];
    [[TTShaderService sharedInstance] loadShader:@"BlurTexture" forKey:kBlurTextureShader];
    
    _grids = [NSMutableArray array];
    
    for (int i=0; i<GRID_COUNT; i++) {
        _eq[i] = 1.0f;
        [_grids addObject:[[TTGLPatchGrid alloc] initWithShaderName:kSolidBlackShader]];
    }
    
    _leftColorGrid = [[TTGLPatchGrid alloc] initWithShaderName:kColorBlendShader];
    _leftColorGrid.mesh = [[TTGLMeshService sharedInstance] patchWithWidth:1 andHeight:4];
    _rightColorGrid = [[TTGLPatchGrid alloc] initWithShaderName:kColorBlendShader];
    _rightColorGrid.mesh = [[TTGLMeshService sharedInstance] patchWithWidth:1 andHeight:4];
    
    _ledGrid = [[TTGLPatchGrid alloc] initWithShaderName:kLedMatrixShader];
    _ledGrid.mesh = [[TTGLMeshService sharedInstance] patchWithWidth:320/4 andHeight:280/4];
    
    _textureGrid = [[TTGLPatchGrid alloc] initWithShaderName:kSimpleTextureShader];
    _reflectionGrid = [[TTGLPatchGrid alloc] initWithShaderName:kBlurTextureShader];
    
    _leftScore = [TTGLLabel labelWithText:@"TEST" andFont:[UIFont systemFontOfSize:20.0f]];
    _leftScore.color = [UIColor whiteColor];
    
    _rightScore = [TTGLLabel labelWithText:@"TEST" andFont:[UIFont systemFontOfSize:20.0f]];
    _rightScore.color = [UIColor whiteColor];
    
    _reflectionFrameBuffer = [[TTGLTextureFrameBuffer alloc] initWithWidth:self.frame.size.width / 4 height:(self.frame.size.height * 0.1) / 2];
    _textureFrameBuffer = [[TTGLTextureFrameBuffer alloc] initWithWidth:80 height:70];
    _ledFrameBuffer = [[TTGLTextureFrameBuffer alloc] initWithWidth:self.frame.size.width * self.contentScaleFactor height:self.frame.size.height * self.contentScaleFactor];

}

- (void)start
{

    _playerNames = [NSMutableArray array];
    _playerScores = [NSMutableArray array];
    _playerImageNames = [NSMutableArray array];
    
    for (int i=0; i < 2; i++) {
        [_playerNames addObject:[self.delegate detailView:self nameForPlayerAtIndex:i]];
        [_playerScores addObject:[NSNumber numberWithFloat:[self.delegate detailView:self scoreForPlayerAtIndex:i]]];
        [_playerImageNames addObject:[self.delegate detailView:self imageNameForPlayerAtIndex:i]];
    }
    
    _leftAvatarGrid = [TTGLImage imageNamed:[_playerImageNames objectAtIndex:0]];
    _rightAvatarGrid = [TTGLImage imageNamed:[_playerImageNames objectAtIndex:1]];
    
    _leftScore.text = [[_playerScores objectAtIndex:0] stringValue];
    _rightScore.text = [[_playerScores objectAtIndex:1] stringValue];
    
    [super start];
    
}

- (void)setupFrameBuffer
{
    [super setupFrameBuffer];
}

- (CGFloat)easeInOut:(CGFloat)time
{
    return (time < 0.5f)? 0.5f * powf(time * 2.0f, 3.0f): 0.5f * powf(time * 2.0f - 2.0f, 3.0f) + 1.0f;
}

- (void)render:(GLfloat)currentFrame
{

    float _animPos = [self easeInOut:MAX(0.0f, MIN(1.0f, (currentFrame - 1.0f) / 2.0f))];
    
    [_textureFrameBuffer begin];
    
    _leftColorGrid.position = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(-1.0f, MIN(0, -1.5f + ((MAX(0, currentFrame-1) / 4) * 1.5)), 0.0f), GLKMatrix4MakeScale(1.0f, 1.0f, 1.0f));
    _leftColorGrid.position = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(-1.0f, MIN(0, -0.5f), 0.0f), GLKMatrix4MakeScale(1.0f, 0.5f, 1.0f));
    [_leftColorGrid renderWithProjectionMatrix:self.projectionMatrix];
    _rightColorGrid.position = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(0.0f, MAX(-3.0, -1.5f - ((MAX(0, currentFrame-1) / 4) * 1.5)), 0.0f), GLKMatrix4MakeScale(1.0f, 1.0f, 1.0f));
    _rightColorGrid.position = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(0.0f, MAX(-3.0, -0.5f), 0.0f), GLKMatrix4MakeScale(1.0f, 0.5f, 1.0f));
    [_rightColorGrid renderWithProjectionMatrix:self.projectionMatrix];
    
    float sumScore = [[_playerScores objectAtIndex:0] floatValue] + [[_playerScores objectAtIndex:1] floatValue];
    
    for (int i=0; i<GRID_COUNT; i++) {
        
        TTGLPatchGrid *grid = [_grids objectAtIndex:i];
        
        CGFloat x = 0;
        
        float end = 0.0f;
        
        if (i<(GRID_COUNT/2)) {
            x = ((float)i/GRID_COUNT) * 2;
            end = [[_playerScores objectAtIndex:0] floatValue] / sumScore;
        } else {
            x = (((float)i/GRID_COUNT) * 2) - 1.0;
            end = [[_playerScores objectAtIndex:1] floatValue] / sumScore;
        }
        
//        end = (end * 0.6f) + 0.2f;
        
        float pixelsize = 4.0f/280.0f;
        
        float y = [self amplitudeForOffset:x start:_start end:end timeshift:currentFrame-1.0f];
        
        float diff = MIN(1.0f, MAX(0.0f, y-end));
        
//        for (int n=0; n<2; n++) {
        
//            _eq[i] += 0.04f;
        
            _eq[i] = MIN(_eq[i], y);
        
            y = MAX(0.0f, y);
        
            _eq[i] += (y - _eq[i]) * 0.3f;
        
            diff = y - _eq[i];
        
            float ratio = diff / y;
            
            // 0.5, 0.5
            // 0.2, 0.8
            grid.position = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(((1.0f / GRID_COUNT) * i * 2) - 1.0f, 1.0f - _eq[i], 0), GLKMatrix4MakeScale((1.0f / GRID_COUNT) * 2.0f, _eq[i], 1.0f));
            [grid renderWithProjectionMatrix:self.projectionMatrix];
            grid.position = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(((1.0f / GRID_COUNT) * i * 2) - 1.0f, 1.0f - _eq[i] - diff - pixelsize, 0), GLKMatrix4MakeScale((1.0f / GRID_COUNT) * 2.0f, diff, 1.0f));
//            grid.position = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(((1.0f / GRID_COUNT) * i * 2) - 1.0f, 1.0f - _eq[i], 0), GLKMatrix4MakeScale((1.0f / GRID_COUNT) * 2.0f, pixelsize, 1.0f));
            [grid renderWithProjectionMatrix:self.projectionMatrix];
//        }
        
    }
    
    _rightScore.alpha = _animPos;
    _rightScore.position = GLKMatrix4MakeScale((45.0f/160.0)*2.0f, (24.0f/(280.0f*0.9f))*2.0f, 1.0f);
    _rightScore.position = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(0.0f, 0.5f, 0.0f), _rightScore.position);
    [_rightScore renderWithProjectionMatrix:self.projectionMatrix];
    
    [_textureFrameBuffer end];
    
    [_ledFrameBuffer begin];
    
    TTGLTexture *texture = _textureFrameBuffer.texture;
    
    _ledGrid.texture = texture;
    
    _ledGrid.position = GLKMatrix4MakeScale(1.0f/(320/4), 1.0f/(280/4), 0);
    //    _textureGrid.position = GLKMatrix4Multiply(GLKMatrix4MakeScale(2.0f, 0.9f, 1.0f), _textureGrid.position);
    //    _textureGrid.position = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(-1.0f, 0.1f, 0), _textureGrid.position);
    _ledGrid.position = GLKMatrix4Multiply(GLKMatrix4MakeScale(2.0f, 1.0f, 1.0f), _ledGrid.position);
    _ledGrid.position = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(-1.0f, 0.0f, 0), _ledGrid.position);
    [_ledGrid renderWithProjectionMatrix:self.projectionMatrix];
    
    _leftAvatarGrid.position = GLKMatrix4Identity;
    _leftAvatarGrid.position = GLKMatrix4Multiply(GLKMatrix4MakeScale(0.5f, 0.25f, 1.0f), _leftAvatarGrid.position);
    _leftAvatarGrid.position = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(1.25f - _animPos, 0.05f, 0), _leftAvatarGrid.position);
    [_leftAvatarGrid renderWithProjectionMatrix:self.projectionMatrix];
    
    _rightAvatarGrid.position = GLKMatrix4Identity;
    _rightAvatarGrid.position = GLKMatrix4Multiply(GLKMatrix4MakeScale(0.5f, 0.25f, 1.0f), _rightAvatarGrid.position);
    //    _rightAvatarGrid.position = GLKMatrix4Multiply(GLKMatrix4MakeScale(-1.0f, -1.0f, 1.0f), _rightAvatarGrid.position);
    _rightAvatarGrid.position = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(-1.75f + _animPos, 0.05f, 0), _rightAvatarGrid.position);
    [_rightAvatarGrid renderWithProjectionMatrix:self.projectionMatrix];

    [_ledFrameBuffer end];
    
    texture = _ledFrameBuffer.texture;
    _textureGrid.texture = texture;
    
    [_reflectionFrameBuffer begin];
    _textureGrid.position = GLKMatrix4Identity;
    _textureGrid.position = GLKMatrix4Multiply(GLKMatrix4MakeScale(2.0f, 1.0f, 1.0f), _textureGrid.position);
    _textureGrid.position = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(-1.0f, 0.0f, 0), _textureGrid.position);
    [_textureGrid renderWithProjectionMatrix:self.projectionMatrix];
    [_reflectionFrameBuffer end];
    
    _textureGrid.position = GLKMatrix4Identity;
    _textureGrid.position = GLKMatrix4Multiply(GLKMatrix4MakeScale(2.0f, 0.9f, 1.0f), _textureGrid.position);
    _textureGrid.position = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(-1.0f, 0.1f, 0), _textureGrid.position);
    [_textureGrid renderWithProjectionMatrix:self.projectionMatrix];
    
    texture = _reflectionFrameBuffer.texture;
    _reflectionGrid.texture = texture;
    
    _reflectionGrid.position = GLKMatrix4Identity;
    _reflectionGrid.position = GLKMatrix4Multiply(GLKMatrix4MakeScale(2.0f, -0.1f, 1.0f), _reflectionGrid.position);
    _reflectionGrid.position = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(-1.0f, 0.1f, 0), _reflectionGrid.position);
    [_reflectionGrid renderWithProjectionMatrix:self.projectionMatrix];
    
    _leftScore.alpha = _animPos;
    _leftScore.position = GLKMatrix4MakeScale(45.0f/160.0, 24.0f/(280.0f*0.9f), 1.0f);
    _leftScore.position = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(-1.0f, 0.5f, 0.0f), _leftScore.position);
    [_leftScore renderWithProjectionMatrix:self.projectionMatrix];

    [super render:currentFrame];
    
}

- (CGFloat)amplitudeForOffset:(float)x start:(float)start end:(float)end timeshift:(NSTimeInterval)shift
{
    
    CGFloat y1 = [self start:start end:end time:shift-0.0f x:x];
    CGFloat y2 = [self start:start end:end time:shift-0.0f x:1.0 - x];
    
    CGFloat y = (y1+y2)/2;
    y = 1.0f - y;
    
    CGFloat amplitude = y;
    NSTimeInterval _noisePhase = shift * 5;
    
    float angle = 4.0 * M_PI * (x/2);
    float scale = MAX(0.0f, amplitude - 1.0f * 0.5f);
    amplitude += (sinf(angle * 4) + 1.0f) * (1.5f + scale);
    amplitude += (sinf(angle + _noisePhase * 0.5f) + 1.0f) * (0.5f + scale);
    amplitude += (sinf(angle * 15 + _noisePhase) + 1.0f) * (2.0f + scale);
    
//    amplitude *= (0.1f + (start - y)) * 10.0f;
    
    y += (amplitude / 100);
    
//    y = MAX(0.0f, y);
    
    return y;
    
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

@end
