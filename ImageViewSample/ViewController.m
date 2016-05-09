//
//  ViewController.m
//  ImageViewSample
//
//  Created by Sivaguru on 4/13/16.
//  Copyright © 2016 Nextwave Multimedia. All rights reserved.
//

#import "ViewController.h"
#import "DrawingViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
//#import <Photos/Photos.h>


@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIButton *colorButton;
@property (strong, nonatomic) IBOutlet UIButton *imageButton;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"app width %d and app height %d",kAppWidth,kAppHeight);
    
    //[self.colorButton addTarget:self action:@selector(changeColor) forControlEvents:UIControlEventTouchUpInside];
    [self.imageButton addTarget:self action:@selector(saveAsImage) forControlEvents:UIControlEventTouchUpInside];

    //self.colorButton.frame = CGRectMake(10, kAppHeight - 50, self.colorButton.frame.size.width, self.colorButton.frame.size.height);
    self.imageButton.frame = CGRectMake(10, kAppHeight - 100, self.imageButton.frame.size.width, self.imageButton.frame.size.height);
    
    self.imageView.frame = CGRectMake(10 * kWidthRatio, 10 * kHeightRatio, _imageView.frame.size.width * kWidthRatio, _imageView.frame.size.height * kHeightRatio);
    
    self.imageView.backgroundColor = [UIColor grayColor];
    self.imageView.layer.borderColor = [UIColor blackColor].CGColor;
    self.imageView.layer.borderWidth = 10.0;
    
}
-(void) changeColor
{
    reloadMode = reloadMode == 1 ? 0 : 1;
    _imageView.backgroundColor = (reloadMode == 1 ? [UIColor redColor] : [UIColor blueColor]);
}
-(void) saveAsImage
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, [UIScreen mainScreen].scale);
    } else {
        UIGraphicsBeginImageContext(self.view.bounds.size);
    }
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [[UIColor blackColor] set];
    CGContextFillRect(ctx, screenRect);
    
    // grab reference to our window
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    // transfer content into our context
    [window.layer renderInContext:ctx];
    UIImage *screengrab = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self setupPhotoAlbumNamed:@"Sample" withCompletionHandler:
     ^(ALAssetsLibrary *assetsLibrary, ALAssetsGroup *group) {
         if (group)
         {
             [self addImage:screengrab toAssetsLibrary:assetsLibrary withGroup:group];
         }
     }];
    
//    [self saveImage:screengrab toPhotoAlbum:@"Sivaguru"];
//    [self saveImage:screengrab toAlbum:@"Sample"];
//    [self insertImage:screengrab intoAlbumNamed:@"My Album"];
//    [self savePhotoToAlbum:screengrab];
//    _imageView.backgroundColor = [UIColor colorWithPatternImage:screengrab];
}

- (void) setupPhotoAlbumNamed: (NSString*) photoAlbumName withCompletionHandler:(void(^)(ALAssetsLibrary*, ALAssetsGroup*))completion
{
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    __weak ALAssetsLibrary *weakAssetsLibrary = assetsLibrary;
    [assetsLibrary addAssetsGroupAlbumWithName:photoAlbumName resultBlock:^(ALAssetsGroup *group)
     {
         NSLog(@"%@ Album result: %@", self, (group.editable ? @"success" : @"already existed"));
         if (!group)
         {
             [weakAssetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *g, BOOL *stop) {
                 if ([[g valueForProperty:ALAssetsGroupPropertyName] isEqualToString:photoAlbumName])
                 {
                     completion(weakAssetsLibrary, g);
                 }
             } failureBlock:^(NSError *error) {
                 NSLog(@"%@ An error has occured with description: %@", self, error.localizedDescription);
                 completion(weakAssetsLibrary, nil);
             }];
         }
         else
         {
             completion(weakAssetsLibrary, group);
         }
     } failureBlock:^(NSError *error)
     {
         NSLog(@"%@ An error has occured with description: %@", self, error.localizedDescription);
         completion(weakAssetsLibrary, nil);
     }];
}

- (void) addImage: (UIImage*) image toAssetsLibrary: (ALAssetsLibrary*) assetsLibrary withGroup: (ALAssetsGroup*) group
{
    [assetsLibrary writeImageDataToSavedPhotosAlbum:UIImagePNGRepresentation(image) metadata:nil
                                    completionBlock:
     ^(NSURL *assetURL, NSError *error)
     {
         if (error)
         {
             NSLog(@"%@ An error has occured with description: %@", self, error.localizedDescription);
         }
         else
         {
             [assetsLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset)
              {
                  [group addAsset:asset];
                  NSLog(@"%@ Image was succesfully added!", self);
              } failureBlock:^(NSError *error) {
                  NSLog(@"%@ An error has occured with description: %@", self, error.localizedDescription);
              }];
         }
     }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
