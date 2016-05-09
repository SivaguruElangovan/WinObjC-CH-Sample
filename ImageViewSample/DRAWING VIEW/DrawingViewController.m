//
//  DrawingViewController.m
//  ComicsHeadPro
//
//  Created by Nextwave Multimedia on 2/5/15.
//  Copyright (c) 2015 mac4. All rights reserved.
//

#import "DrawingViewController.h"
//#import "EditorViewController.h"
//#define kControlHeight      72



@interface DrawingViewController ()
//@property (strong,nonatomic) EditorViewController *editorViewController;
@property BOOL isZooming;
@end

@implementation DrawingViewController
@synthesize paintView;
//@synthesize paintControlView;
//@synthesize editorViewController;
@synthesize zoomView;
@synthesize backgroundImage;
@synthesize isZooming;
@synthesize scrollView;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.view.frame = CGRectMake(0, 0, kAppWidth, kAppHeight);
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kAppWidth, kAppHeight)];
    scrollView.minimumZoomScale = 1.0;
    scrollView.maximumZoomScale = 5.0;
    scrollView.zoomScale = 1.0;
    scrollView.delegate = self;
    scrollView.scrollEnabled = NO;
    scrollView.pinchGestureRecognizer.enabled = NO;
    //    scrollView.scrollIndicatorInsets
    scrollView.tag = 312;
    [self.view addSubview:scrollView];
    
    [self setEditor:nil];
    
//    [self showTutorial];
//    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:<#(nullable id)#> action:<#(nullable SEL)#>];
}
-(void) showTutorial
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    BOOL shownTutorial = [standardUserDefaults boolForKey:@"PaintTutorial"];
    
    if(shownTutorial == false)
    {
//        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
//        view.tag = 9873;
//        [self.view addSubview:view];
//        
//        UIView *transView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
//        transView.backgroundColor = [UIColor blackColor];
//        transView.alpha = 0.7;
//        [view addSubview:transView];
        
//        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 500, 100)];
//        label.text = @"pinch to zoom and use two fingers to move.";
//        label.center = CGPointMake(1024 / 2, 768 / 2);
//        label.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
//        label.textColor = [UIColor whiteColor];
//        label.textAlignment = NSTextAlignmentCenter;
//        label.font = [UIFont fontWithName:@"Comics" size:18];
//        label.tag = 9873;
//        [self.view addSubview:label];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kAppWidth, kAppHeight)];
        view.tag = 897;
        [self.view addSubview:view];
        
        UIView *transView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kAppWidth, kAppHeight)];
        transView.backgroundColor = [UIColor blackColor];
        transView.alpha = 0.6;
        [view addSubview:transView];
        
        UIImage *image = [UIImage imageNamed:@"paint_tutorial"];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,kAppWidth,kAppHeight)];
        imageView.image = image;
		imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.center = CGPointMake(kAppWidth / 2, kAppHeight / 2);
        [view addSubview:imageView];
        
        UIButton  *okButton = [[UIButton alloc] initWithFrame:CGRectMake(0, imageView.frame.origin.y + image.size.height - 40 - 30, 80, 30)];
        [okButton setTitle:@"ok" forState:UIControlStateNormal];
        [okButton setTitle:@"ok" forState:UIControlStateHighlighted];
        [okButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        [okButton setBackgroundColor:[UIColor blueColor]];
        okButton.titleLabel.font = [UIFont fontWithName:@"Comics" size:18];
        okButton.center = CGPointMake(kAppWidth / 2, okButton.center.y);
//        [okButton addTarget:self action:@selector(okButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [okButton addTarget:self action:@selector(okButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:okButton];
        
        paintView.canDraw = false;
//        [standardUserDefaults setBool:YES forKey:@"PaintTutorial"];
    }
}
-(void) okButtonClicked:(id) sender
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    UIView *view = (UIView *)[self.view viewWithTag:897];
    [view removeFromSuperview];
    paintView.canDraw = true;
    [standardUserDefaults setBool:YES forKey:@"PaintTutorial"];
}
//-(void) pinchRecognizerCalled
//{
//    
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//    UILabel *label = (UILabel *)[self.view viewWithTag:9873];
//    if(label != nil)
//    [label removeFromSuperview];
//}
-(UIView*) viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    //UIView *zoomView = []
    // bg view
    //add paintView
    NSLog(@"view for zooming view method called %ld",(long) paintView.pathArray.count);
//    if(paintView.canDraw == false)
//    {

    paintView.canDraw = false;
        return zoomView;//self.paintView;
//    }
//    else{
//        scrollView.pinchGestureRecognizer.enabled = NO;
//        return nil;
//    }
}


- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    printf("\n Scroll Ended");
//    [paintView renderAllBezierLines];
    paintView.canDraw = true;
    isZooming = false;
}
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view
{
    paintView.canDraw = false;
}

-(void) setEditor:(id)sender
{
//    editorViewController = (EditorViewController*) sender;
    
    
    
    
    zoomView = [[UIView alloc] initWithFrame:scrollView.frame];
    [scrollView addSubview:zoomView];
    
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
    [zoomView addSubview:backgroundImageView];
    
    
    paintView = [[DrawingView alloc] initWithFrame:zoomView.frame];
    paintView.backgroundColor = [UIColor clearColor];
    
    NSString *fileLocation = [[NSBundle mainBundle] pathForResource:@"10-%-black" ofType:@"png"];
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:fileLocation];
    UIImageView *paintViewBg = [[UIImageView alloc] initWithImage:image];
	paintViewBg.frame = CGRectMake(0,0,kAppWidth,kAppHeight);
	paintViewBg.contentMode = UIViewContentModeScaleAspectFill;
    [zoomView addSubview:paintViewBg];
    
    [zoomView addSubview:paintView];
    
    
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         //                         topControlView.frame = CGRectMake(0,-120,1024,kControlHeight);
                         
                         [paintView setAlpha:1.0];
                     }
                     completion:nil];
    //    popViewIndex = kPaint;
    //    self.showSettingsView = false;
    scrollView.contentSize = paintView.frame.size;
    
//    paintControlView    = [[PaintControlView alloc] initWithFrame:CGRectMake(0,0,kAppWidth,kControlHeight)];
//    paintControlView.delegate = paintView;
//    [self.view addSubview:paintControlView];
    
    
    
//    paintView.paintControlView = paintControlView;
//    [paintView setEditor:editorViewController withDrawingView:self];
    isZooming = false;
    
    [self showTutorial];

}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}


@end
