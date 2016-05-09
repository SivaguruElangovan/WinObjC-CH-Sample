//
//  DrawingView.h
//  ComicsHead
//
//  Created by mac4 on 11/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

//#import "PaintControlView.h"

struct Shapes {
    CGPathRef path;
    CGColorRef strokeColor;
    CGColorRef fillColor;
};
typedef struct CGSize CGSize;


@interface DrawingView : UIView{// <PaintControlViewDelegate>
    CGMutablePathRef    path;
    CGPathRef           drawingPath;
    CGRect start;
    BOOL outsideStart;
    NSInteger drawingMode;
    NSMutableArray *pathArray;
    NSMutableArray *redoPathArray;
    CGPoint startPoint;
    int x1,x2,y1,y2;
    UIColor *drawColor;
    UIColor *drawrectColor;
    CGFloat pencillineWidth;
    
    CGFloat strightlineWidth;

    CGRect currentRect;
    
    CGFloat drawX,drawY,drawWidth,drawHeight;
    NSInteger pathArrayCount;
    NSInteger drawFilledorOpenedShape;

    CGFloat eraserlineWidth;    
//    PaintControlView *paintControlView;
    
//    NSMutableArray *drawnImagesArray;
//    NSMutableArray *redoImagesArray;
    
    
    CGPoint currentPoint;
    CGPoint previousPoint1;
    CGPoint previousPoint2;
    CGPoint touchBegin;
    
//    UIImage *curImage;
    BOOL    istouch;
    

        // int                 sliderreset;

//    UIImage     *touchImage;
    int undoCount;
    
    UIImage *offScrImg;
    UIPinchGestureRecognizer *pinchRecognizer;
    
}
@property CGFloat drawX,drawY,drawWidth,drawHeight;
@property(nonatomic,retain) UIColor *drawColor;
@property(nonatomic,retain) UIColor *fillColor;
@property BOOL canDraw;
@property(nonatomic,retain) UIImage *offScrImg;

@property NSInteger drawingMode;
@property(nonatomic,retain) NSMutableArray *pathArray;
@property(nonatomic,retain) NSMutableArray *redoPathArray;


//@property(nonatomic,retain) NSMutableArray *drawnImagesArray;
//@property(nonatomic,retain) NSMutableArray *redoImagesArray;




//@property(nonatomic,retain) PaintControlView *paintControlView;

+(CGRect)getScreenFrameForOrientation;
-(CGRect)trim:(UIImage*)sourceImage;
-(UIColor *)getClr:(NSDictionary *)_dict;

-(void)setShapeSelection;
-(void)renderAllBezierLines;

-(void)setEditor:(id)sender withDrawingView:(id) drawingView;

@end
