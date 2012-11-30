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
#import "TTGLShaderService.h"

#define GRID_COUNT 80
#define PLAYER_COUNT 2
#define TRANSITION_DURATION 2.0f

#define REFLECTION_HEIGHT_RATIO (1.0f/5.0f)
#define MAIN_HEIGHT_RATIO (1.0f - REFLECTION_HEIGHT_RATIO)

@interface TTDuelDetailView ()
{
    NSMutableArray *_grids;
    GLint _framebufferWidth, _framebufferHeight;
    float _start;
    float _end;
    
    float _graphFrame;
    float _textFrame;
    float _avatarFrame;
    float _backgroundFrame;
    
    float *_eq;
    float *_startPos;
    float *_endPos;
    
    BOOL _updating;
    
    CGRect _ledAreaRect;
    CGRect _reflectionAreaRect;
    
    TTGLTexture *_leftAvatarTexture;
    TTGLTexture *_rightAvatarTexture;
    
}

@property (strong, nonatomic) TTGLPatchGrid *solidColorGrid;

@property (strong, nonatomic) TTGLPatchGrid *leftColorGrid;
@property (strong, nonatomic) TTGLPatchGrid *rightColorGrid;

@property (strong, nonatomic) TTGLPatchGrid *ledGrid;
@property (strong, nonatomic) TTGLPatchGrid *textureGrid;
@property (strong, nonatomic) TTGLPatchGrid *reflectionGrid;
@property (strong, nonatomic) TTGLPatchGrid *horizBlurGrid;
@property (strong, nonatomic) TTGLPatchGrid *vertBlurGrid;

@property (strong, nonatomic) TTGLImage     *leftAvatarGrid;
@property (strong, nonatomic) TTGLImage     *rightAvatarGrid;

@property (strong, nonatomic) TTGLLabel     *leftScore;
@property (strong, nonatomic) TTGLLabel     *rightScore;

