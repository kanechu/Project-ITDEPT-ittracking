//
//  AppDelegate.m
//  worldtrans
//
//  Created by itdept on 2/11/14.
//  Copyright (c) 2014 itdept. All rights reserved.
//

#import "AppDelegate.h"
#import <RestKit/RestKit.h>
#import "Web_get_alert.h"
#import "DB_login.h"
#import "DB_alert.h"
#import "Reachability.h"
@implementation AppDelegate

@synthesize is_device_token;
-(void)fn_reachabilityChanged:(NSNotification*)note{
    Reachability *curReach=[note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    NetworkStatus status=[curReach currentReachabilityStatus];
    if (status==NotReachable) {
        NSString *str_alert=@"Unable to connect to the network, you must connect Wi-Fi network or mobile data network to access ITTracking.";
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"ITTracking" message:str_alert delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Override point for customization after application launch.
    //監測網絡情況
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(fn_reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    hostReach=[Reachability reachabilityForInternetConnection];
    [hostReach startNotifier];
    
    NSLog(@"Registering for push notifications...");
    if ([[[UIDevice currentDevice]systemVersion]floatValue]<8.0) {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge)];
    }else{
        UIUserNotificationSettings *setting=[UIUserNotificationSettings settingsForTypes:( UIUserNotificationTypeBadge|UIUserNotificationTypeSound |UIUserNotificationTypeAlert) categories:nil];
        [application registerUserNotificationSettings:setting];
        [application registerForRemoteNotifications];
    }
    
    return YES;
    
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    is_device_token = [[deviceToken description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    is_device_token = [is_device_token stringByReplacingOccurrencesOfString:@" " withString:@""];
    
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    
    NSLog(@"Error %@",[NSString stringWithFormat: @"Error: %@", err]);
    is_device_token = @"dev-ser";
    
}

							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive)
    {
        //background task here
        Web_get_alert *web_get_alert = [[Web_get_alert alloc] init];
        web_get_alert.callBack=^(NSMutableArray* alist_result,BOOL isTimeOut){
            DB_alert * ldb_alert = [[DB_alert alloc] init];
            [ldb_alert fn_save_data:alist_result];
        };
        [web_get_alert fn_get_data];
    }
    else {
        // Push Notification received in the background
    }
}

- (void) fn_save_alert_list: (NSMutableArray *) alist_alert {
    DB_alert * ldb_alert = [[DB_alert alloc] init];
    [ldb_alert fn_save_data:alist_alert];
}
//禁止横屏
-(NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
    return UIInterfaceOrientationMaskPortrait;
}

@end
