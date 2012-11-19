//
//  TTGLGlobals.h
//  translatetest
//
//  Created by Andy on 15/11/2012.
//  Copyright (c) 2012 Venalicium Ltd. All rights reserved.
//

#ifndef translatetest_TTGLGlobals_h
#define translatetest_TTGLGlobals_h

typedef struct {
    GLfloat position[3];
    GLfloat color[4];
    GLfloat texcoord[2];
} Vertex3D;

extern GLKMatrix4 matrixForRectInRect(CGRect rect, CGRect rect2);

#endif