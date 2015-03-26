//
//  Resp_app_config.h
//  ittracking
//
//  Created by itdept on 15/3/25.
//  Copyright (c) 2015年 ittracking Logistics Services Ltd. . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Resp_app_config : NSObject

@property (nonatomic,copy) NSString *company_code;
@property (nonatomic,copy) NSString *sys_name;
@property (nonatomic,copy) NSString *env;
@property (nonatomic,copy) NSString *web_addr;
@property (nonatomic,copy) NSString *php_addr;

@end
