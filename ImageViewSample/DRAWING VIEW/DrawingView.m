//
//  DrawingView.m
//  ComicsHead
//
//  Created by mac4 on 11/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DrawingView.h"
//#import "Utils.h"
#import "AppDelegate.h"
#import "DrawingViewController.h"
//#import "EditorViewController.h"

#define kScaleFactor 0.0f

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface DrawingView()<UIGestureRecognizerDelegate>
//@property (nonatomic,assign) EditorViewController *editorViewController;
@property (nonatomic,assign) DrawingViewController *drawingViewController;
@end

@implementation DrawingView
@synthesize drawX;
@synthesize drawY;
@synthesize drawWidth;
@synthesize drawHeight;
@synthesize canDraw;
@synthesize drawingViewController;
@synthesize drawingMode;
@synthesize pathArray;
@synthesize redoPathArray;
@synthesize fillColor;
//@synthesize paintControlView;
//@synthesize drawnImagesArray;
//@synthesize redoImagesArray;

@synthesize drawColor;
@synthesize offScrImg;
//@synthesize editorViewController;

+ (CGRect)getScreenFrameForOrientation{
	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    CGRect fullScreenRect = [[UIScreen mainScreen] bounds];

    // implicitly in Portrait orientation.
    if (UIInterfaceOrientationIsLandscape(orientation)) {
      CGRect temp = CGRectZero;
      temp.size.width = fullScreenRect.size.height;
      temp.size.height = fullScreenRect.size.width;
      fullScreenRect = temp;
    }
	/*
    if (![[UIApplication sharedApplication] statusBarHidden]) {
      CGFloat statusBarHeight = 20; // Needs a better solution, FYI statusBarFrame reports wrong in some cases..
      fullScreenRect.size.height -= statusBarHeight;
    }
	*/
    return fullScreenRect;
} 
- (id)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
//        self.tag                            = kPOPUP_Tag;
        self.userInteractionEnabled         = YES;
        self.multipleTouchEnabled           = NO;
        self.contentScaleFactor             = 1.0f;
        drawingMode                         = 1;                // 0 - fill path    1 - drawPath    2 - draw Rect   3 - draw ellipse    4 - erase
        pathArray                           = [[NSMutableArray alloc] init ];
        redoPathArray                       = [[NSMutableArray alloc] init ];
        drawFilledorOpenedShape = 0;
        
//        [self setDrawColor:[UIColor blackColor]];
        drawColor                           =  [UIColor blackColor];
        fillColor                           = [UIColor blackColor];
        

        
    }
    return self;
}

- (void)sliderAction:(UISlider*)sender{
    

    if (drawingMode == 1)//pencil
    {
        pencillineWidth     = (sender.value);

    }
    else if(drawingMode == 11) { // Crayon size
        strightlineWidth    =   (sender.value);
    }else{                  // Eraser size
        eraserlineWidth     = (sender.value);    
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];        
    [defaults setInteger:pencillineWidth forKey:@"paint-pencil"];
    [defaults setInteger:strightlineWidth forKey:@"paint-line"];
    [defaults setInteger:eraserlineWidth forKey:@"paint-eraser"];
    [defaults synchronize];
       
}



- (void) finishPath {
//    if (drawingPath) {
//        CGPathRelease(drawingPath);
//    }
    CGPathCloseSubpath(path);
//    drawingPath = CGPathCreateCopy(path);
//    CGPathRelease(path);
//    path = NULL;
    // [self setNeedsDisplay];
    [self setNeedsDisplayInRect:CGRectMake(drawX,drawY,drawWidth,drawHeight)];
}



bool makeOffScreen=false;
bool moveToolView=false;


