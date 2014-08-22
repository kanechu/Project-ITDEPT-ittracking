//
//  LogoutViewController.m
//  worldtrans
//
//  Created by itdept on 14-3-29.
//  Copyright (c) 2014年 itdept. All rights reserved.
//

#import "LogoutViewController.h"
#import "MZFormSheetController.h"
#import "DB_login.h"
#import "AppConstants.h"

#define HEIGHT1 100
@interface LogoutViewController ()

@end

@implementation LogoutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad
{
    
    [super viewDidLoad];
    [_logoutBtn addTarget:self action:@selector(clickLogout:) forControlEvents:UIControlEventTouchUpInside];
    _logoutBtn.layer.cornerRadius=5;
    _logoutBtn.layer.borderWidth=1;
    _logoutBtn.layer.borderColor=[UIColor lightGrayColor].CGColor;
    [self showUserCodeAndLoginTime];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//没有logo的时候，label整体往上移动
-(void)changeLabelFrame:(UILabel*)label{
    label.frame=CGRectMake(label.frame.origin.x, label.frame.origin.y-HEIGHT1, label.frame.size.width, label.frame.size.height);
}
//没有logo的时候，Button往上移动
-(void)changeButtonFrame:(UIButton*)btn{
    btn.frame=CGRectMake(btn.frame.origin.x, btn.frame.origin.y-HEIGHT1, btn.frame.size.width, btn.frame.size.height);
}
-(void)showUserCodeAndLoginTime{
    
    DB_login *dbLogin=[[DB_login alloc]init];
    NSString *str_userId=@"";
    NSString *str_time=@"";
    NSString *str_logo=@"";
    if ([[dbLogin fn_get_all_msg]count]!=0) {
        str_userId=[[[dbLogin fn_get_all_msg] objectAtIndex:0] valueForKey:@"user_code"];
        str_time=[[[dbLogin fn_get_all_msg] objectAtIndex:0] valueForKey:@"login_time"];
        str_logo=[[[dbLogin fn_get_all_msg] objectAtIndex:0] valueForKey:@"user_logo"];
    }
    //图片不存在，整体往上移动
    if (str_logo==NULL || str_logo==nil || [str_logo length]==0) {
        _userImage.image=nil;
        [self changeLabelFrame:_userCode];
        [self changeLabelFrame:_userLoginTime];
        [self changeLabelFrame:_userID];
        [self changeLabelFrame:_loginTime];
        [self changeButtonFrame:_logoutBtn];
    }else{
        NSData *data=[[NSData alloc]initWithBase64EncodedString:str_logo options:0];
        _userImage.image=[UIImage imageWithData:data];
    }
    _userCode.text=str_userId;
    _userLoginTime.text=str_time;
    
}
- (void)clickLogout:(id)sender {
     [self mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController* formSheet){}];
    if (_callback) {
       _callback();
    }
}

- (IBAction)closeLogoutUI:(id)sender {
     [self mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController* formSheet){}];
}
@end
