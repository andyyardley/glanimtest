#import "TTGLGlobals.h"

GLKMatrix4 matrixForRectInRect(CGRect rect, CGRect rect2)
{
    GLKMatrix4 matrix = GLKMatrix4MakeScale(rect.size.width/rect2.size.width, rect.size.height/rect2.size.height, 1.0f);
    matrix = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(rect.origin.x/rect2.size.width, 1.0f - (rect.origin.y/rect2.size.height) - (rect.size.height/rect2.size.height), 0.0f), matrix);
    return matrix;
}