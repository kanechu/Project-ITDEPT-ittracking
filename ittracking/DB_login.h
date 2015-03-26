//
//  DB_login.h
//  worldtrans
//
//  Created by itdept on 14-3-20.
//  Copyright (c) 2014年 itdept. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DatabaseQueue.h"
#import "AuthContract.h"
typedef NS_ENUM(NSInteger, kAppConfig_field){
    kWeb_addr,
    kCompany_code,
    kPhp_addr,
    kSys_name
};
@interface DB_login : NSObject
{
    DatabaseQueue *quque;
}
@property(nonatomic,strong) DatabaseQueue *queue;

- (BOOL) fn_save_data:(NSString*)user_ID password:(NSString*)user_pass system:(NSString*)sys_name logo:(NSString*)user_logo ;

- (NSMutableArray *) fn_get_all_msg;

-(BOOL)fn_delete_record;
-(BOOL)isLoginSuccess;
-(AuthContract*)WayOfAuthorization;

#pragma mark -app config
- (BOOL)fn_save_app_config_data:(NSMutableArray*)alist_appConfig;
-(NSMutableArray*)fn_get_all_appConfig_data;
-(BOOL)fn_delete_all_appConfig_data;
-(NSString*)fn_get_field_content:(kAppConfig_field)field_name;

@end