CGPoint midPoint(CGPoint p1, CGPoint p2)
{
    return CGPointMake((p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5);
}



- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    //printf(" touch at paint view");
    UILabel *label = (UILabel *)[drawingViewController.view viewWithTag:9873];
    
    if(label != nil)
        [label removeFromSuperview];
    if(canDraw)
    {
    

//        for(id view in paintControlView.subviews)
//        {
//            if([view isKindOfClass:[UIButton class]])
//            {
//                UIButton *btn = (UIButton*)view;
//                btn.selected = NO;
//            }
//            
//        }
        
//        if(drawingMode == 1)
//        {
//            [(UIButton*)[paintControlView viewWithTag:kPencil] setSelected:YES];
//        }
//        else if(drawingMode == 11)
//        {
//            [(UIButton*)[paintControlView viewWithTag:kline] setSelected:YES];
//        }
//        else if(drawingMode == 4)
//        {
//            [(UIButton*)[paintControlView viewWithTag:kEraser] setSelected:YES];
//        }
//        else if(drawingMode >=2 && drawingMode <=10)
//        {
//            [(UIButton*)[paintControlView viewWithTag:kShapes] setSelected:YES];
//        }
//        [paintControlView.pencilsliderView removeFromSuperview];
//        paintControlView.pencilsliderView = nil;
//        [paintControlView.colorToolView removeFromSuperview];
//        paintControlView.colorToolView = nil;
//        [paintControlView.shapeToolView removeFromSuperview];
//        paintControlView.shapeToolView = nil;
////        [self changeScrollViewZoomingState];
        
        UITouch *t = [touches anyObject];
        
        printf("\n touch count %ld %ld",touches.count,t.tapCount);
        
        CGPoint p ;
        previousPoint1              = [t previousLocationInView:self];
        previousPoint2              = [t previousLocationInView:self];
        currentPoint                = [t locationInView:self];
        
        p                           =  currentPoint;
        
        touchBegin                  =   currentPoint;

        if(CGRectContainsPoint(currentRect,p)==false)
            {
            return;
            }
//        if(p.y < 43 && paintControlView.visible)
//        {
//            return;
//        }

        istouch                     =   YES;

//        paintControlView.hidden    =   YES;
        


           
        if(path){
            CGPathRelease(path);
            path = NULL;
        }
        
        path = CGPathCreateMutable();
        
        start = CGRectZero;
        start.origin = p;
        startPoint = p;
        start = CGRectInset(start,-10, -10);
        outsideStart = NO;
        CGPathMoveToPoint(path, NULL, p.x, p.y);
        moveToolView=false;
        
        if(drawingMode == 1 || drawingMode == 2 || drawingMode == 3 || drawingMode == 4 || drawingMode == 5|| drawingMode == 11){
            if(p.x < x1){
                x1 = p.x;
            }
            if(p.y < y1){
                y1 = p.y;
            }
            if(p.x > x2){
                x2 = p.x;
            }
            if(p.y > y2){
                y2 = p.y;
            }
        }
        

//        [paintControlView colorDone:nil];
        [self touchesMoved:touches withEvent:event];
    }
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if(canDraw)
    {
    if (!path) {
        return;
    }
    switch (drawingMode) {
        case 0:{
            UITouch *t = [touches anyObject];
            CGPoint p = [t locationInView:self];
            if (CGRectContainsPoint(start,p)) {
                if (outsideStart) {
                    [self finishPath];
                }
            }else {
                outsideStart = YES;
            }
            CGPathAddLineToPoint(path,NULL,p.x,p.y);
            [self setNeedsDisplayInRect:CGRectMake(drawX,drawY,drawWidth,drawHeight)];
//            // 5 star
//            CGPathMoveToPoint(path,NULL,x+width/2,y);
//            CGPathAddLineToPoint(path,NULL,x+((width*3)/10)+((width*8)/100),y+((height*3)/10)+((height*8)/100));
        }break;
            case 4:
             case 1:{
            UITouch *t = [touches anyObject];
            previousPoint2  = previousPoint1;
            previousPoint1  = [t previousLocationInView:self];
            currentPoint    = [t locationInView:self];
            
            CGPoint p       =   currentPoint;
//            // Stright line
//            CGPathMoveToPoint(path,NULL,touchBegin.x,touchBegin.y);
//            CGPathAddLineToPoint(path,NULL,p.x,p.y);
            
                if([pathArray count]>pathArrayCount){
                    for(NSInteger i=pathArrayCount;i<[pathArray count];i++){
                        [pathArray removeObjectAtIndex:i];
                    }
                }
                 
                 
                
                // calculate mid point
                CGPoint mid1    = midPoint(previousPoint1, previousPoint2); 
                CGPoint mid2    = midPoint(currentPoint, previousPoint1);
                
                CGPathMoveToPoint(path, NULL, mid1.x, mid1.y);
                CGPathAddQuadCurveToPoint(path, NULL, previousPoint1.x, previousPoint1.y, mid2.x, mid2.y);
                
                CGMutablePathRef path1 = CGPathCreateMutable();
                CGPathMoveToPoint(path1, NULL, mid1.x, mid1.y);
                CGPathAddQuadCurveToPoint(path1, NULL, previousPoint1.x, previousPoint1.y, mid2.x, mid2.y);
                CGRect bounds = CGPathGetBoundingBox(path1);
                CGPathRelease(path1);
                
               CGRect drawBox = bounds;
                
                 if(drawingMode == 1){
                //Pad our values so the bounding box respects our line width
                drawBox.origin.x        -= pencillineWidth * 0.5f;
                drawBox.origin.y        -= pencillineWidth * 0.5f;
                drawBox.size.width      += pencillineWidth * 1;
                drawBox.size.height     += pencillineWidth * 1;
                 }else if(drawingMode == 4){
                     drawBox.origin.x        -= eraserlineWidth * 0.5f;
                     drawBox.origin.y        -= eraserlineWidth * 0.5f;
                     drawBox.size.width      += eraserlineWidth * 1;
                     drawBox.size.height     += eraserlineWidth * 1;
                 }
                
                [self setNeedsDisplayInRect:drawBox];

//                 UIGraphicsBeginImageContextWithOptions(drawBox.size, NO, kScaleFactor);
//
//                 CGContextClearRect(UIGraphicsGetCurrentContext(), drawBox);
//
//                     [self.layer renderInContext:UIGraphicsGetCurrentContext()];
//                UIGraphicsEndImageContext();
                
                
                UIBezierPath* aPath = [UIBezierPath bezierPath];
                aPath.CGPath = path;
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                [dict setObject:aPath forKey:@"path"];
                if(drawingMode == 4)            {
                    [dict setObject:[UIColor clearColor] forKey:@"color"];
                    NSString *strWidth = [[NSString alloc] initWithFormat:@"%f",eraserlineWidth];            
                    [dict setObject:strWidth forKey:@"lineWidth"];            
//                    [strWidth release];
                }else{
                    [dict setObject:drawColor forKey:@"color"];
                    NSString *strWidth = [[NSString alloc] initWithFormat:@"%f",pencillineWidth];            
                    [dict setObject:strWidth forKey:@"lineWidth"];            
//                    [strWidth release];
                }
                [pathArray addObject:dict];             
//                [dict release];
                
                
                if(p.x < x1){
                    x1 = p.x;
                }
                if(p.y < y1){
                    y1 = p.y;
                }
                if(p.x > x2){
                    x2 = p.x;
                }
                if(p.y > y2){
                    y2 = p.y;
                }
                
                istouch =   YES;

                          
                }break;
        case 2:
        case 5:{
            UITouch *t = [touches anyObject];
            CGPoint p = [t locationInView:self];
            if(path){
                CGPathRelease(path);
                path = NULL;                
                path = CGPathCreateMutable();
            }
            int width=0,height=0;
            int x,y;
            if(startPoint.x >  p.x){
                width = startPoint.x - p.x;
                x = p.x;
            }else{
                width =  p.x - startPoint.x;
                x = startPoint.x;
            }
            
            if(startPoint.y >  p.y){
                height = startPoint.y - p.y;
                y = p.y;
            }else{
                height =  p.y - startPoint.y;
                y = startPoint.y;
            }
            
            CGPathAddRect(path,NULL,CGRectMake(x, y,width, height ) );
            [self setNeedsDisplayInRect:CGRectMake(drawX,drawY,drawWidth,drawHeight)];
            
            if(p.x < x1){
                x1 = p.x;
            }
            if(p.y < y1){
                y1 = p.y;
            }
            if(p.x > x2){
                x2 = p.x;
            }
            if(p.y > y2){
                y2 = p.y;
            }
            
        }break;
        case 3:{
            UITouch *t = [touches anyObject];
            CGPoint p = [t locationInView:self];
            if(path){
                CGPathRelease(path);
                path = NULL;                                
            }
            path = CGPathCreateMutable();
            int width=0,height=0;
            int x,y;
            if(startPoint.x >  p.x){
                width = startPoint.x - p.x;
                x = p.x;
            }else{
                width =  p.x - startPoint.x;
                x = startPoint.x;
            }
            
            if(startPoint.y >  p.y){
                height = startPoint.y - p.y;
                y = p.y;
            }else{
                height =  p.y - startPoint.y;
                y = startPoint.y;
            }
            CGPathAddEllipseInRect(path,NULL,CGRectMake(x, y,width, height ) );
            [self setNeedsDisplayInRect:CGRectMake(drawX,drawY,drawWidth,drawHeight)];
            
            if(p.x < x1){
                x1 = p.x;
            }
            if(p.y < y1){
                y1 = p.y;
            }
            if(p.x > x2){
                x2 = p.x;
            }
            if(p.y > y2){
                y2 = p.y;
            }
        }break;
//        case 4:{
//            UITouch *t = [touches anyObject];
//            CGPoint p = [t locationInView:self];
//            CGPathAddLineToPoint(path,NULL,p.x,p.y);
//            [self setNeedsDisplayInRect:CGRectMake(drawX,drawY,drawWidth,drawHeight)];
//        }break;
        case 6:{
            UITouch *t = [touches anyObject];
            CGPoint p = [t locationInView:self];
            if(path){
                CGPathRelease(path);
                path = NULL;                                
            }
            path = CGPathCreateMutable();
            int width=0,height=0;
            int x,y;
            if(startPoint.x >  p.x){
                width = startPoint.x - p.x;
                x = p.x;
            }else{
                width =  p.x - startPoint.x;
                x = startPoint.x;
            }
            
            if(startPoint.y >  p.y){
                height = startPoint.y - p.y;
                y = p.y;
            }else{
                height =  p.y - startPoint.y;
                y = startPoint.y;
            }
            
            if(p.x < x1){
                x1 = p.x;
            }
            if(p.y < y1){
                y1 = p.y;
            }
            if(p.x > x2){
                x2 = p.x;
            }
            if(p.y > y2){
                y2 = p.y;
            }
            
            CGPathMoveToPoint(path,NULL,x+width/2,y);
            CGPathAddLineToPoint(path,NULL,x,y+height);
            CGPathAddLineToPoint(path,NULL,x+width,y+height);
            CGPathAddLineToPoint(path,NULL,x+width/2,y);
            CGPathAddLineToPoint(path,NULL,x,y+height);
            [self setNeedsDisplayInRect:CGRectMake(drawX,drawY,drawWidth,drawHeight)];
            
        }break;
        case 7:
        {
        }break;
            
        case 8:{
            UITouch *t = [touches anyObject];
            CGPoint p = [t locationInView:self];
            
            if(path){
                CGPathRelease(path);
                path = NULL;                                
            }
            path = CGPathCreateMutable();
            int width=0,height=0;
            int x,y;
            if(startPoint.x >  p.x){
                width = startPoint.x - p.x;
                x = p.x;
                x = x -10;
            }else{
                width =  p.x - startPoint.x;
                x = startPoint.x;
                x = x -10;
            }
            
            if(startPoint.y >  p.y){
                height = startPoint.y - p.y;
                y = p.y;
                y = y -10;
            }else{
                height =  p.y - startPoint.y;
                y = startPoint.y;
                y = y -10;
            }
            
            if(p.x < x1){
                x1 = p.x;
            }
            if(p.y < y1){
                y1 = p.y;
            }
            if(p.x > x2){
                x2 = p.x;
            }
            if(p.y > y2){
                y2 = p.y;
            }
            
            
            // 5 star
            CGPathMoveToPoint(path,NULL,x+width/2,y);
            CGPathAddLineToPoint(path,NULL,x+((width*3)/10)+((width*8)/100),y+((height*3)/10)+((height*8)/100));
            CGPathAddLineToPoint(path,NULL,x,y+((height*3)/10)+((height*8)/100));
            CGPathAddLineToPoint(path,NULL,x+(width*3)/10,y+((height*6)/10)+((height*2)/100));  ////
            CGPathAddLineToPoint(path,NULL,x+((width*1)/5),y+height);
            CGPathAddLineToPoint(path,NULL,x+width/2,y+((height*7)/10)+((height*8)/100));  // centre
            CGPathAddLineToPoint(path,NULL,x+((width*4)/5),y+height);
            CGPathAddLineToPoint(path,NULL,x+((width*7)/10),y+((height*6)/10)+((height*2)/100));  ////
            CGPathAddLineToPoint(path,NULL,x+width,y+((height*3)/10)+((height*8)/100));
            CGPathAddLineToPoint(path,NULL,x+((width*6)/10)+((width*2)/100),y+((height*3)/10)+((height*8)/100));
            CGPathAddLineToPoint(path,NULL,x+width/2,y);
            CGPathAddLineToPoint(path,NULL,x+((width*3)/10)+((width*8)/100),y+((height*3)/10)+((height*8)/100));
            [self setNeedsDisplayInRect:CGRectMake(drawX,drawY,drawWidth,drawHeight)];
            
        }break;
        case 9:{
            UITouch *t = [touches anyObject];
            CGPoint p = [t locationInView:self];
            if(path){
                CGPathRelease(path);
                path = NULL;                                
            }
            path = CGPathCreateMutable();
            int width=0,height=0;
            int x,y;
            if(startPoint.x >  p.x){
                width = startPoint.x - p.x;
                x = p.x;
            }else{
                width =  p.x - startPoint.x;
                x = startPoint.x;
            }
            
            if(startPoint.y >  p.y){
                height = startPoint.y - p.y;
                y = p.y;
            }else{
                height =  p.y - startPoint.y;
                y = startPoint.y;
            }
            
            if(p.x < x1){
                x1 = p.x;
            }
            if(p.y < y1){
                y1 = p.y;
            }
            if(p.x > x2){
                x2 = p.x;
            }
            if(p.y > y2){
                y2 = p.y;
            }
            // pentagon
            CGPathMoveToPoint(path,NULL,x+width/2,y);
            CGPathAddLineToPoint(path,NULL,x,y+((height*3)/10)+((height*8)/100));
            CGPathAddLineToPoint(path,NULL,x+width/5,y+height);
            CGPathAddLineToPoint(path,NULL,x+(width*4)/5,y+height);
            CGPathAddLineToPoint(path,NULL,x+width,y+((height*3)/10)+((height*8)/100));
            CGPathAddLineToPoint(path,NULL,x+width/2,y);
            CGPathAddLineToPoint(path,NULL,x,y+((height*3)/10)+((height*8)/100));  
            [self setNeedsDisplayInRect:CGRectMake(drawX,drawY,drawWidth,drawHeight)];
            
        }break;
        case 10:{
            UITouch *t = [touches anyObject];
            CGPoint p = [t locationInView:self];
            
            if(path){
                CGPathRelease(path);
                path = NULL;                                
            }
            path = CGPathCreateMutable();
            int width=0,height=0;
            int x,y;
            if(startPoint.x >  p.x){
                width = startPoint.x - p.x;
                x = p.x;
            }else{
                width =  p.x - startPoint.x;
                x = startPoint.x;
            }
            
            if(startPoint.y >  p.y){
                height = startPoint.y - p.y;
                y = p.y;
            }else{
                height =  p.y - startPoint.y;
                y = startPoint.y;
            }
            
            if(p.x < x1){
                x1 = p.x;
            }
            if(p.y < y1){
                y1 = p.y;
            }
            if(p.x > x2){
                x2 = p.x;
            }
            if(p.y > y2){
                y2 = p.y;
            }
            
            // hexogon
            CGPathMoveToPoint(path,NULL,x+(width*1)/4,y);
            CGPathAddLineToPoint(path,NULL,x,y+height/2);
            CGPathAddLineToPoint(path,NULL,x+(width*1)/4,y+height);
            CGPathAddLineToPoint(path,NULL,x+(width*3)/4,y+height);
            CGPathAddLineToPoint(path,NULL,x+width,y+height/2);
            CGPathAddLineToPoint(path,NULL,x+(width*3)/4,y);
            CGPathAddLineToPoint(path,NULL,x+(width*1)/4,y);
            CGPathAddLineToPoint(path,NULL,x,y+height/2);
            [self setNeedsDisplayInRect:CGRectMake(drawX,drawY,drawWidth,drawHeight)];
        }break;
        case 11:{
            UITouch *t = [touches anyObject];
            CGPoint p = [t locationInView:self];
            
            if(path){
                CGPathRelease(path);
                path = NULL;                
                path = CGPathCreateMutable();
            }

                       // Stright line
            CGPathMoveToPoint(path,NULL,touchBegin.x,touchBegin.y);
            CGPathAddLineToPoint(path,NULL,p.x,p.y);
            //cgpathad
            [self setNeedsDisplayInRect:CGRectMake(drawX,drawY,drawWidth,drawHeight)];
            
 
            if(p.x < x1){
                x1 = p.x;
            }
            if(p.y < y1){
                y1 = p.y;
            }
            if(p.x > x2){
                x2 = p.x;
            }
            if(p.y > y2){
                y2 = p.y;
            }
            istouch =   YES;

            
        }break;          

        default:
            break;
    }
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(canDraw)
    {
//    [paintControlView hideTooltip:nil];
        //istouch             =   NO;
    
    
    if (!path) {
        return;
    }
//    paintControlView.hidden    =   YES;


    switch (drawingMode) {
        case 0:{
            [self finishPath];
        }break;            
        case 1:
        case 2:
        case 3:
        case 4:
        case 8:
        case 9:
        case 10:
        case 11:
        case 6:
        {    
            for(NSInteger i=pathArrayCount;i<[pathArray count];i++)
            {
                [pathArray removeObjectAtIndex:i];
            }
            UIBezierPath* aPath = [UIBezierPath bezierPath];
            aPath.CGPath = path;
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setObject:aPath forKey:@"path"];
            if(drawingMode == 4)
            {
                [dict setObject:[UIColor clearColor] forKey:@"color"];  //[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:.005f]
                NSString *strWidth = [[NSString alloc] initWithFormat:@"%f",eraserlineWidth];
                [dict setObject:strWidth forKey:@"lineWidth"];
//                [strWidth release];
            }
            else if(drawingMode == 11)
            {
                [dict setObject:drawColor forKey:@"color"];
                NSString *strWidth = [[NSString alloc] initWithFormat:@"%f",strightlineWidth];
                [dict setObject:strWidth forKey:@"lineWidth"];
//                [strWidth release];
            }
            else
            {
                [dict setObject:drawColor forKey:@"color"];
                NSString *strWidth = [[NSString alloc] initWithFormat:@"%f",pencillineWidth];
                [dict setObject:strWidth forKey:@"lineWidth"];
//                [strWidth release];
            }
            
            if((drawingMode==2) || (drawingMode==3) || (drawingMode==6) || (drawingMode==8) || (drawingMode==9) || (drawingMode==10))
            {
                if(drawFilledorOpenedShape == 1)
                {
                    [dict setObject:drawColor forKey:@"fillcolor"];   
                }
            }
            [pathArray addObject:dict];
            pathArrayCount=[pathArray count];
//            [dict release];
            makeOffScreen = true;
                //[self setNeedsDisplayInRect:CGRectMake(drawX,drawY,drawWidth,drawHeight)];
            [redoPathArray removeAllObjects];
            
//            if ([[UIScreen mainScreen] scale] <= 2.0f ||[@"iPad1,1" isEqualToString:[UIDeviceHardware platform]]||[@"iPad2,2" isEqualToString:[UIDeviceHardware platform]])
            if(0)
            {
                // commented this for CGContex <Error>
                // if commented drawing shapes disappears
                if (drawingMode==1 )
                {
                    
                    UIGraphicsBeginImageContextWithOptions(CGSizeMake(drawWidth,drawHeight), NO, kScaleFactor);

                    CGContextRef context = UIGraphicsGetCurrentContext();
                    CGContextSetLineWidth(context, pencillineWidth);
                    CGContextSetLineCap(context, kCGLineCapRound);
                    CGContextSetStrokeColorWithColor(context, drawColor.CGColor);
                    if (path){
                        CGContextAddPath(context,path);
                        [drawColor setStroke];
                        if(drawingMode==4){
                            CGContextSetBlendMode(context, kCGBlendModeClear);
                            CGContextSetLineWidth(context, eraserlineWidth);
                        }else if(drawingMode == 11){
                            CGContextSetBlendMode(context, kCGBlendModeNormal);
                            CGContextSetLineWidth(context, strightlineWidth);
                        }else{
                            CGContextSetBlendMode(context, kCGBlendModeNormal);
                            CGContextSetLineWidth(context, pencillineWidth);
                        }
                        if((drawingMode==2) || (drawingMode==3) || (drawingMode==6) || (drawingMode==8) || (drawingMode==9) || (drawingMode==10)){
                            if(drawFilledorOpenedShape == 1){
                                [drawColor setFill];
                                CGContextDrawPath(context,kCGPathFillStroke);
                            }
                            else if(drawFilledorOpenedShape == 0){
                                CGContextDrawPath(context,kCGPathStroke);
                            }
                        }else{
                            CGContextDrawPath(context,kCGPathStroke);
                        }
                        
                        
                    }
                    UIGraphicsEndImageContext();
                }else if(drawingMode != 4){
                    [self renderAllBezierLines];
                }
            }else{
                [self renderCurrentBezierLines];
            }
            
            
            
            istouch             =   NO;

            
            CGPathRelease(path);
            path = NULL;
                        // Clear all redo images if any
            // Reset undo redo buttons
            if(undoCount<10)
                undoCount++;
            
            

            
            BOOL enabled = undoCount>0;
//            [paintControlView setEnabled:enabled ForButtonTag:kUndo];
            //[(UIButton*)[paintControlView viewWithTag:kUndo] setEnabled:YES];
            //[(UIButton*)[paintControlView viewWithTag:kRedo] setEnabled:[redoImagesArray count]>0];
            enabled = [redoPathArray count]>0;
//            [paintControlView setEnabled:enabled ForButtonTag:kRedo];
            //[(UIButton*)[paintControlView viewWithTag:kRedo] setEnabled:enabled];
            
            enabled = [pathArray count] > 0;
//            [paintControlView setEnabled:enabled ForButtonTag:kClear];
            
            
            if(drawingMode == 1 || drawingMode == 4){
                    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                    dispatch_sync(queue, ^{
                        
                        UIGraphicsBeginImageContextWithOptions(currentRect.size, NO, kScaleFactor);
                        
                        CGContextRef context = UIGraphicsGetCurrentContext();
                        
                        CGContextTranslateCTM(context, -currentRect.origin.x,-currentRect.origin.y);
                        //render the container, with the correct coordinate system
                        
                        [self.layer renderInContext:context];
                        
                        
                        CGContextTranslateCTM(context, currentRect.origin.x,currentRect.origin.y);
                        
                        
                        UIImage *image =   UIGraphicsGetImageFromCurrentImageContext();
                        [self setOffScrImg:image];
                        UIGraphicsEndImageContext();
                        
                    });

                
            }


        }break;
        case 7:{
            
        }break;
        default:
            break;
    }
//    paintControlView.hidden    =   NO;

    }
}

