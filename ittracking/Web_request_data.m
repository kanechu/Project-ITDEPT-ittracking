//
//  Web_request_data.m
//  ittracking
//
//  Created by itdept on 15/3/25.
//  Copyright (c) 2015年 ittracking Logistics Services Ltd. . All rights reserved.
//

#import "Web_request_data.h"
#import "Resp_Sypara.h"
#import "RespSearchCriteria.h"
#import "RespIcon.h"
#import "DB_sypara.h"
#import "DB_login.h"
#import "DB_searchCriteria.h"
#import "DB_icon.h"
#import "NSDictionary.h"
@implementation Web_request_data

#pragma mark -Network Resquest sypara
//登录成功后，请求sypara 用于控制是否显示carrier milestone
-(void)fn_get_sypara_data:(NSString*)str_base_url{
    RequestContract *req_form = [[RequestContract alloc] init];
    req_form.AdditSypara=[NSSet setWithObject:@"IAPPSMILESTONETIME"];
    DB_login *_dbLogin=[[DB_login alloc]init];
    AuthContract *auth=[_dbLogin WayOfAuthorization];
    auth.company_code=[_dbLogin fn_get_field_content:kCompany_code];
    req_form.Auth =auth;
    
    Web_base *web_base=[[Web_base alloc]init];
    web_base.il_url=STR_SYPARA_URL;
    web_base.base_url=str_base_url;
    web_base.iresp_class=[Resp_Sypara class];
    web_base.ilist_resp_mapping =[NSArray arrayWithPropertiesOfObject:[Resp_Sypara class]];
    web_base.callBack=^(NSMutableArray *alist_result ,BOOL isTimeOut){
        if ([alist_result count]!=0) {
            DB_sypara *db_sypara=[[DB_sypara alloc]init];
            [db_sypara fn_save_sypara_data:alist_result];
            db_sypara=nil;
        }
    };
    [web_base fn_get_data:req_form];
}

/**
 *  请求搜索标准数据SEARCHCRITERIA
 */
-(void)fn_get_searchcriteria_data:(NSString*)str_base_url{
    
    RequestContract *req_form=[[RequestContract alloc]init];
    DB_login *dbLogin=[[DB_login alloc]init];
    req_form.Auth=[dbLogin WayOfAuthorization];
    
    SearchFormContract *search=[[SearchFormContract alloc]init];
    search.os_column=@"form";
    search.os_value=@"ctschedule";
    
    req_form.SearchForm=[NSSet setWithObjects:search,nil];
    Web_base *web_base=[[Web_base alloc]init];
    web_base.base_url=str_base_url;
    web_base.il_url =STR_SEARCHCRITERIA_URL;
    web_base.iresp_class =[RespSearchCriteria class];
    
    web_base.ilist_resp_mapping =[NSArray arrayWithPropertiesOfObject:[RespSearchCriteria class]];
    web_base.callBack=^(NSMutableArray *alist_result,BOOL isTimeOut){
        DB_searchCriteria *db=[[DB_searchCriteria alloc]init];
        if (alist_result.count!=0) {
            [db fn_delete_all_data];
            [db fn_save_data:alist_result];
        }
        db=nil;
    };
    [web_base fn_get_data:req_form];
    req_form=nil;
    dbLogin=nil;
    search=nil;
    web_base=nil;
    
}
#pragma mark NetWork request

-(void)fn_get_allIcon{
    DB_icon *db=[[DB_icon alloc]init];
    if ([[db fn_get_all_iconData] count]==0) {
        [self fn_get_icon_data:@"0"];
    }else{
        NSString *recent_update=[[db fn_get_recent_update] valueForKey:@"max(upd_date)"];
        [self fn_get_icon_data:recent_update];
    }
    db=nil;
}
//请求图片
-(void)fn_get_icon_data:(NSString*)search_value{
    
    RequestContract *req_form=[[RequestContract alloc]init];
    DB_login *dbLogin=[[DB_login alloc]init];
    req_form.Auth=[dbLogin WayOfAuthorization];
    
    SearchFormContract *search=[[SearchFormContract alloc]init];
    search.os_column=@"rec_upd_date";
    search.os_value=search_value;
    
    req_form.SearchForm=[NSSet setWithObjects:search,nil];
    Web_base *web_base=[[Web_base alloc]init];
    web_base.base_url=[dbLogin fn_get_field_content:kWeb_addr];
    web_base.il_url =STR_ICON_URL;
    web_base.iresp_class =[RespIcon class];
    
    web_base.ilist_resp_mapping =[NSArray arrayWithPropertiesOfObject:[RespIcon class]];
    web_base.callBack=^(NSMutableArray *alist_result,BOOL isTimeOut){
        [self fn_save_icon_list:alist_result];
    };
    [web_base fn_get_data:req_form];
    req_form=nil;
    dbLogin=nil;
    search=nil;
    web_base=nil;
    
}

//搜索标准的图片存入数据库中
-(void)fn_save_icon_list:(NSMutableArray*)ilist_result{
    DB_icon *db=[[DB_icon alloc]init];
    if ([[db fn_get_all_iconData]count]==0) {
        [db fn_save_data:ilist_result];
    }else{
        for (RespIcon *lmap_icon in ilist_result) {
            NSMutableDictionary *ldict_row = [[NSDictionary dictionaryWithPropertiesOfObject:lmap_icon] mutableCopy];
            if ([db fn_isExist_icon:[ldict_row valueForKey:@"ic_name"]]) {
                [db fn_save_update_data:ldict_row];
            }else{
                NSMutableArray *arr=[[NSMutableArray alloc]init];
                [arr addObject:ldict_row];
                [db fn_save_data:arr];
            }
        }
    }
    db=nil;
}


@end
