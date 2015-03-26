//
//  Web_get_permit.m
//  itleo
//
//  Created by itdept on 14-11-3.
//  Copyright (c) 2014年 itdept. All rights reserved.
//

#import "Web_get_permit.h"
#import "Web_base.h"
#import "Resp_permit.h"
#import "DB_permit.h"
#import "DB_login.h"
#import "Common_methods.h"

@implementation Web_get_permit

-(void)fn_get_permit_data:(NSString*)base_url callBack:(call_isGetPermit)call_back{
    RequestContract *ao_form=[[RequestContract alloc]init];
    AuthContract *auth=[[AuthContract alloc]init];
#warning -neet to mofify
    auth.system=@"ITNEW";//备注，这里先写死，日后记住改过来
    auth.app_code=DEFAULT_APP_CODE;
    base_url=@"http://192.168.1.17/kie_web_api/";//这里也先写死，日后记住改过来
    ao_form.Auth=auth;
    SearchFormContract *searchform=[[SearchFormContract alloc]init];
    searchform.os_column=@"type";
    searchform.os_value=@"ALL";
    ao_form.SearchForm=[NSSet setWithObject:searchform];
    Web_base *web_base=[[Web_base alloc]init];
    web_base.il_url=STR_PERMIT_URL;
    web_base.iresp_class=[Resp_permit class];
    web_base.ilist_resp_mapping=[NSArray arrayWithPropertiesOfObject:[Resp_permit class]];
    web_base.callBack=^(NSMutableArray *alist_arr,BOOL isTimeOut){
        DB_permit *db_permit=[[DB_permit alloc]init];
        [db_permit fn_save_permit_data:alist_arr];
        if (call_back) {
            call_back(YES);
        }
    };
    [web_base fn_get_data:ao_form];
}
-(NSMutableArray*)fn_get_function_module{
    DB_permit *db_permit=[[DB_permit alloc]init];
    NSMutableArray *alist_result=[db_permit fn_get_permit_data];
    NSMutableArray *alist_function=[[NSMutableArray alloc]initWithCapacity:1];
    for (NSMutableDictionary *dic in alist_result) {
        NSMutableDictionary *idic_result=[[NSMutableDictionary alloc]initWithCapacity:1];
        NSString *module_unique_i=[Common_methods fn_cut_whitespace:[dic valueForKey:@"module_unique_id"]] ;
        NSString *module_code=[Common_methods fn_cut_whitespace:[dic valueForKey:@"module_code"]];
        if ([module_unique_i isEqualToString:@"SYS"]==NO) {
            NSString *f_exec=[dic valueForKey:@"f_exec"];
            [idic_result setObject:module_code forKey:@"module_code"];
            [idic_result setObject:f_exec forKey:@"f_exec"];
            [alist_function addObject:idic_result];
        }
    }
    return alist_function;
}
@end