- (void) touchesCanceled:(NSSet *)touches withEvent:(UIEvent *)event {
    printf("\n touch count %ld",touches.count);
    if (!path) {
        return;
    }    
    CGPathRelease(path);
    path = NULL;
//    if(self.del)
    //printf("\n touch cancelled");
}

float kPatternWidth = 8;
float kPatternHeight = 8;

-(void)renderAllBezierLines
{
    
    //printf("\n render all lines");
//    
//    if(true){
//        return;
//    }
    
    self.backgroundColor    =   [UIColor clearColor];
        //UIGraphicsBeginImageContext(self.frame.size);
    
    UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, kScaleFactor);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //    if([drawnImagesArray count] > 0)
    //        [[drawnImagesArray lastObject] drawAtPoint:CGPointZero];
    
    //CGRect rectPart=CGRectMake(drawX, drawY, drawWidth, drawHeight);
    CGContextClearRect(context,self.frame);
    CGContextClipToRect(context,currentRect);
    CGContextSetLineWidth(context, pencillineWidth);
    
    for(NSMutableDictionary *dict in pathArray){        
        kPatternWidth = [[dict objectForKey:@"lineWidth"] floatValue];
        kPatternHeight = [[dict objectForKey:@"lineWidth"] floatValue];
        CGContextSetLineWidth(context, [[dict objectForKey:@"lineWidth"] floatValue] );
        UIBezierPath *bezierPath = [dict objectForKey:@"path"];
        CGPathRef storedPath = [bezierPath CGPath];
        
        
        CGContextAddPath(context,storedPath);
        UIColor *color =  [dict objectForKey:@"color"];//[self getClr:dict];
        if([color isEqual:[UIColor clearColor]])
            CGContextSetBlendMode(context, kCGBlendModeClear);
        else
            CGContextSetBlendMode(context, kCGBlendModeNormal);
        
        CGContextSetFlatness(context, 1.0);
        [color setStroke];
        [color setFill];
        
        CGContextSetLineCap(context, kCGLineCapRound);
//        if (drawingMode !=3)
//            {
//            CGContextSetLineJoin(context, kCGLineJoinRound); 
//
//        }
        if([dict objectForKey:@"fillcolor"])
        {
            UIColor *fillcolor = [dict objectForKey:@"fillcolor"];
            [fillcolor setFill];
            CGContextDrawPath(context,kCGPathFillStroke);
        }
        else 
        {
            CGContextDrawPath(context,kCGPathStroke);
        }
        
        
        
    }
    
    if (path) {
        CGContextAddPath(context,path);
        [drawColor setStroke];
        if(drawingMode==4)
        {
            CGContextSetBlendMode(context, kCGBlendModeClear);
            CGContextSetLineWidth(context, eraserlineWidth);
        } else  if(drawingMode==11)
        {
            CGContextSetBlendMode(context, kCGBlendModeNormal);
            CGContextSetLineWidth(context, strightlineWidth);
        }
        else
        {
            CGContextSetBlendMode(context, kCGBlendModeNormal);
            CGContextSetLineWidth(context, pencillineWidth);
        }
        if((drawingMode==2) || (drawingMode==3) || (drawingMode==6) || (drawingMode==8) || (drawingMode==9) || (drawingMode==10))
        {
            if(drawFilledorOpenedShape == 1)
            {
                [drawColor setFill];
                CGContextDrawPath(context,kCGPathFillStroke);
            }
            else   if(drawFilledorOpenedShape == 0)
            {
                CGContextDrawPath(context,kCGPathStroke);
            }
        }
        else
        {
            CGContextDrawPath(context,kCGPathStroke);
        }
        
    }
    
    //[self.layer renderInContext:context];
    UIImage *image          =   UIGraphicsGetImageFromCurrentImageContext();
    
    [self setOffScrImg:nil];

    self.backgroundColor    =   [UIColor colorWithPatternImage:image];
    [self setOpaque:NO];
    [self.layer setOpaque:NO];
    UIGraphicsEndImageContext();
    
    
    
}



