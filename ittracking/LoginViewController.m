//
//  LoginViewController.m
//  worldtrans
//
//  Created by itdept on 14-3-18.
//  Copyright (c) 2014年 itdept. All rights reserved.
//

#import "LoginViewController.h"
#import "MZFormSheetController.h"
#import <RestKit/RestKit.h>
#import "RespLogin.h"
#import "Resp_Sypara.h"
#import "DB_login.h"
#import "DB_sypara.h"
#import "Web_base.h"
#import "MBProgressHUD.h"
#import "NSDictionary.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

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
    _loginBtn.layer.cornerRadius=5;
    _loginBtn.layer.borderWidth=1;
    _loginBtn.layer.borderColor=[UIColor lightGrayColor].CGColor;
    //设置文本框的代理
    _user_ID.delegate=self;
    _user_Password.delegate=self;
    _user_ID.returnKeyType=UIReturnKeyNext;
    _user_Password.returnKeyType=UIReturnKeyDone;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)fn_userName_textField_didEndOnExit:(id)sender {
    [_user_Password becomeFirstResponder];
}
- (IBAction)fn_pass_textField_didEndOnExit:(id)sender {
    [sender resignFirstResponder];
}

#pragma mark UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if (_user_ID.editing) {
        _user_ID.layer.borderColor=[UIColor orangeColor].CGColor;
    }else if(_user_Password.editing){
        _user_Password.layer.borderColor=[UIColor orangeColor].CGColor;
    }
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    _user_ID.layer.borderColor=[UIColor lightGrayColor].CGColor;
    _user_Password.layer.borderColor=[UIColor lightGrayColor].CGColor;
}

#pragma mark -Network Resquest Method
- (void) fn_get_data: (NSString*)user_code :(NSString*)user_pass
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [NSTimer scheduledTimerWithTimeInterval: 11.0 target: self
                                   selector: @selector(fn_hide_HUDView) userInfo: nil repeats: NO];
    
    RequestContract *req_form = [[RequestContract alloc] init];
    AuthContract *auth=[[AuthContract alloc]init];
    auth.user_code=user_code;
    auth.password=user_pass;
    auth.system = DEFAULT_SYSTEM;
    /**
     *  encrypted 如果为1，密码需要AES128加密，并base64 encode
     */
    auth.encrypted=IS_ENCRYPTED;
    req_form.Auth =auth;
    Web_base *web_base=[[Web_base alloc]init];
    web_base.il_url=STR_LOGIN_URL;
    web_base.iresp_class=[RespLogin class];
    web_base.ilist_resp_mapping =@[@"user_code",@"pass",@"user_logo"];
    web_base.callBack=^(NSMutableArray *alist_result){
        if ([alist_result count]!=0) {
            
            [self fn_save_login_list:alist_result];
        }
    };
    [web_base fn_get_data:req_form];
    
}
- (void) fn_save_login_list: (NSMutableArray *) alist_result {
    
    NSDictionary *loginData=[NSDictionary dictionaryWithPropertiesOfObject:[alist_result objectAtIndex:0]];
    if ([[loginData valueForKey:@"pass"] isEqualToString:@"true"]) {
        DB_login *dbLogin=[[DB_login alloc]init];
        NSString *userlogo=[loginData valueForKey:@"user_logo"];
        NSString *usercode=[loginData valueForKey:@"user_code"];
        [dbLogin fn_save_data:usercode password:_user_Password.text logo:userlogo];
        //登录成功后，请求spara
        [self fn_get_sypara_data:_user_ID.text pass:_user_Password.text];
        [self mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController* formSheet){}];
        if (_callBack) {
            _callBack(_user_ID.text);
        }
       
    }else{
       NSString *str_alert=@"User ID and Password do not match!";
        [self fn_PopUp_alert:str_alert];
    }
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
}
#pragma mark -helper
-(void)fn_hide_HUDView{
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}
-(void)fn_PopUp_alert:(NSString*)str_alert{
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:nil message:str_alert delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alertView show];
}
#pragma mark -Network Resquest sypara
//登录成功后，请求sypara 用于控制是否显示carrier milestone
-(void)fn_get_sypara_data:(NSString*)user_code pass:(NSString*)password{
   
    RequestContract *req_form = [[RequestContract alloc] init];
    req_form.AdditSypara=[NSSet setWithObject:@"IAPPSMILESTONETIME"];
    AuthContract *auth=[[AuthContract alloc]init];
    auth.user_code=user_code;
    auth.password=password;
    auth.system = DEFAULT_SYSTEM;
    /**
     *  encrypted 如果为1，密码需要AES128加密，并base64 encode
     */
    auth.encrypted=IS_ENCRYPTED;
    auth.company_code=DEFAULT_COMPANY_CODE;
    req_form.Auth =auth;
    
    Web_base *web_base=[[Web_base alloc]init];
    web_base.il_url=STR_SYPARA_URL;
    web_base.iresp_class=[Resp_Sypara class];
    web_base.ilist_resp_mapping =[NSArray arrayWithPropertiesOfObject:[Resp_Sypara class]];
    web_base.callBack=^(NSMutableArray *alist_result){
        if ([alist_result count]!=0) {
            DB_sypara *db_sypara=[[DB_sypara alloc]init];
            [db_sypara fn_save_sypara_data:alist_result];
        }
    };
    [web_base fn_get_data:req_form];
}
#pragma mark -userLogin method
- (IBAction)UserLogin:(id)sender {
    CheckNetWork *check_obj=[[CheckNetWork alloc]init];
    if ([check_obj fn_isPopUp_alert]==NO) {
        NSString *str=nil;
        if (_user_ID.text.length==0) {
            str=@"User ID can not be empty!";
        }else if(_user_Password.text.length==0){
            str=@"User Password can not be empty!";
        }else{
            [self fn_get_data:_user_ID.text :_user_Password.text];
            return;
        }
        [self fn_PopUp_alert:str];
        
    }
}

- (IBAction)closeLoginUI:(id)sender {
     [self mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController* formSheet){}];
}
@end