@property (strong, nonatomic) TTGLTextureFrameBuffer *textureFrameBuffer;
@property (strong, nonatomic) TTGLTextureFrameBuffer *ledFrameBuffer;
@property (strong, nonatomic) TTGLTextureFrameBuffer *reflectionFrameBufferA;
@property (strong, nonatomic) TTGLTextureFrameBuffer *reflectionFrameBufferB;
@property (strong, nonatomic) TTGLTextureFrameBuffer *avatarFrameBuffer;

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
    [[TTGLShaderService sharedInstance] loadShader:@"ColorBlend" forKey:kColorBlendShader];
    [[TTGLShaderService sharedInstance] loadShader:@"ledMatrix" forKey:kLedMatrixShader];
    [[TTGLShaderService sharedInstance] loadShader:@"SolidColor" forKey:kSolidColorShader];
    [[TTGLShaderService sharedInstance] loadShader:@"SimpleTexture" forKey:kSimpleTextureShader];
    [[TTGLShaderService sharedInstance] loadShader:@"HorizBlurTexture" forKey:kHorizBlurTextureShader];
    [[TTGLShaderService sharedInstance] loadShader:@"VertBlurTexture" forKey:kVertBlurTextureShader];
    [[TTGLShaderService sharedInstance] loadShader:@"ReflectionTexture" forKey:kReflectionTextureShader];
    
    _grids = [NSMutableArray array];
    
    for (int i=0; i<GRID_COUNT; i++) {
        _eq[i] = 1.0f;
        [_grids addObject:[[TTGLPatchGrid alloc] initWithShaderName:kSolidColorShader]];
    }
    
    _solidColorGrid = [[TTGLPatchGrid alloc] initWithShaderName:kSolidColorShader];
    _solidColorGrid.color = GLKVector4Make(0.0f, 0.0f, 0.0f, 1.0f);
    
    _ledAreaRect = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height * MAIN_HEIGHT_RATIO);
    _reflectionAreaRect = CGRectMake(0, self.bounds.size.height * MAIN_HEIGHT_RATIO, self.bounds.size.width, self.bounds.size.height * REFLECTION_HEIGHT_RATIO);
    
    _leftColorGrid = [[TTGLPatchGrid alloc] initWithShaderName:kColorBlendShader];
    _leftColorGrid.mesh = [[TTGLMeshService sharedInstance] patchWithWidth:1 andHeight:4];
    _rightColorGrid = [[TTGLPatchGrid alloc] initWithShaderName:kColorBlendShader];
    _rightColorGrid.mesh = [[TTGLMeshService sharedInstance] patchWithWidth:1 andHeight:4];
    
    _ledGrid = [[TTGLPatchGrid alloc] initWithShaderName:kLedMatrixShader];
    _ledGrid.mesh = [[TTGLMeshService sharedInstance] patchWithWidth:320/4 andHeight:280/4];
    
    _textureGrid = [[TTGLPatchGrid alloc] initWithShaderName:kSimpleTextureShader];
    _horizBlurGrid = [[TTGLPatchGrid alloc] initWithShaderName:kHorizBlurTextureShader];
    _vertBlurGrid = [[TTGLPatchGrid alloc] initWithShaderName:kVertBlurTextureShader];
    _reflectionGrid = [[TTGLPatchGrid alloc] initWithShaderName:kReflectionTextureShader];
    
    _leftScore = [TTGLLabel labelWithText:@"TEST" andFont:[UIFont systemFontOfSize:20.0f]];//[UIFont fontWithName:@"ledcountdown" size:32]
    _leftScore.textColor = [UIColor whiteColor];
    
    _rightScore = [TTGLLabel labelWithText:@"TEST" andFont:[UIFont systemFontOfSize:20.0f]];
    _rightScore.textColor = [UIColor whiteColor];
    
    _reflectionFrameBufferA = [[TTGLTextureFrameBuffer alloc] initWithWidth:_reflectionAreaRect.size.width / 1.0 height:_reflectionAreaRect.size.height / 4.0];
    _reflectionFrameBufferB = [[TTGLTextureFrameBuffer alloc] initWithWidth:_reflectionAreaRect.size.width / 1.0 height:_reflectionAreaRect.size.height / 4.0];

    _textureFrameBuffer = [[TTGLTextureFrameBuffer alloc] initWithWidth:self.bounds.size.width / 4 height:_ledAreaRect.size.height / 4];
    _ledFrameBuffer = [[TTGLTextureFrameBuffer alloc] initWithWidth:self.frame.size.width * self.contentScaleFactor height:self.frame.size.height * self.contentScaleFactor];

    _avatarFrameBuffer = [[TTGLTextureFrameBuffer alloc] initWithWidth:60 * self.contentScaleFactor height:70 * self.contentScaleFactor];
    
}