-(void)renderCurrentBezierLines
{
    
    
    UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, kScaleFactor);

    CGContextRef context = UIGraphicsGetCurrentContext();
    //    if([drawnImagesArray count] > 0)
    //        [[drawnImagesArray lastObject] drawAtPoint:CGPointZero];
    
    CGContextClearRect(context,self.frame);
    CGContextClipToRect(context,currentRect);
    CGContextSetLineWidth(context, pencillineWidth);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetStrokeColorWithColor(context, drawColor.CGColor);
      
//    [touchmage drawAtPoint:CGPointZero];
   // [touchImage drawInRect:rectPart];
    
    if (path) {
        CGContextAddPath(context,path);
        [drawColor setStroke];
        if(drawingMode==4)
        {
            CGContextSetBlendMode(context, kCGBlendModeClear);
            CGContextSetLineWidth(context, eraserlineWidth);
        }
        else if(drawingMode == 11)
        {
            CGContextSetBlendMode(context, kCGBlendModeNormal);
            CGContextSetLineWidth(context, strightlineWidth);
        }
        else
        {
            CGContextSetBlendMode(context, kCGBlendModeNormal);
            CGContextSetLineWidth(context, pencillineWidth);
        }
        if((drawingMode==2) || (drawingMode==3) || (drawingMode==6) || (drawingMode==8) || (drawingMode==9) || (drawingMode==10))
        {
            if(drawFilledorOpenedShape == 1)
            {
                [drawColor setFill];
                CGContextDrawPath(context,kCGPathFillStroke);
            }
            else if(drawFilledorOpenedShape == 0)
            {
                CGContextDrawPath(context,kCGPathStroke);
            }
        }
        else
        {
            CGContextDrawPath(context,kCGPathStroke);
        }
        
    }
    
//    [touchImage release];
    //[self.layer renderInContext:context];
    UIImage *image          =   UIGraphicsGetImageFromCurrentImageContext();
    self.backgroundColor    =   [UIColor colorWithPatternImage:image];
    [self setOpaque:NO];
    [self.layer setOpaque:NO];
    UIGraphicsEndImageContext();
    

}

- (void)drawRect:(CGRect)rect        {
    
    
//    if (!istouch)
//    {
//        printf("\n return drawrect");
//        CGContextRef context = UIGraphicsGetCurrentContext();
//        CGContextClipToRect(context,CGRectMake(drawX, drawY, drawWidth, drawHeight));
//
//        if(offScrImg)
//            [offScrImg drawAtPoint:CGPointZero];
//        return;
//    }
    
//    paintControlView.hidden    =   YES;
    
//    if ([[UIScreen mainScreen] scale] <= 2.0f||[@"iPad1,1" isEqualToString:[UIDeviceHardware platform]]||[@"iPad2,2" isEqualToString:[UIDeviceHardware platform]])
    if(0)
        {
        switch (drawingMode){
            case 1:
            case 4:
            {
//                CGContextRef context = UIGraphicsGetCurrentContext();
//                CGContextClipToRect(context,currentRect);
//                [self.layer renderInContext:context];
            }
            case 11:
            {
                CGContextRef context = UIGraphicsGetCurrentContext();
                
                
                //CGContextClipToRect(context,CGRectMake(drawX, drawY, drawWidth, drawHeight));
                if(offScrImg ){
                    CGContextClearRect(context,currentRect);
                    [offScrImg drawAtPoint:currentRect.origin]; //CGPointMake(drawX, drawY)currentRect.origin
                }
                
                
                
                CGContextClipToRect(context,currentRect);
                CGContextSetLineWidth(context, pencillineWidth);
                CGContextSetLineCap(context, kCGLineCapRound);
                CGContextSetStrokeColorWithColor(context, drawColor.CGColor);

                if (path) {
                    CGContextAddPath(context,path);
                    [drawColor setStroke];
                    if(drawingMode==4)
                    {
                        CGContextSetBlendMode(context, kCGBlendModeClear);
                        CGContextSetLineWidth(context, eraserlineWidth);
                    }
                else if(drawingMode==11)
                    {
                        CGContextSetBlendMode(context, kCGBlendModeNormal);
                        CGContextSetLineWidth(context, strightlineWidth);
                    }
                else
                    {
                        CGContextSetBlendMode(context, kCGBlendModeNormal);
                        CGContextSetLineWidth(context, pencillineWidth);
                    }
                if((drawingMode==2) || (drawingMode==3) || (drawingMode==6) || (drawingMode==8) || (drawingMode==9) || (drawingMode==10))
                {
                    if(drawFilledorOpenedShape == 1)
                    {
                        [drawColor setFill];
                        CGContextDrawPath(context,kCGPathFillStroke);
                    }
                    else   if(drawFilledorOpenedShape == 0)
                    {
                        CGContextDrawPath(context,kCGPathStroke);
                    }
                }
                else
                {
                    
                    CGContextDrawPath(context,kCGPathStroke);
                }
                    
                   
                
            }
            }break;
                default:
                if (path) {
                    
                    CGContextRef context = UIGraphicsGetCurrentContext();
                    
                    CGContextAddPath(context,path);
                    CGContextSetLineCap(context, kCGLineCapRound);
                    
                    [drawColor setStroke];
                    if(drawingMode==4)
                        {
                        CGContextSetBlendMode(context, kCGBlendModeClear);
                        CGContextSetLineWidth(context, eraserlineWidth);
                        }
                    else
                        {
                        CGContextSetBlendMode(context, kCGBlendModeNormal);
                        CGContextSetLineWidth(context, pencillineWidth);
                        }
                    if((drawingMode==2) || (drawingMode==3) || (drawingMode==6) || (drawingMode==8) || (drawingMode==9) || (drawingMode==10))
                        {
                        if(drawFilledorOpenedShape == 1)
                            {
                            [drawColor setFill];
                            CGContextDrawPath(context,kCGPathFillStroke);
                            }
                        else   if(drawFilledorOpenedShape == 0)
                            {
                            CGContextDrawPath(context,kCGPathStroke);
                            }
                        }
                    else
                        {
                            CGContextDrawPath(context,kCGPathStroke);

                        }
                }
                break;
        
        }
        }
//    paintControlView.hidden    =   NO;
    
    [super drawRect:rect];
    
    
}

