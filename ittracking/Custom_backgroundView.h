//
//  Custom_backgroundView.h
//  worldtrans
//
//  Created by itdept on 14-4-29.
//  Copyright (c) 2014年 Worldtrans Logistics Services Ltd. . All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger, kBgView_type) {
    kBgView_color,
    kBgView_alert,
    kBgView_colorAndAlert,
};
@interface Custom_backgroundView : UIView

@property (nonatomic, copy) NSString *str_msg;
@property (nonatomic, assign) kBgView_type flag_bgView_type;

@end
