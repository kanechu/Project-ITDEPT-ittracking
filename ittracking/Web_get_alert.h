//
//  Web_get_alert.h
//  worldtrans
//
//  Created by itdept on 2/27/14.
//  Copyright (c) 2014 itdept. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^CallBack_alert)(NSMutableArray *);
@interface Web_get_alert : NSObject

@property (strong,nonatomic) NSMutableArray *ilist_alert;
@property (strong,nonatomic) CallBack_alert callBack;

- (void) fn_get_data;

@end