-(UIColor *)getClr:(NSDictionary *)_dict
{
    if (drawrectColor)
    {
//        [drawrectColor release];
        drawrectColor   =   nil;
    }
    drawrectColor = [_dict objectForKey:@"color"] ;
    
    return drawrectColor;
}


- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    // Was there an error?
    if (error != NULL){
        //printf("\n image save error messsagekl l ljlkjasdf ");
        // Show error message...        
    }else{  // No errors    
        // Show message image successfully saved
        //printf("\n image successfully saved ");
    }
}

//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
//    if(alertView.tag == 50){
//        if(buttonIndex == 0){                
//        }else if(buttonIndex == 1){
//            //[drawnImagesArray removeAllObjects];
//            //[redoImagesArray removeAllObjects];
//            
//            [pathArray removeAllObjects];
//            [redoPathArray removeAllObjects];
//            
//            self.backgroundColor = [UIColor clearColor];
//            
//            [self setNeedsDisplayInRect:CGRectMake(drawX,drawY,drawWidth,drawHeight)];
//            undoCount = 0;
//            [(UIButton*)[paintControlView viewWithTag:kUndo] setEnabled:undoCount>0];
//            //[(UIButton*)[paintControlView viewWithTag:kRedo] setEnabled:[redoImagesArray count]>0];
//            [(UIButton*)[paintControlView viewWithTag:kRedo] setEnabled:[redoPathArray count]>0];
//            
//            [paintControlView setEnabled:NO ForButtonTag:kClear];
//            
//            pathArrayCount = [pathArray count];
//            
//            [self setOffScrImg:nil];
//            
//        }
//    }
//}



