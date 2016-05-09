//
//  DrawingViewController.h
//  ComicsHeadPro
//
//  Created by Nextwave Multimedia on 2/5/15.
//  Copyright (c) 2015 mac4. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrawingView.h"
//#import "PaintControlView.h"

//#define kAppWidth           [UIScreen mainScreen].bounds.size.width
//#define kAppHeight          [UIScreen mainScreen].bounds.size.height


//#define kAppWidth           [UIScreen mainScreen].applicationFrame.size.width
//#define kAppHeight          [UIScreen mainScreen].applicationFrame.size.height

#define	kAppRect			[DrawingView getScreenFrameForOrientation]


#define kAppWidth           kAppRect.size.width
#define kAppHeight          kAppRect.size.height


#define kStdWidth   1024
#define kStdHeight  768

#define kWidthRatio         kAppWidth / kStdWidth
#define kHeightRatio        kAppHeight / kStdHeight

@interface DrawingViewController : UIViewController<UIScrollViewDelegate>//,PaintControlViewDelegate>
-(void)setEditor:(id)sender;
@property (strong,nonatomic) UIScrollView *scrollView;
@property (strong,nonatomic) DrawingView *paintView;
//@property (strong,nonatomic) PaintControlView *paintControlView;
@property (strong,nonatomic) UIView *zoomView;
@property (strong,nonatomic) UIImage *backgroundImage;
@end