- (void)start
{
    
    _startPos = (float*)malloc(PLAYER_COUNT * sizeof(float));
    _endPos = (float*)malloc(PLAYER_COUNT * sizeof(float));
    
    _playerNames = [NSMutableArray array];
    _playerScores = [NSMutableArray array];
    _playerImageNames = [NSMutableArray array];
    
    float sumScore = 0.0f;
    
    for (int i=0; i < PLAYER_COUNT; i++) {
        float score = [self.delegate detailView:self scoreForPlayerAtIndex:i];
        sumScore += score;
        _startPos[i] = 0.0f;
        [_playerNames addObject:[self.delegate detailView:self nameForPlayerAtIndex:i]];
        [_playerScores addObject:[NSNumber numberWithFloat:score]];
        [_playerImageNames addObject:[self.delegate detailView:self imageNameForPlayerAtIndex:i]];
    }
    
    for (int i=0; i < PLAYER_COUNT; i++) {
        float score = [[_playerScores objectAtIndex:0] floatValue];
        _endPos[i] = score / sumScore;
    }
    
    _leftAvatarGrid = [TTGLImage imageNamed:[_playerImageNames objectAtIndex:0]];
    _rightAvatarGrid = [TTGLImage imageNamed:[_playerImageNames objectAtIndex:1]];
    
    _leftScore.text = [[_playerScores objectAtIndex:0] stringValue];
    _rightScore.text = [[_playerScores objectAtIndex:1] stringValue];
    
    _solidColorGrid.color = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
    
    // Left Avatar
    [_avatarFrameBuffer begin];
    _solidColorGrid.position = GLKMatrix4Identity;
    [_solidColorGrid renderWithProjectionMatrix:self.projectionMatrix];
    _leftAvatarGrid.position = matrixForRectInRect(CGRectMake(2, 2, 56, 56), CGRectMake(0, 0, 60, 70));
    [_leftAvatarGrid renderWithProjectionMatrix:self.projectionMatrix];
    [_avatarFrameBuffer end];
    _leftAvatarTexture = _avatarFrameBuffer.texture;
    
    [_avatarFrameBuffer createNew];
    
    // Right Avatar
    [_avatarFrameBuffer begin];
    _solidColorGrid.position = GLKMatrix4Identity;
    [_solidColorGrid renderWithProjectionMatrix:self.projectionMatrix];
    _rightAvatarGrid.position = matrixForRectInRect(CGRectMake(2, 2, 56, 56), CGRectMake(0, 0, 60, 70));
    [_rightAvatarGrid renderWithProjectionMatrix:self.projectionMatrix];
    [_avatarFrameBuffer end];
    _rightAvatarTexture = _avatarFrameBuffer.texture;
    
    [super start];
    
}

- (void)dealloc
{
    
    free(_eq);
    free(_startPos);
    free(_endPos);
    
}

- (void)setupFrameBuffer
{
    [super setupFrameBuffer];
}

- (CGFloat)easeInOut:(CGFloat)time
{
    return (time < 0.5f)? 0.5f * powf(time * 2.0f, 3.0f): 0.5f * powf(time * 2.0f - 2.0f, 3.0f) + 1.0f;
}

- (void)update
{
    
    if (_graphFrame > TRANSITION_DURATION + 1.0f) {
        
        _graphFrame = 0.0f;
        _textFrame  = TRANSITION_DURATION;
        _backgroundFrame = TRANSITION_DURATION;
        
        for (int i=0; i<PLAYER_COUNT; i++) {
            _startPos[i] = _endPos[i];
        }
        
        _endPos[0] = (float)(arc4random()%100) / 100.0f;
        _endPos[1] = 1.0f - _endPos[0];
        
        _updating = YES;
        
    }
    
}

