//
//  LogoutViewController.h
//  worldtrans
//
//  Created by itdept on 14-3-29.
//  Copyright (c) 2014年 itdept. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^callBack)(void);
@interface LogoutViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *userLoginTime;
@property (weak, nonatomic) IBOutlet UILabel *userCode;
@property (weak, nonatomic) IBOutlet UIImageView *userImage;

@property (weak, nonatomic) IBOutlet UILabel *userID;
@property (weak, nonatomic) IBOutlet UILabel *loginTime;

@property (strong,nonatomic)callBack callback;

@property (weak, nonatomic) IBOutlet UIButton *logoutBtn;

- (void)clickLogout:(id)sender;
- (IBAction)closeLogoutUI:(id)sender;

@end
