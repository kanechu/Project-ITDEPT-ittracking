//
//  DB_device.h
//  worldtrans
//
//  Created by itdept on 14-3-29.
//  Copyright (c) 2014年 itdept. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBManager.h"
@interface DB_device : NSObject
@property (strong,nonatomic)DBManager *idb;
- (BOOL)fn_save_data:(NSString*)device_id;
-(NSMutableArray*)fn_get_all_msg;
@end
