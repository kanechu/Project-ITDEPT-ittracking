//
//  DB_Excntr_status.h
//  ittracking
//
//  Created by itdept on 14-8-20.
//  Copyright (c) 2014年 ittracking Logistics Services Ltd. . All rights reserved.
//

#import <Foundation/Foundation.h>
@class DatabaseQueue;
@interface DB_Excntr_status : NSObject
@property(strong,nonatomic)DatabaseQueue *queue;

-(BOOL)fn_save_excntr_status_data:(NSMutableArray*)arr_result;

-(NSMutableArray*)fn_all_excntr_status_data;

-(NSMutableArray*)fn_get_groupAndNum;

-(BOOL)fn_delete_all_excntr_status_data;

@end