-(void)buttonPressed:(id)sender{
//    UIButton *btn = (UIButton *)sender;
//    
//    
//    if (/*btn.tag==kUndo||btn.tag==kRedo ||*/btn.tag==kPencil||btn.tag==kline||btn.tag==kEraser||btn.tag==kRect||btn.tag==kCircle||btn.tag==kTriangle||btn.tag==k5Star||btn.tag==kPentagon||btn.tag==kHexogon||btn.tag==kFilledRect||btn.tag==kFilledCircle||btn.tag==kFilledTriangle||btn.tag==kFilled5Star||btn.tag==kFilledPentagon||btn.tag==kFilledHexogon) {
//        [self renderAllBezierLines];
//        [self setNeedsDisplay];
//    }
//    if(btn.tag!=kZoom)
//    {
//        canDraw = true;
//        [self changeScrollViewZoomingState];
//    }
//    switch (btn.tag) {
//            case kColors:
//            {
////                [UIAppDelegate openDownloadedAssets];
//            }
//            break;
//                   case kDone:{
//            editorViewController.isEdited=true;
//                       editorViewController.isComicsSaved = NO;
//            
//            [paintControlView showHide:nil];
//            
//                                 paintControlView.frame = CGRectMake(0,-kControlHeight,1024,kControlHeight);
//                                 
//                                 paintControlView.hidden    =   YES;
//                                 int width = fabs(x1-x2);
//                                 int height = fabs(y1-y2);
//                       
//                       if(x1 != kAppWidth && (width==0||height==0)){
//                           width = pencillineWidth;
//                           height = pencillineWidth;
//                       }
//                           
//                                 
//                                 if(x1 != kAppWidth && y1 != kAppHeight && width > 0 && height > 0){
//                                     
//                                     
//                                     x1 = 0;y1 = 0;
//                                     width = kAppWidth;
//                                     height = kAppHeight;
//
//                                     
//                                     UIGraphicsBeginImageContext(CGSizeMake(kAppWidth,kAppHeight));
//                                     CGContextRef context = UIGraphicsGetCurrentContext();
//                                         //CGContextSetLineWidth(context, pencillineWidth); 
//                                     // CGContextClearRect(context,self.frame);
//                                     CGContextClipToRect(context,currentRect);
//                                     
//                                     [self.layer renderInContext:context];
//                                    
//                                     UIImage *originalImage = UIGraphicsGetImageFromCurrentImageContext();
//                                     UIGraphicsEndImageContext();
//                                     
//                                     //UIImage *originalImage = [drawnImagesArray lastObject];
//                                     
//                                     int xCorner,yCorner;
//                                     xCorner=x1;
//                                     yCorner=y1;
//                                     if(x1<drawX)
//                                     {
//                                         xCorner=drawX;
//                                         width=(width-(drawX-x1));
//                                         x1=0;   
//                                     }
//                                     else
//                                     {
//                                         x1=x1-drawX;
//                                     }
//                                     if(y1<drawY)
//                                     {
//                                         yCorner=drawY;
//                                         height=(height-(drawY-y1));
//                                         y1=0;
//                                     }
//                                     else
//                                     {
//                                         y1=y1-drawY;
//                                     }
//                                     
//                                     if((x1+width)>drawWidth)
//                                     {
//                                         width=drawWidth-x1;
//                                     }
//                                     if((y1+height)>drawHeight)
//                                     {
//                                         height=drawHeight-y1;
//                                     }
//                                     
//                                     CGImageRef imageRe = CGImageCreateWithImageInRect([originalImage CGImage], CGRectMake(xCorner, yCorner, width, height));
//                                     UIImage *finalImag = [[UIImage alloc]initWithCGImage:imageRe]; 
//                                     // UIImage *finalImag = [UIImage imageWithCGImage:imageRe]; 
//                                     CGImageRelease(imageRe);            
//                                     
//                                     
//                                     CGImageRef imageRef = CGImageCreateWithImageInRect([finalImag CGImage], CGRectMake(0, 0, width, height));
////                                     [finalImag release];
//                                     finalImag   =   nil;
//                                     UIImage *image = [[UIImage alloc]initWithCGImage:imageRef]; 
//                                     
//                                     //UIImage *finalImage = [UIImage imageWithCGImage:imageRef]; 
//                                     CGImageRelease(imageRef);
//                                     
//                                     // UIImage* image = finalImage;
//                                     CGImageRef cgimage = image.CGImage;
//                                     
//                                     
//                                     size_t width  = CGImageGetWidth(cgimage);
//                                     size_t height = CGImageGetHeight(cgimage);
//                                     
//                                     if((width>0) && (height>0))
//                                     {
//                                         size_t bpr = CGImageGetBytesPerRow(cgimage);
//                                         size_t bpp = CGImageGetBitsPerPixel(cgimage);
//                                         size_t bpc = CGImageGetBitsPerComponent(cgimage);
//                                         size_t bytes_per_pixel = bpp / bpc;
//                                         CGDataProviderRef provider = CGImageGetDataProvider(cgimage);
//                                         NSData* data = (id)CFBridgingRelease(CGDataProviderCopyData(provider));
//                                         
//                                         
//                                         //[data autorelease];
//                                         const uint8_t* bytes = [data bytes];
//                                         
//                                         int transparent;
//                                         int top,top1;
//                                         top=0;top1=0;
//                                         for(size_t row = 0; row < height; row++)
//                                         {
//                                             transparent=0;
//                                             for(size_t col = 0; col < width; col++)
//                                             {
//                                                 const uint8_t* pixel =
//                                                 &bytes[row * bpr + col * bytes_per_pixel];
//                                                 
//                                                 for(size_t x = 0; x < bytes_per_pixel; x++)
//                                                 {
//                                                     if(pixel[x]>0)
//                                                     {
//                                                         transparent=1; 
//                                                     }
//                                                 }
//                                             }
//                                             if((transparent==0)&&(top1==0))
//                                             {
//                                                 top++;
//                                             }
//                                             else
//                                             {
//                                                 top1=100;
//                                             }
//                                         }
//                                         
//                                         int bottom,bottom1;
//                                         bottom=0;bottom1=0;
//                                         for(size_t row = height-1; row > 0; row--)
//                                         {
//                                             transparent=0;
//                                             for(size_t col = 0; col < width; col++)
//                                             {
//                                                 const uint8_t* pixel =
//                                                 &bytes[row * bpr + col * bytes_per_pixel];
//                                                 for(size_t x = 0; x < bytes_per_pixel; x++)
//                                                 {
//                                                     if(pixel[x]>0)
//                                                     {
//                                                         transparent=1; 
//                                                     }
//                                                 }
//                                             }
//                                             if((transparent==0)&&(bottom1==0))
//                                             {
//                                                 bottom++;
//                                             }
//                                             else
//                                             {
//                                                 bottom1=100;
//                                             }
//                                         }
//                                         
//                                         int left,left1;
//                                         left=0;left1=0;
//                                         for(size_t row = 0; row < width; row++)
//                                         {
//                                             transparent=0;
//                                             for(size_t col = 0; col < height; col++)
//                                             {
//                                                 const uint8_t* pixel =
//                                                 &bytes[col * bpr + row * bytes_per_pixel];
//                                                 for(size_t x = 0; x < bytes_per_pixel; x++)
//                                                 {
//                                                     if(pixel[x]>0)
//                                                     {
//                                                         transparent=1; 
//                                                     }
//                                                 }
//                                             }
//                                             if((transparent==0)&&(left1==0))
//                                             {
//                                                 left++;
//                                             }
//                                             else
//                                             {
//                                                 left1=100;
//                                             }
//                                         }
//                                         
//                                         int right,right1;
//                                         right=0;right1=0;
//                                         for(size_t row = width-1; row >0 ; row--)
//                                         {
//                                             transparent=0;
//                                             for(size_t col = 0; col < height; col++)
//                                             {
//                                                 const uint8_t* pixel =
//                                                 &bytes[col * bpr + row * bytes_per_pixel];
//                                                 for(size_t x = 0; x < bytes_per_pixel; x++)
//                                                 {
//                                                     if(pixel[x]>0)
//                                                     {
//                                                         transparent=1; 
//                                                     }
//                                                 }
//                                             }
//                                             if((transparent==0)&&(right1==0))
//                                             {
//                                                 right++;
//                                             }
//                                             else
//                                             {
//                                                 right1=100;
//                                             }
//                                         }
//                                         
//                                         
//                                         NSInteger x,y;
//                                         x=x1;x=x+width;
//                                         y=y1;y=y+height;
//                                         y1=y1+top;
//                                         height=height-(bottom+top);
//                                         x1=x1+left;
//                                         width=width-(right+left);
//                                         
//                                         
//                                         
//                                         if((x1==x) && (y1==y))
//                                         {
//                                         }
//                                         else
//                                         {
//                                             CGImageRef imageRef1;
//                                             if(drawX==0)
//                                             {
//                                                 if(drawY==0)
//                                                 {
//                                                     imageRef1 = CGImageCreateWithImageInRect([originalImage CGImage], CGRectMake(x1,y1, width, height));
//                                                 }
//                                                 else  if(drawY>0)
//                                                 {
//                                                     imageRef1 = CGImageCreateWithImageInRect([originalImage CGImage], CGRectMake(x1,drawY+y1, width, height));
//                                                 }
//                                             }
//                                             else   if(drawX>0)
//                                             {
//                                                 if(drawY==0)
//                                                 {
//                                                     imageRef1 = CGImageCreateWithImageInRect([originalImage CGImage], CGRectMake(drawX+x1,y1, width, height));
//                                                 }
//                                                 else  if(drawY>0)
//                                                 {
//                                                     imageRef1 = CGImageCreateWithImageInRect([originalImage CGImage], CGRectMake(drawX+x1,drawY+y1, width, height));
//                                                 }
//                                             }
//                                             
//                                             UIImage *finalImage1 = [[UIImage alloc]initWithCGImage:imageRef1]; 
//                                             CGImageRelease(imageRef1);   
//
//                                             
//                                             
//                                             if (width<40)
//                                             {
//                                                 width  =   40;
//                                             }
//                                             if (height<40)
//                                             {
//                                                 height  =   40;
//                                             }
//
//                                             int w,h;
//                                             //int s_w,s_h;
//                                             CGPoint drawPoint  =   CGPointMake(w = width>40?0:5, h = height>40?0:5);
//                                             UIGraphicsBeginImageContext(CGSizeMake(width = width>40?width:width + 5, height = height>40?height:height + 5));
//                                             [finalImage1 drawAtPoint:drawPoint];
//                                             UIImage *gr_Image  =   UIGraphicsGetImageFromCurrentImageContext();
//                                             UIGraphicsEndImageContext();
////                                             [finalImage1 release];
//                                             
////                                             [drawingViewController dismissViewControllerAnimated:NO completion:nil];
//                                             // Modified on Oct 4 2012
//                                             [editorViewController addImageToPage:gr_Image withFrame:CGRectMake(x1,y1, width,height) :nil] ;
//                                             [Utils logPageEvent:@"Assets" action:@"PaintObject" label:@""];
//
//                                         }
////                                         [data release];
//
//                                     }
////                                     [image release];
//
//                                     
//                                 }
//                                 x1 = kAppWidth;
//                                 y1 = kAppHeight;
//                                 x2 = 0;
//                                 y2 = 0;
//                                 
//
////                             }
////                             completion:^(BOOL finished){
////                                 if(finished){
//                                     paintControlView.hidden    =   NO;
////                                       [drawingViewController.navigationController popViewControllerAnimated:NO];
//                       [drawingViewController dismissViewControllerAnimated:NO completion:nil];
//                                     [editorViewController closePaintview:nil];
////                                 }
////                             }];
//            
//            
//                       
//            
//        }break;
//        case kZoom:
//        {
//            [Utils logPageEvent:@"PaintTool" action:@"Redo" label:@""];
//            canDraw = !canDraw;
//            [self changeScrollViewZoomingState];
//        }
//        break;
//        case 1:{
//            [UIView animateWithDuration:0.3 
//                                  delay:0.0 
//                                options:  UIViewAnimationOptionCurveEaseInOut
//                             animations:^{
//                                 [[self viewWithTag:kPOPUP_Tag] setAlpha:0.0];
//                             } 
//                             completion:^(BOOL finished){
//                                 if(finished){
//                                     [[self viewWithTag:kPOPUP_Tag] removeFromSuperview]; 
//                                 }
//                             }];
//            
//            
//            
//        }break;            
//        case 2:{
//            
//        }break;            
//        case kRedo:{   // redo
//            [Utils logPageEvent:@"PaintTool" action:@"Redo" label:@""];
//            if([redoPathArray count] > 0){
//                
//                undoCount++;
//                [pathArray addObject:[redoPathArray lastObject]];
//                [redoPathArray removeLastObject];
//                [self renderAllBezierLines];
//                [self setNeedsDisplay];
//                [(UIButton*)[paintControlView viewWithTag:kUndo] setEnabled:undoCount>0];
//                [(UIButton*)[paintControlView viewWithTag:kRedo] setEnabled:[redoPathArray count]>0];
//                [paintControlView setEnabled:YES ForButtonTag:kClear];
//                pathArrayCount=(int)[pathArray count];
//            }
//        }break;
//        case kUndo:{   // undo
//            [Utils logPageEvent:@"PaintTool" action:@"Undo" label:@""];
//            if(undoCount > 0 ){
//                undoCount--;
//                [redoPathArray addObject:[pathArray lastObject]];
//                [pathArray removeLastObject];
//                [self renderAllBezierLines];
//
//                [self setNeedsDisplayInRect:CGRectMake(drawX,drawY,drawWidth,drawHeight)];
//                
//                [(UIButton*)[paintControlView viewWithTag:kUndo] setEnabled:undoCount!=0];
//                [(UIButton*)[paintControlView viewWithTag:kRedo] setEnabled:[redoPathArray count]>0];
//                [paintControlView setEnabled:[pathArray count]>0 ForButtonTag:kClear];
//                pathArrayCount=(int)[pathArray count];
//            }
//            
//        }break;
//        case kClear:{   // clear
//            [Utils logPageEvent:@"PaintTool" action:@"Clear All" label:@""];
//            //printf("\nclear all called");
////                      UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
////                                                                message:NSLocalizedString(@"Do you want to clear all the art you did?",nil)  delegate:self
////                                                      cancelButtonTitle:NSLocalizedString(@"No", nil)				//Cancel
////                                                      otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];			//OK
////            [alertView show];
////            alertView.tag = 50;
////            [alertView release];
//            
////            SCLAlertView *alert = [[SCLAlertView alloc] init];
////            
////            [alert addButton:NSLocalizedString(@"Yes",nil) actionBlock:^(void) {
////                
//////                [drawingViewController.scrollView zoomToRect:CGRectMake(0, 0, 1024, 768) animated:NO];
////                CGPoint center = drawingViewController.zoomView.center;
////                drawingViewController.zoomView.transform = CGAffineTransformMakeScale(1.0, 1.0);
////                drawingViewController.scrollView.contentSize = CGSizeZero;
////                drawingViewController.zoomView.center = CGPointMake(1024/2, 768/2);//center;
////
////                
////                [pathArray removeAllObjects];
////                [redoPathArray removeAllObjects];
////                
////                self.backgroundColor = [UIColor clearColor];
////                
////                [self setNeedsDisplayInRect:CGRectMake(drawX,drawY,drawWidth,drawHeight)];
////                undoCount = 0;
////                [(UIButton*)[paintControlView viewWithTag:kUndo] setEnabled:undoCount>0];
////                //[(UIButton*)[paintControlView viewWithTag:kRedo] setEnabled:[redoImagesArray count]>0];
////                [(UIButton*)[paintControlView viewWithTag:kRedo] setEnabled:[redoPathArray count]>0];
////                
////                [paintControlView setEnabled:NO ForButtonTag:kClear];
////                
////                pathArrayCount = (int)[pathArray count];
////                
////                [self setOffScrImg:nil];
////
////            }];
////
////            [alert showSuccess:editorViewController title:@"" subTitle:NSLocalizedString(@"Do you want to clear all the art you did?",nil) closeButtonTitle:NSLocalizedString(@"No",nil) duration:0.0f];
//            
//            
//            
//            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"Do you want to clear all the art you did?", nil) preferredStyle:UIAlertControllerStyleAlert];
//            UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
////                CGPoint center = drawingViewController.zoomView.center;
//                drawingViewController.zoomView.transform = CGAffineTransformMakeScale(1.0, 1.0);
//                drawingViewController.scrollView.contentSize = CGSizeZero;
//                drawingViewController.zoomView.center = CGPointMake(kAppWidth/2, kAppHeight/2);//center;
//                
//                
//                [pathArray removeAllObjects];
//                [redoPathArray removeAllObjects];
//                
//                self.backgroundColor = [UIColor clearColor];
//                
//                [self setNeedsDisplayInRect:CGRectMake(drawX,drawY,drawWidth,drawHeight)];
//                undoCount = 0;
//                [(UIButton*)[paintControlView viewWithTag:kUndo] setEnabled:undoCount>0];
//                //[(UIButton*)[paintControlView viewWithTag:kRedo] setEnabled:[redoImagesArray count]>0];
//                [(UIButton*)[paintControlView viewWithTag:kRedo] setEnabled:[redoPathArray count]>0];
//                
//                [paintControlView setEnabled:NO ForButtonTag:kClear];
//                
//                pathArrayCount = (int)[pathArray count];
//                
//                [self setOffScrImg:nil];
//            }];
//            UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//                
//            }];
//            [alertController addAction:yesAction];
//            [alertController addAction:noAction];
//            [editorViewController presentViewController:alertController animated:NO completion:nil];
////            [alert release];
//
//        }break;
//            
//        case kPencil:{   // pencil
//            drawingMode = 1;
//            [paintControlView.pencilslider setValue:pencillineWidth];
//            
//            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//            [defaults setInteger:drawingMode forKey:@"drawingMode"];            
//            [defaults synchronize];
//            
//        }break;
//        case kline:{   // pencil
//            drawingMode = 11;
//            
//
//            [paintControlView.pencilslider setValue:strightlineWidth];
//
//            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//            [defaults setInteger:drawingMode forKey:@"drawingMode"];            
//            [defaults synchronize];
//            
//        }break;
//
//            
//        case kEraser:{   // eraser
//            drawingMode = 4; 
//
//            [paintControlView.pencilslider setValue:eraserlineWidth];
//            
//        }break;
//        case kRect:{ // Rect
//            drawingMode = 2;
//            drawFilledorOpenedShape = 0;
//            
//            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//            [defaults setInteger:drawingMode forKey:@"drawingMode"];
//            [defaults setInteger:drawFilledorOpenedShape forKey:@"drawFilledorOpenedShape"]; 
//            [defaults synchronize];
//            
//        }break;
//        case kCircle:{ //Circle
//            drawingMode = 3;
//            drawFilledorOpenedShape = 0;
//            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//            [defaults setInteger:drawingMode forKey:@"drawingMode"]; 
//            [defaults setInteger:drawFilledorOpenedShape forKey:@"drawFilledorOpenedShape"]; 
//            [defaults synchronize];
//            
//        }break;
//        case kTriangle:{
//            drawingMode = 6;
//            drawFilledorOpenedShape = 0;
//            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//            [defaults setInteger:drawingMode forKey:@"drawingMode"];   
//            [defaults setInteger:drawFilledorOpenedShape forKey:@"drawFilledorOpenedShape"]; 
//            [defaults synchronize];
//            
//        }break;
//        case k5Star:{ // Rect
//            drawingMode = 8;
//            drawFilledorOpenedShape = 0;
//            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//            [defaults setInteger:drawingMode forKey:@"drawingMode"]; 
//            [defaults setInteger:drawFilledorOpenedShape forKey:@"drawFilledorOpenedShape"]; 
//            [defaults synchronize];
//            
//        }break;
//        case kPentagon:{ // Rect
//            drawingMode = 9;
//            drawFilledorOpenedShape = 0;
//            
//            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//            [defaults setInteger:drawingMode forKey:@"drawingMode"]; 
//            [defaults setInteger:drawFilledorOpenedShape forKey:@"drawFilledorOpenedShape"]; 
//            [defaults synchronize];
//            
//        }break;
//        case kHexogon:{ // Rect
//            drawingMode = 10;
//            drawFilledorOpenedShape = 0;            
//            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//            [defaults setInteger:drawingMode forKey:@"drawingMode"];  
//            [defaults setInteger:drawFilledorOpenedShape forKey:@"drawFilledorOpenedShape"]; 
//            [defaults synchronize];
//            
//        }break;
//            
//        case kFilledRect:{ // Rect
//            drawingMode = 2;
//            drawFilledorOpenedShape = 1;
//            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//            [defaults setInteger:drawingMode forKey:@"drawingMode"];
//            [defaults setInteger:drawFilledorOpenedShape forKey:@"drawFilledorOpenedShape"]; 
//            [defaults synchronize];
//            
//        }break;
//        case kFilledCircle:{ //Circle
//            drawingMode = 3;
//            drawFilledorOpenedShape = 1;
//            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//            [defaults setInteger:drawingMode forKey:@"drawingMode"]; 
//            [defaults setInteger:drawFilledorOpenedShape forKey:@"drawFilledorOpenedShape"]; 
//            [defaults synchronize];
//            
//        }break;
//        case kFilledTriangle:{
//            drawingMode = 6;
//            drawFilledorOpenedShape = 1;
//            
//            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//            [defaults setInteger:drawingMode forKey:@"drawingMode"];  
//            [defaults setInteger:drawFilledorOpenedShape forKey:@"drawFilledorOpenedShape"]; 
//            [defaults synchronize];
//            
//        }break;
//        case kFilled5Star:{ // Rect
//            drawingMode = 8;
//            drawFilledorOpenedShape = 1;
//            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//            [defaults setInteger:drawingMode forKey:@"drawingMode"]; 
//            [defaults setInteger:drawFilledorOpenedShape forKey:@"drawFilledorOpenedShape"]; 
//            [defaults synchronize];
//            
//        }break;
//        case kFilledPentagon:{ // Rect
//            drawingMode = 9;
//            drawFilledorOpenedShape = 1;
//            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//            [defaults setInteger:drawingMode forKey:@"drawingMode"]; 
//            [defaults setInteger:drawFilledorOpenedShape forKey:@"drawFilledorOpenedShape"]; 
//            [defaults synchronize];
//            
//        }break;
//        case kFilledHexogon:{ // Rect
//            drawingMode = 10;
//            drawFilledorOpenedShape = 1;
//            
//            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//            [defaults setInteger:drawingMode forKey:@"drawingMode"];  
//            [defaults setInteger:drawFilledorOpenedShape forKey:@"drawFilledorOpenedShape"]; 
//            [defaults synchronize];
//            
//        }break;
//            
//        default:
//            //[self showPropOptions];
//            [UIView animateWithDuration:0.3 
//                                  delay:0.0 
//                                options:  UIViewAnimationOptionCurveEaseInOut
//                             animations:^{
//                                 [[self viewWithTag:kPOPUP_Tag] setAlpha:1.0];
//                             } 
//                             completion:nil];            
//            
//            break;
//            
//    } 
    
}

