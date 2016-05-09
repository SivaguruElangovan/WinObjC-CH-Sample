//
//  AppDelegate.m
//  ImageViewSample
//
//  Created by Sivaguru on 4/13/16.
//  Copyright © 2016 Nextwave Multimedia. All rights reserved.
//

#import "AppDelegate.h"


@implementation UIApplication (UIApplicationInitialStartupMode)
+ (void)setStartupDisplayMode:(WOCDisplayMode*)mode {
    mode.autoMagnification = TRUE;
    mode.sizeUIWindowToFit = TRUE;
    mode.clampScaleToClosestExpected = FALSE;
    mode.fixedWidth = 0;
    mode.fixedHeight = 0;
    mode.magnification = 1.0;
	mode.presentationTransform = UIInterfaceOrientationLandscapeLeft;
}
@end

@interface AppDelegate ()

@end



@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
/*
    // Override point for customization after application launch.
    [self registerForUserNotifications];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int notificationTimeInterval = 60 * 60 * 24 * 7;
    //    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    for(int time = notificationTimeInterval; time <  notificationTimeInterval * 10; time += notificationTimeInterval)
        //        for(int time = 600; time<6000; time+=600)
    {

        NSLog(@"time in seconds %d",time);
        UILocalNotification *beginNotification = [[UILocalNotification alloc] init];//[[[UILocalNotification alloc] init] autorelease];
        if (beginNotification) {
            beginNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:(time)];    // 7 days 60*60*24*7 = 604800//604800
            beginNotification.timeZone = [NSTimeZone defaultTimeZone];
//            beginNotification.repeatInterval = NSCalendarUnitTimeZone;
            beginNotification.alertAction = @"Local notification";
            
            int random = arc4random() % 5;
            NSArray *alertText = [NSArray arrayWithObjects:NSLocalizedString(@"We miss your awesomeness. Show us some love and create with Comics Head!",nil),
                                  NSLocalizedString(@"Click pictures and make an awesome photo comic with Comics Head!",nil),
                                  NSLocalizedString(@"Knock knock! Comics Head here. Go create a comic today!",nil),
                                  NSLocalizedString(@"How about telling a story today using Comics Head?!",nil),
                                  NSLocalizedString(@"Explore the endless story telling possibilities with Comics Head!",nil),
                                  nil];
            
            if([defaults objectForKey:@"notifcation-index"]==nil)
                [defaults setInteger:0 forKey:@"notifcation-index"];
            random = ([[defaults objectForKey:@"notifcation-index"] integerValue]  + 1) % 5;
            [defaults setInteger:random forKey:@"notifcation-index"];
            
            beginNotification.alertBody = alertText[random];
            
            beginNotification.applicationIconBadgeNumber = 1;
            beginNotification.soundName = UILocalNotificationDefaultSoundName;
            // this will schedule the notification to fire at the fire date
            //[app scheduleLocalNotification:notification];
            // this will fire the notification right away, it will still also fire at the date we set
            [application scheduleLocalNotification:beginNotification];
        }
    }
    */
    return YES;
}
-(void) registerForUserNotifications
{
    UIMutableUserNotificationAction *readAction = [UIMutableUserNotificationAction new];
    readAction.identifier = @"READ_IDENTIFIER";
    readAction.title = @"Read";
    readAction.activationMode = UIUserNotificationActivationModeForeground;
    readAction.destructive = NO;
    readAction.authenticationRequired = YES;
    
    UIMutableUserNotificationAction *deleteAction = [UIMutableUserNotificationAction new];
    deleteAction.identifier = @"DELETE_IDENTIFIER";
    deleteAction.title = @"Delete";
    deleteAction.activationMode = UIUserNotificationActivationModeForeground;
    deleteAction.destructive = YES;
    deleteAction.authenticationRequired = YES;
    
    UIMutableUserNotificationAction *ignoreAction = [UIMutableUserNotificationAction new];
    ignoreAction.identifier = @"IGNORE_IDENTIFIER";
    ignoreAction.title = @"Ignore";
    ignoreAction.activationMode = UIUserNotificationActivationModeForeground;
    ignoreAction.destructive = NO;
    ignoreAction.authenticationRequired = NO;
    
    UIMutableUserNotificationCategory *messageCategory = [UIMutableUserNotificationCategory new];
    messageCategory.identifier = @"MESSAGE_CATEGORY";
    [messageCategory setActions:@[readAction, deleteAction] forContext:UIUserNotificationActionContextMinimal];
    [messageCategory setActions:@[readAction, deleteAction, ignoreAction] forContext:UIUserNotificationActionContextDefault];
    
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:types categories:[NSSet setWithArray:@[messageCategory]]];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
