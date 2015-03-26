//
//  LoginViewController.h
//  worldtrans
//
//  Created by itdept on 14-3-18.
//  Copyright (c) 2014年 itdept. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Custom_TextField.h"
typedef void (^callBack_id)(NSString*);

@interface LoginViewController : UIViewController<UITextFieldDelegate>

@property(nonatomic,strong)callBack_id callBack;

@end