-(void)closeAction:(id)sender{
    
    if(drawingMode==1)
    {       
    }
    else if(drawingMode==4)
    {       
        
    }
    
    else  if((drawingMode==2) ||  (drawingMode==3) || (drawingMode==6) || (drawingMode==7) ||  (drawingMode==8) || (drawingMode==9))
    {       
        
    }
    
    
    //    [ColorPalatteBgView removeFromSuperview];
    //    [paletteView removeFromSuperview];
}

- (void) dealloc {
    
    
    [self setOffScrImg:nil];

//    if (drawingPath) {
//        CGPathRelease(drawingPath);
//    }
    if (path) {
        CGPathRelease(path);
    }
//    
//    if(pathArray != nil){
//        [pathArray removeAllObjects];
//        [pathArray release];
//        pathArray = nil;
//    }
//    if(redoPathArray != nil){
//        [redoPathArray removeAllObjects];
//        [redoPathArray release];
//        redoPathArray = nil;
//    }
//        
//    [paintControlView release];
//    if(drawColor){
//        [drawColor release];
//        drawColor = nil;
//    }
//    
////    [self setDrawColor:nil];
//    
//    [super dealloc];
}

-(CGRect)trim:(UIImage*)sourceImage {
    CGImageRef image = [sourceImage CGImage];
    NSUInteger width = CGImageGetWidth(image);
    NSUInteger height = CGImageGetHeight(image);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = malloc(height * width * 4);
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height),image);
    CGContextRelease(context);
    
    
    int pty1=0;
    int x=0;    
    for(pty1=0;pty1<height;pty1++){ 
        bool hasPoint = false;
        for(x=0;x<width;x++){    
            NSInteger pixelIndex = (bytesPerRow * pty1) + x * bytesPerPixel;
            unsigned char alpha = rawData[pixelIndex + 3];
            if(alpha > 0){
                //printf("point x %d alpha %d\n ",x,alpha);
                hasPoint = true;
                break;
            }
        } 
        if(hasPoint==true){
            //printf("point y %d\n ",pty1);
            break;
        }
    }
    NSInteger pty2;
    for(pty2=height-1;pty2>0;pty2--){ 
        bool hasPoint = false;
        for(x=0;x<width;x++){    
            NSInteger pixelIndex = (bytesPerRow * pty2) + x * bytesPerPixel;
            unsigned char alpha = rawData[pixelIndex + 3];
            if(alpha > 0){
                hasPoint = true;
                break;
                
            }
        } 
        if(hasPoint==true){
            //printf("point y %d\n ",pty2-pty1);
            break;
        }
    }
    free(rawData);
    //printf("\n raw data freed");
    return CGRectMake(0,pty1,0,pty2-pty1);
}