- (void)render:(GLfloat)delta
{
    
    _graphFrame         += delta;
    _avatarFrame        += delta;
    _textFrame          += delta;

    float _backgroundPos;
    
    if (_updating) {
        if (_graphFrame < TRANSITION_DURATION/2) {
            _backgroundFrame -= delta * 2.0;
            _textFrame       -= delta * 2.0;
        } else {
            _backgroundFrame += delta * 2.0;
            _textFrame       += delta * 2.0;
        }
    } else {
        _backgroundFrame += delta;
    }
    
    _backgroundPos = [self easeInOut:MAX(0.0f, MIN(1.0f, (_backgroundFrame) / TRANSITION_DURATION))];
    
    float _avatarPos = [self easeInOut:MAX(0.0f, MIN(1.0f, (_avatarFrame - 1.0f) / 2.0f))];
    float _textPos = [self easeInOut:MAX(0.0f, MIN(1.0f, (_textFrame - 1.0f) / 2.0f))];

    [_textureFrameBuffer begin];
    
    _leftColorGrid.position = matrixForRectInRect(CGRectMake(0, -_ledAreaRect.size.height - ((_ledAreaRect.size.height * 2.0f) * _backgroundPos), 160, _ledAreaRect.size.height * (3 + (1.0f * _backgroundPos))), _ledAreaRect);
    [_leftColorGrid renderWithProjectionMatrix:self.projectionMatrix];
    _rightColorGrid.position = matrixForRectInRect(CGRectMake(160, -_ledAreaRect.size.height * (1.0f - _backgroundPos), 160, _ledAreaRect.size.height * (3 + (1.0f * _backgroundPos))), _ledAreaRect);
    [_rightColorGrid renderWithProjectionMatrix:self.projectionMatrix];
    
    int player = 0;
    
    _solidColorGrid.color = GLKVector4Make(0.1f, 0.1f, 0.1f, 1.0f);
    
    for (int i=0; i<GRID_COUNT; i++) {
        
//        TTGLPatchGrid *grid = [_grids objectAtIndex:i];
        
        CGFloat x = 0;
        
        if (i<(GRID_COUNT/2)) {
            x = ((float)i/GRID_COUNT) * 2;
        } else {
            x = (((float)i/GRID_COUNT) * 2) - 1.0;
            player = 1;
        }
        
        float pixelsize = 4.0f/280.0f;
        
        float y = [self amplitudeForOffset:x start:_startPos[player] end:_endPos[player] timeshift:_graphFrame];
        
        y *= 0.8;
        y += 0.2;
        
        float diff = MIN(1.0f, MAX(0.0f, y-_endPos[player]));
        
        _eq[i] = MIN(_eq[i], y);
    
        y = MAX(0.0f, y);
    
        _eq[i] += (y - _eq[i]) * 0.1f;
    
        diff = y - _eq[i];

        TTGLPatchGrid *grid = _solidColorGrid;
        
        grid.position = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(((1.0f / GRID_COUNT) * i * 2)/2.0f, 1.0f - _eq[i], 0), GLKMatrix4MakeScale((1.0f / GRID_COUNT) * 1.0f, _eq[i], 1.0f));
        [grid renderWithProjectionMatrix:self.projectionMatrix];
        grid.position = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(((1.0f / GRID_COUNT) * i * 2)/2.0f, 1.0f - _eq[i] - diff - pixelsize, 0), GLKMatrix4MakeScale((1.0f / GRID_COUNT) * 1.0f, diff, 1.0f));
        [grid renderWithProjectionMatrix:self.projectionMatrix];

    }
    
    _leftScore.alpha = _textPos;
    _leftScore.position = matrixForRectInRect(CGRectMake((160-_leftScore.size.width)/2, 0, _leftScore.size.width, _leftScore.size.height), _ledAreaRect);
    [_leftScore renderWithProjectionMatrix:self.projectionMatrix];
    
    _rightScore.alpha = _textPos;
    _rightScore.position = matrixForRectInRect(CGRectMake(((160-_rightScore.size.width)/2 + 160), 0, _rightScore.size.width, _rightScore.size.height), _ledAreaRect);
    [_rightScore renderWithProjectionMatrix:self.projectionMatrix];
    
    [_textureFrameBuffer end];
    
    TTGLTexture *texture = _textureFrameBuffer.texture;

    
//    [_ledFrameBuffer begin];
//    
    _ledGrid.texture = texture;
    _ledGrid.position = matrixForRectInRect(_ledAreaRect, self.bounds);
//    _ledGrid.position = GLKMatrix4MakeScale(1.0f/(self.bounds.size.width/4), 1.0f/(self.bounds.size.height/4), 0);
//    _ledGrid.position = GLKMatrix4Multiply(GLKMatrix4MakeScale(1.0f, 1.0f, 1.0f), _ledGrid.position);
//    _ledGrid.position = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(0.0f, 0.0f, 0), _ledGrid.position);
    [_ledGrid renderWithProjectionMatrix:self.projectionMatrix];
//
   //
