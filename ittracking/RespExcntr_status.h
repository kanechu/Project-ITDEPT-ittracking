//
//  RespExcntr_status.h
//  ittracking
//
//  Created by itdept on 14-8-19.
//  Copyright (c) 2014年 ittracking Logistics Services Ltd. . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RespExcntr_status : NSObject

@property (copy,nonatomic) NSString *cntr_uid;
@property (copy,nonatomic) NSString *cntr_no;
@property (copy,nonatomic) NSString *size_type_word;
@property (copy,nonatomic) NSString *remark;
@property (copy,nonatomic) NSString *location;
@property (copy,nonatomic) NSString *act_status_date;
@property (copy,nonatomic) NSString *eventtransportmode;

@end
