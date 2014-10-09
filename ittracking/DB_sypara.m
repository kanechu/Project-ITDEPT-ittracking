//
//  DB_sypara.m
//  ittracking
//
//  Created by itdept on 14-10-9.
//  Copyright (c) 2014年 ittracking Logistics Services Ltd. . All rights reserved.
//

#import "DB_sypara.h"
#import "FMDatabaseAdditions.h"
#import "FMResultSet.h"
#import "DBManager.h"
#import "NSDictionary.h"
#import "Resp_Sypara.h"

@implementation DB_sypara
@synthesize idb;

-(id)init{
    idb=[DBManager getSharedInstance];
    return self;
    
}

- (BOOL)fn_save_sypara_data:(NSMutableArray*)arr_sypara{
    if ([[idb fn_get_db]open]) {
        for (Resp_Sypara *sypara in arr_sypara) {
            NSMutableDictionary *dic_sypara=[[NSDictionary dictionaryWithPropertiesOfObject:sypara]mutableCopy];
            BOOL isSucceed=[[idb fn_get_db]executeUpdate:@"insert into sypara(unique_id,para_code,company_code,data1,data2,data3,data4,data5,para_desc,rec_crt_user,rec_upd_user,rec_crt_date,rec_upd_date,db_id,is_ct,crt_user,req_user,rmk)values(:unique_id,:para_code,:company_code,:data1,:data2,:data3,:data4,:data5,:para_desc,:rec_crt_user,:rec_upd_user,:rec_crt_date,:rec_upd_date,:db_id,:is_ct,:crt_user,:req_user,:rmk)" withParameterDictionary:dic_sypara];
            if (!isSucceed) {
                return NO;
            }
        }
        [[idb fn_get_db]close];
        return YES;
    }
    
    return NO;
}

- (NSMutableArray*)fn_get_sypara_data{
    NSMutableArray *arr_result=[NSMutableArray array];
    if ([[idb fn_get_db]open]) {
        FMResultSet *lfmdb_result=[[idb fn_get_db]executeQuery:@"select * from sypara"];
        while ([lfmdb_result next]) {
            [arr_result addObject:[lfmdb_result resultDictionary]];
        }
        [[idb fn_get_db]close];
    }
    return arr_result;
}


- (BOOL)fn_delete_all_sypara_data{
    if ([[idb fn_get_db]open]) {
        BOOL isDeleted=[[idb fn_get_db]executeUpdate:@"delete from sypara"];
        if (!isDeleted) {
            return NO;
        }
        [[idb fn_get_db]close];
        return YES;
    }
    return NO;
}

@end