//    [_ledFrameBuffer end];
//    
//    _textureGrid.texture = _textureFrameBuffer.texture;
//    _textureGrid.position = matrixForRectInRect(_ledAreaRect, self.bounds);
//    [_textureGrid renderWithProjectionMatrix:self.projectionMatrix];
    
    
    
    
    
    [_reflectionFrameBufferA begin];
    
    _textureGrid.texture = _textureFrameBuffer.texture;
    _textureGrid.position = GLKMatrix4Identity; //matrixForRectInRect(_reflectionAreaRect, self.bounds);
    [_textureGrid renderWithProjectionMatrix:self.projectionMatrix];
    
    // Left Avatar
    _textureGrid.texture = _leftAvatarTexture;
    _textureGrid.position = matrixForRectInRect(CGRectMake((80-30) - (160 * (1.0f - _avatarPos)), 0, 60, 70), self.bounds);
    [_textureGrid renderWithProjectionMatrix:self.projectionMatrix];
    
    // Right Avatar
    _textureGrid.texture = _rightAvatarTexture;
    _textureGrid.position = matrixForRectInRect(CGRectMake(160 + (80-30) + (160 * (1.0f - _avatarPos)), 0, 60, 70), self.bounds);
    [_textureGrid renderWithProjectionMatrix:self.projectionMatrix];
    [_reflectionFrameBufferA end];
    
    [_reflectionFrameBufferB begin];
    _horizBlurGrid.texture = _reflectionFrameBufferA.texture;
    _horizBlurGrid.position = GLKMatrix4Identity;
    _horizBlurGrid.position = GLKMatrix4Multiply(GLKMatrix4MakeScale(1.0f, -1.0f, 1.0f), _horizBlurGrid.position);
    _horizBlurGrid.position = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(0.0f, 1.0f, 0), _horizBlurGrid.position);
    [_horizBlurGrid renderWithProjectionMatrix:self.projectionMatrix];
    [_reflectionFrameBufferB end];
        
    [_reflectionFrameBufferA begin];
    _vertBlurGrid.texture = _reflectionFrameBufferB.texture;
    _vertBlurGrid.position = GLKMatrix4Identity;
    [_vertBlurGrid renderWithProjectionMatrix:self.projectionMatrix];
    [_reflectionFrameBufferA end];
    
//    for (int i=0; i<1; i++) {
//    
//        [_reflectionFrameBufferB begin];
//        _horizBlurGrid.texture = _reflectionFrameBufferA.texture;
//        _horizBlurGrid.position = GLKMatrix4Identity;
//        [_horizBlurGrid renderWithProjectionMatrix:self.projectionMatrix];
//        [_reflectionFrameBufferB end];
//        
//        [_reflectionFrameBufferA begin];
//        _vertBlurGrid.texture = _reflectionFrameBufferB.texture;
//        _vertBlurGrid.position = GLKMatrix4Identity;
//        [_vertBlurGrid renderWithProjectionMatrix:self.projectionMatrix];
//        [_reflectionFrameBufferA end];
//        
//    }
    
    texture = _reflectionFrameBufferA.texture;
    _reflectionGrid.texture = texture;
    _reflectionGrid.position = matrixForRectInRect(_reflectionAreaRect, self.bounds);
    [_reflectionGrid renderWithProjectionMatrix:self.projectionMatrix];

    // Left Avatar
    _textureGrid.texture = _leftAvatarTexture;
    _textureGrid.position = matrixForRectInRect(CGRectMake((80-30) - (160 * (1.0f - _avatarPos)), self.bounds.size.height - 70 - 35, 60, 70), self.bounds);
    [_textureGrid renderWithProjectionMatrix:self.projectionMatrix];
    
    // Right Avatar
    _textureGrid.texture = _rightAvatarTexture;
    _textureGrid.position = matrixForRectInRect(CGRectMake(160 + (80-30) + (160 * (1.0f - _avatarPos)), self.bounds.size.height - 70 - 35, 60, 70), self.bounds);
    [_textureGrid renderWithProjectionMatrix:self.projectionMatrix];

    
    [super render:delta];
    
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