-(void)setShapeSelection{
//    int tag[] = {0,0,kRect,kCircle,0,0,kTriangle,0,k5Star,kPentagon,kHexogon};
//    int filledtag[] = {0,0,kFilledRect,kFilledCircle,0,0,kFilledTriangle,0,kFilled5Star,kFilledPentagon,kFilledHexogon};
//   
//  
//    if(drawingMode != 1 && drawingMode != 4 && drawingMode != 11){
//        if(drawFilledorOpenedShape==0){
//            int tagValue = tag[drawingMode];
//            [(UIButton*)[paintControlView.shapeToolView viewWithTag:tagValue] setSelected:YES];
//        }else{
//            //printf("\n drawing mode %d",drawingMode);
//            int tagValue = filledtag[drawingMode];
//            [(UIButton*)[paintControlView.shapeToolView viewWithTag:tagValue] setSelected:YES];
//        }
//    }
}


#pragma -
#pragma ColorPaletteDelegate Method
- (void) setDrawingColor:(UIColor*)color{
    if(drawColor){
        drawColor = nil;
    }
    drawColor = color;
//    [self setDrawColor:color];
}

- (void) setFillColor:(UIColor*)color{
    fillColor = color;
}

//- (void) drawString: (NSString*)textString withFont:(UIFont*)font inRect:(CGRect)contextRect {
//    
//    
//    [textString drawAtPoint:CGPointMake(100, 100) withFont:[UIFont fontWithName:@"Helvetica-Bold" size:12]];
//}
-(void) changeScrollViewZoomingState
{
//    NSLog(@"scroll view zoooming state updated");
//    UIScrollView *scrollView = (UIScrollView *)[drawingViewController.view viewWithTag:312];
//    if(canDraw == false)
//    {
//        scrollView.scrollEnabled = YES;
//        scrollView.pinchGestureRecognizer.enabled = YES;
//    }
//    else{
//        scrollView.scrollEnabled = NO;
//        scrollView.pinchGestureRecognizer.enabled = NO;
//    }
}
-(void)setEditor:(id)sender withDrawingView:(id)drawingView{
//    editorViewController = (EditorViewController*)sender;
//    drawingViewController = (DrawingViewController*) drawingView;
//
//    UIView *Partview;
//    for (UIView *view in [editorViewController.slideView subviews]) {
//        
//        Partview                        = [[UIView alloc] initWithFrame:CGRectMake(view.frame.origin.x,view.frame.origin.y,view.frame.size.width,view.frame.size.height)];
//        Partview.backgroundColor        = [UIColor blackColor];
//        [Partview setAlpha:0.5];
//        Partview.layer.borderWidth      = kWidth;
//        Partview.layer.borderColor      = normalColor;
//        Partview.clipsToBounds          = YES;
//        Partview.userInteractionEnabled =NO;
//        [self addSubview:Partview];
//        
//        if (editorViewController.slideView.selectedView.tag==view.tag) {
//            
//            Partview.layer.borderWidth      = kWidth;
//            Partview.layer.borderColor      = selectionColor;
//            drawX                           =Partview.frame.origin.x;
//            drawY                           =Partview.frame.origin.y;
//            drawWidth                       =Partview.frame.size.width;
//            drawHeight                      =Partview.frame.size.height;
//            Partview.userInteractionEnabled =YES;
//            [Partview removeFromSuperview];
////            [Partview release];
//            Partview                        = nil;
//        }
////        [Partview release];
//        Partview = nil;
//        
//    }
//    
//    
//    [editorViewController.slideView resetSubViews:nil];
//    
//    
//    x1                  = kAppWidth;
//    y1                  = kAppHeight;
//    x2                  = 0;
//    y2                  = 0;
//    
//    istouch             =   NO;
//    
//    pencillineWidth     =   5.0;
//    strightlineWidth    =   3.0;
//    eraserlineWidth     = 10.0;
//    
//    currentRect         = CGRectMake(drawX, drawY, drawWidth, drawHeight);
//    
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    if([defaults integerForKey:@"drawingMode"]){
//        drawingMode     = [defaults integerForKey:@"drawingMode"];
//    }else{
//        [defaults       setInteger:drawingMode forKey:@"drawingMode"];
//    }
//    
//    if([defaults        integerForKey:@"drawFilledorOpenedShape"]){
//        drawFilledorOpenedShape = [defaults integerForKey:@"drawFilledorOpenedShape"];
//    }else{
//        [defaults       setInteger:drawFilledorOpenedShape forKey:@"drawFilledorOpenedShape"];
//    }
//    [defaults       synchronize];
//    
//    // Add PaintControlView
////    paintControlView    = [[PaintControlView alloc] initWithFrame:CGRectMake(0,-(kControlHeight),1024,kControlHeight)];
////    paintControlView.delegate = self;
//    
////    [self addSubview:paintControlView];
//    // paintControlView.alpha      =   0.0;
//    
////    [UIView beginAnimations:nil context:nil];
////    [UIView setAnimationDuration:0.3];
////    paintControlView.frame = CGRectMake(0,0,1024,kControlHeight-5);
////    [UIView commitAnimations];
//    
//    
//    [(UIButton*)[paintControlView viewWithTag:kUndo] setEnabled:NO];
//    [(UIButton*)[paintControlView viewWithTag:kRedo] setEnabled:NO];
//    [paintControlView setEnabled:NO ForButtonTag:kClear];
//    
//    [(UIButton*)[paintControlView viewWithTag:kPencil] setSelected:NO];
//    if(drawingMode == 1){
//        paintControlView.paintToolIndex = kPencil;
//    }else if(drawingMode == 11){
//        paintControlView.paintToolIndex = kline;
//    }else if(drawingMode == 4){
//        paintControlView.paintToolIndex = kEraser;
//    }else if(drawingMode >= 2 && drawingMode <= 10 ){
//        paintControlView.paintToolIndex = kShapes;
//    }
//    [(UIButton*)[paintControlView viewWithTag:paintControlView.paintToolIndex] setSelected:YES];
//    
//    //for remember the defult color and thicness.....
//    if([defaults boolForKey:@"paint-settings"]){
//        [self performSelector:@selector(setDrawingColor:) withObject:[paintControlView.lastColorsArray objectAtIndex:3] ];
//        
//        pencillineWidth = [defaults integerForKey:@"paint-pencil"];
//        strightlineWidth = [defaults integerForKey:@"paint-line"];
//        eraserlineWidth = [defaults integerForKey:@"paint-eraser"];
//        
//    }else{
//        //[paintControlView.lastColorsArray replaceObjectAtIndex:3 withObject:[UIColor blackColor]];
//        
//        NSMutableData *data = [[NSMutableData alloc] init];
//        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
//        [archiver encodeObject:paintControlView.lastColorsArray forKey:@"paintstoredcolors"];
//        [archiver finishEncoding];
//        [data writeToFile:[Utils dataFilePath:@"paintstoredcolors"] atomically:NO];
////        [data release];
////        [archiver release];
//        
//        [defaults setInteger:pencillineWidth forKey:@"paint-pencil"];
//        [defaults setInteger:strightlineWidth forKey:@"paint-line"];
//        [defaults setInteger:eraserlineWidth forKey:@"paint-eraser"];
//        
//    }
//    
//    [defaults setBool:YES forKey:@"paint-settings"];
//    [defaults synchronize];
//    [paintControlView setLastUsedColor];
    
    canDraw = true;
    [self performSelector:@selector(changeScrollViewZoomingState) withObject:nil afterDelay:0.1];
    
}

@end
