//
//  AppConstants.h
//  worldtrans
//
//  Created by itdept on 2/27/14.
//  Copyright (c) 2014 itdept. All rights reserved.
//

#import <Foundation/Foundation.h>
#define DEFAULT_APP_CODE @"MOB_ITTRACK"  
#define ITTRACKING_VERSION [[[NSBundle mainBundle]infoDictionary]valueForKey:@"CFBundleShortVersionString"]!=nil ? [[[NSBundle mainBundle]infoDictionary]valueForKey:@"CFBundleShortVersionString"] : @"1.0"
#define IS_ENCRYPTED @"0"
@interface AppConstants : NSObject

extern NSString* const STR_BASE_URL;
extern NSString* const STR_CONFIG_URL;
extern NSString* const STR_LOGIN_URL;
extern NSString* const STR_SYPARA_URL;
extern NSString* const STR_PERMIT_URL;
extern NSString* const STR_MILESTONE_IMAGE_URL;
extern NSString* const STR_SEA_URL;
extern NSString* const STR_AIR_URL;
extern NSString* const STR_ALERT_URL;
extern NSString* const STR_MILESTONE_URL;
extern NSString* const STR_SCHEDULE_URL;
extern NSString* const STR_PORTNAME_URL;
extern NSString* const STR_SEARCHCRITERIA_URL;
extern NSString* const STR_ICON_URL;
extern NSString* const STR_EXCNTR_STATUS_URL;

@end
