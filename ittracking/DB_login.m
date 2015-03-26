//
//  DB_login.m
//  worldtrans
//
//  Created by itdept on 14-3-20.
//  Copyright (c) 2014年 itdept. All rights reserved.
//

#import "DB_login.h"
#import "DatabaseQueue.h"
#import "NSDictionary.h"
#import "FMDatabaseAdditions.h"
#import "AppDelegate.h"
#import "DB_device.h"
#import "AppConstants.h"
#import "Resp_app_config.h"

@implementation DB_login

@synthesize queue;

-(id) init {
    queue = [DatabaseQueue fn_sharedInstance];
    return self;
}

- (BOOL) fn_save_data:(NSString*)user_ID password:(NSString*)user_pass system:(NSString*)sys_name logo:(NSString*)user_logo
{
    // get current date/time
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // display in 12HR/24HR (i.e. 11:25PM or 23:25) format according to User Settings
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *ls_currentTime = [dateFormatter stringFromDate:today];
    __block BOOL ib_updated=NO;
    [queue inDataBase:^(FMDatabase *db){
        if ([db open]) {
            NSString *insertSQL = [NSString stringWithFormat:@"insert into loginInfo (user_code,password,sys_name,login_time,user_logo) values (\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")", user_ID,user_pass,sys_name,ls_currentTime,user_logo];
            ib_updated =[db executeUpdate:insertSQL];
            [db close];
        }
    }];
    return ib_updated;
}

-(BOOL)fn_delete_record{
    __block BOOL ib_deleted=NO;
    [queue inDataBase:^(FMDatabase* db){
        if ([db open]) {
            NSString *delete = [NSString stringWithFormat:@"delete from loginInfo"];
            ib_deleted =[db executeUpdate:delete];
            
            [db close];
        }
    }];
    return ib_deleted;
}
- (NSMutableArray *) fn_get_all_msg
{
    __block NSMutableArray *llist_results = [NSMutableArray array];
    [queue inDataBase:^(FMDatabase *db){
        if ([db open]) {
            
            FMResultSet *lfmdb_result = [db executeQuery:@"SELECT * FROM loginInfo"];
            while ([lfmdb_result next]) {
                [llist_results addObject:[lfmdb_result resultDictionary]];
            }
            [db close];
        }
        
    }];
    return llist_results;
}
-(BOOL)isLoginSuccess{
    __block NSInteger li_count=0;
    [queue inDataBase:^(FMDatabase *db){
        if ([db open]) {
            li_count = [db intForQuery:@"SELECT COUNT(*) FROM loginInfo"];
            [db close];
        }
    }];
    if (li_count==0) {
        return NO;
    }else{
        return YES;
    }
}
-(AuthContract*)WayOfAuthorization{
    AuthContract *auth=[[AuthContract alloc]init];
    NSString * ls_device_token = [(AppDelegate *)[[UIApplication sharedApplication] delegate] is_device_token];
    DB_device *device=[[DB_device alloc]init];
    if (ls_device_token==nil) {
        [device fn_save_data:@"dev-simulator"];
        ls_device_token=@"dev-simulator";
    }else{
        [device fn_save_data:ls_device_token];
    }
    NSMutableArray *userInfo=[self fn_get_all_msg];
    if ([userInfo count]!=0) {
        NSMutableDictionary *dic_userInfo=[userInfo firstObject];
        auth.user_code =[dic_userInfo valueForKey:@"user_code"];
        auth.password = [dic_userInfo valueForKey:@"password"];
        
        auth.system=[dic_userInfo valueForKey:@"sys_name"];
        /**
         *  encrypted 如果为1，密码需要AES128加密，并base64 encode
         */
        auth.encrypted=IS_ENCRYPTED;
        auth.device_id = ls_device_token;
    }
    return auth;
}
#pragma mark -app config
- (BOOL)fn_save_app_config_data:(NSMutableArray*)alist_appConfig{
    __block BOOL ib_updated=NO;
    [queue inDataBase:^(FMDatabase *db){
        if ([db open]) {
            for (Resp_app_config *lmap_data in alist_appConfig) {
                NSMutableDictionary *ldict_row=[[NSDictionary dictionaryWithPropertiesOfObject:lmap_data]mutableCopy];
                ib_updated =[db executeUpdate:@"delete from app_config where company_code = :company_code and sys_name = :sys_name and env = :env and web_addr =:web_addr and php_addr =:php_addr" withParameterDictionary:ldict_row];
                
                ib_updated =[db executeUpdate:@"insert into app_config (company_code, sys_name, env, web_addr,php_addr) values (:company_code, :sys_name, :env, :web_addr,:php_addr)" withParameterDictionary:ldict_row];
            }
            [db close];
        }
    }];
    return ib_updated;
}
-(NSMutableArray*)fn_get_all_appConfig_data{
    __block NSMutableArray *llist_result=[NSMutableArray array];
    [queue inDataBase:^(FMDatabase *db){
        if ([db open]) {
            FMResultSet *lfmdb_result=[db executeQuery:@"SELECT * FROM app_config"];
            while ([lfmdb_result next]) {
                [llist_result addObject:[lfmdb_result resultDictionary]];
            }
            [db close];
        }
    }];
    
    return llist_result;
}
-(BOOL)fn_delete_all_appConfig_data{
    __block BOOL ib_deleted=NO;
    [queue inDataBase:^(FMDatabase *db){
        if ([db open]) {
            ib_deleted=[db executeUpdate:@"delete from app_config"];
            [db close];
        }
    }];
    return ib_deleted;
}
-(NSString*)fn_get_field_content:(kAppConfig_field)field_name{
    NSMutableArray *alist_appconfig=[self fn_get_all_appConfig_data];
    NSString *str_field_content;
    NSString *str_key;
    if (field_name==kWeb_addr) {
        str_key=@"web_addr";
    }else if (field_name==kPhp_addr){
        str_key=@"php_addr";
    }else if (field_name==kCompany_code){
        str_key=@"company_code";
    }else if (field_name==kSys_name){
        str_key=@"sys_name";
    }
    if ([alist_appconfig count]!=0) {
        str_field_content=[[alist_appconfig objectAtIndex:0]valueForKey:str_key];
        str_field_content=[str_field_content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    str_key=nil;
    alist_appconfig=nil;
    return str_field_content;
}

@end
