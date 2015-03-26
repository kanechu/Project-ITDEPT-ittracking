//
//  Web_request_data.h
//  ittracking
//
//  Created by itdept on 15/3/25.
//  Copyright (c) 2015年 ittracking Logistics Services Ltd. . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Web_base.h"
@interface Web_request_data : NSObject

-(void)fn_get_sypara_data:(NSString*)str_base_url;
-(void)fn_get_searchcriteria_data:(NSString*)str_base_url;

@end
