//
//  ViewController.m
//  ImageViewSample
//
//  Created by Sivaguru on 4/13/16.
//  Copyright © 2016 Nextwave Multimedia. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	UIView *view = [[UIView alloc] initWithFrame:self.view.frame];
	view.backgroundColor = [UIColor grayColor];
	view.layer.borderColor = [UIColor blackColor].CGColor;
	view.layer.borderWidth = 10.0;
	view.clipsToBounds = YES;
	[self.view addSubview:view];

	/*    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1280, 768)];
    CGRect frame = self.view.frame;
    imageView.image = [UIImage imageNamed:@"images_1.jpg"];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.backgroundColor = [UIColor blueColor];
	imageView.frame = frame;
    [self.view addSubview:imageView];
	*/
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
