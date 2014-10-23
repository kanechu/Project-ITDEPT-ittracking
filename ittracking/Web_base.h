//
//  Web_base.h
//  worldtrans
//
//  Created by itdept on 3/25/14.
//  Copyright (c) 2014 itdept. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AuthContract.h"
#import "RequestContract.h"
#import "SearchFormContract.h"
#import "AppConstants.h"
#import "NSArray.h"
#import "NSString.h"
#import "Res_color.h"
#import "CheckNetWork.h"
typedef void (^CallBack_arrResult)(NSMutableArray*);
@interface Web_base : NSObject

@property (strong,nonatomic)CallBack_arrResult callBack;

@property (strong,nonatomic) NSString *il_url;

@property (strong,nonatomic) Class iresp_class;

@property (strong,nonatomic) NSMutableArray *ilist_resp_result;

@property (strong,nonatomic) NSArray *ilist_resp_mapping;

- (void) fn_get_data:(RequestContract*)ao_form ;

@end
