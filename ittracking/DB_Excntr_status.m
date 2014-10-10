//
//  DB_Excntr_status.m
//  ittracking
//
//  Created by itdept on 14-8-20.
//  Copyright (c) 2014年 ittracking Logistics Services Ltd. . All rights reserved.
//

#import "DB_Excntr_status.h"
#import "DatabaseQueue.h"
#import "FMDatabaseAdditions.h"
#import "NSDictionary.h"
#import "RespExcntr_status.h"
@implementation DB_Excntr_status
@synthesize queue;

-(id)init{
    queue=[DatabaseQueue fn_sharedInstance];
    return self;
}

-(BOOL)fn_save_excntr_status_data:(NSMutableArray*)arr_result{
    __block BOOL ib_updated=NO;
    [queue inDataBase:^(FMDatabase *db){
        if ([db open]) {
            for (RespExcntr_status *lmap_result in arr_result) {
                NSDictionary *dic=[NSDictionary dictionaryWithPropertiesOfObject:lmap_result];
                ib_updated =[db executeUpdate:@"delete from excntr_status where cntr_uid = :cntr_uid and cntr_no = :cntr_no and size_type_word = :size_type_word and remark =:remark and location=:location and act_status_date=:act_status_date and eventtransportmode=:eventtransportmode" withParameterDictionary:dic];
                
                ib_updated=[db executeUpdate:@"insert into excntr_status(cntr_uid,cntr_no,size_type_word,remark,location,act_status_date,eventtransportmode)values (:cntr_uid,:cntr_no,:size_type_word,:remark,:location,:act_status_date,:eventtransportmode) " withParameterDictionary:dic];
            }
            [db close];
        }
    }];
    return ib_updated;
}
-(NSMutableArray*)fn_all_excntr_status_data{
    __block NSMutableArray *arr=[NSMutableArray array];
    [queue inDataBase:^(FMDatabase *db){
        if ([db open]) {
            FMResultSet *lfmdb_result=[db executeQuery:@"select * from excntr_status"];
            while ([lfmdb_result next]) {
                [arr addObject:[lfmdb_result resultDictionary]];
            }
            [db close];
        }
    }];
    return arr;
}
-(NSMutableArray*)fn_get_groupAndNum{
    __block NSMutableArray *arr=[NSMutableArray array];
    [queue inDataBase:^(FMDatabase *db){
        if ([db open]) {
            FMResultSet *lfmdb_result= [db executeQuery:@"SELECT cntr_uid,size_type_word,COUNT(cntr_uid) as subrows FROM excntr_status group by cntr_uid"];
            while ([lfmdb_result next]) {
                NSMutableDictionary *dic=[[lfmdb_result resultDictionary]mutableCopy];
                NSInteger subrows=[[dic valueForKey:@"subrows"]integerValue]+1;
                NSString *str_rows=[NSString stringWithFormat:@"%d",subrows];
                [dic setObject:str_rows forKey:@"subrows"];
                [arr addObject:dic];
            }
            [db close];
        }
    }];
    return arr;
}

-(BOOL)fn_delete_all_excntr_status_data{
    __block BOOL ib_deleted=NO;
    [queue inDataBase:^(FMDatabase *db){
        if ([db open]) {
            ib_deleted=[db executeUpdate:@"delete from excntr_status"];
            [db close];
        }
    }];
    return ib_deleted;
}

@end
