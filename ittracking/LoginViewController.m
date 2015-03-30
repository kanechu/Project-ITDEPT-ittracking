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
#import "Resp_app_config.h"
#import "RespLogin.h"
#import "DB_login.h"
#import "Web_request_data.h"
#import "Web_get_permit.h"
#import "MBProgressHUD.h"
#import "NSDictionary.h"

#define DEFAULT_USERCODE @"anonymous";
#define DEFAULT_PASSWORD @"anonymous1";
#define DEFAULT_SYSTEM @"ITNEW";
typedef NS_ENUM(NSInteger, kTimeOut_stage){
    kAppconfig_stage,
    kLogin_stage
};
@interface LoginViewController ()<UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *itf_usercode;
@property (weak, nonatomic) IBOutlet UITextField *itf_password;
@property (weak, nonatomic) IBOutlet UITextField *itf_system;
@property (weak, nonatomic) IBOutlet UIView *iv_usercode_line;
@property (weak, nonatomic) IBOutlet UIView *iv_password_line;
@property (weak, nonatomic) IBOutlet UIView *iv_system_line;
@property (weak, nonatomic) IBOutlet UIButton *ibtn_login;
@property (weak, nonatomic) IBOutlet UIButton *ibtn_showPassword;
//用来标识点击的textfiled
@property (nonatomic)UITextField *checkText;
@property (nonatomic, assign) CGRect keyboardRect;
@property (nonatomic, strong) DB_login *dbLogin;
@property (nonatomic, assign) kTimeOut_stage timeOut_stage;

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
    [self fn_set_control_property];
    [self fn_custom_gesture];
    [self fn_registKeyBoardNotification];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)fn_set_control_property{
    _dbLogin=[[DB_login alloc]init];
    
    [_itf_usercode setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [_itf_password setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [_itf_system setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    _itf_usercode.returnKeyType=UIReturnKeyNext;
    _itf_password.returnKeyType=UIReturnKeyNext;
    _itf_system.returnKeyType=UIReturnKeyDone;
    
    _ibtn_login.layer.cornerRadius=2;
    _ibtn_login.layer.borderWidth=0.5;
    _ibtn_login.layer.borderColor=[UIColor lightGrayColor].CGColor;
    [_ibtn_showPassword setImage:[UIImage imageNamed:@"checkbox_unchecked"] forState:UIControlStateNormal];
    [_ibtn_showPassword setImage:[UIImage imageNamed:@"checkbox_checked"] forState:UIControlStateSelected];
}
-(void)fn_custom_gesture{
    UITapGestureRecognizer *tapgesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(fn_keyboardHide:)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapgesture.cancelsTouchesInView = NO;
    //将触摸事件添加到当前view
    [self.view addGestureRecognizer:tapgesture];
}
-(void)fn_keyboardHide:(UITapGestureRecognizer*)tap{
    [_checkText resignFirstResponder];
}
//监听键盘隐藏和显示事件
-(void)fn_registKeyBoardNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
//注销监听事件
-(void)fn_removeKeyBoarNotificaton{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
#pragma mark Responding to keyboard events
- (void)keyboardWillShow:(NSNotification*)notification {
    
    if (nil == _checkText) {
        return;
    }
    NSDictionary *userInfo = [notification userInfo];
    
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect keyboardRect1 = [aValue CGRectValue];
    if (keyboardRect1.size.width!=0) {
        _keyboardRect=keyboardRect1;
    }
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    NSTimeInterval animationDuration;
    
    [animationDurationValue getValue:&animationDuration];
    
    CGRect textFrame =[_checkText convertRect:_checkText.bounds toView:self.view];
    float textY = textFrame.origin.y + textFrame.size.height;//得到tableView下边框距离顶部的高度
    float bottomY = self.view.frame.size.height - textY;//得到下边框到底部的距离
    
    if(bottomY >=_keyboardRect.size.height ){//键盘默认高度,如果大于此高度，则直接返回
        return;
        
    }
    float moveY = _keyboardRect.size.height - bottomY+10;
    [self moveInputBarWithKeyboardHeight:moveY withDuration:animationDuration];
    
}
//键盘被隐藏的时候调用的方法
-(void)keyboardWillHide:(NSNotification*)notification {
    NSDictionary* userInfo = [notification userInfo];
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    NSTimeInterval animationDuration;
    
    [animationDurationValue getValue:&animationDuration];
    
    [self moveInputBarWithKeyboardHeight:0.0 withDuration:animationDuration];
    
}
#pragma mark 移动view

-(void)moveInputBarWithKeyboardHeight:(float)_CGRectHeight withDuration:(NSTimeInterval)_NSTimeInterval{
    
    CGRect rect = self.view.frame;
    
    [UIView beginAnimations:nil context:NULL];
    
    [UIView setAnimationDuration:_NSTimeInterval];
    
    rect.origin.y = -_CGRectHeight;//view往上移动
    
    self.view.frame = rect;
    
    [UIView commitAnimations];
}

#pragma mark -event action
- (IBAction)fn_login_ITTracking:(id)sender {
    CheckNetWork *check_obj=[[CheckNetWork alloc]init];
    if ([check_obj fn_check_isNetworking]) {
        NSString *str_prompt=@"";
        if ([_itf_usercode.text length]==0) {
            str_prompt=@"User ID can not be empty!";
        }else if([_itf_password.text length]==0){
            str_prompt=@"User Password can not be empty!";
        }else if ([_itf_system.text length]==0){
            str_prompt=@"System Code can not be empty!";
        }else{
            [self fn_get_Web_addr_data];
            return;
        }
        [self fn_PopUp_alert:str_prompt];
    }
}
- (IBAction)fn_isShowPassword:(id)sender {
    _ibtn_showPassword.selected=!_ibtn_showPassword.selected;
    if (_ibtn_showPassword.selected) {
        [_itf_password setSecureTextEntry:NO];
    }else{
        [_itf_password setSecureTextEntry:YES];
    }
}

- (IBAction)fn_userName_textField_didEndOnExit:(id)sender {
    [self.itf_password becomeFirstResponder];
    [self keyboardWillShow:nil];
}
- (IBAction)fn_pass_textField_didEndOnExit:(id)sender {
    [self.itf_system becomeFirstResponder];
    [self keyboardWillShow:nil];
}
- (IBAction)fn_sys_textField_didEndOnExit:(id)sender {
    [sender resignFirstResponder];
}


#pragma mark UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    _checkText=textField;
    if (_itf_usercode.editing) {
        _iv_usercode_line.backgroundColor=[UIColor blueColor];
    }else if(_itf_password.editing){
        _iv_password_line.backgroundColor=[UIColor blueColor];
    }else if(_itf_system.editing){
        _iv_system_line.backgroundColor=[UIColor blueColor];
    }
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    _iv_system_line.backgroundColor=[UIColor lightGrayColor];
    _iv_password_line.backgroundColor=[UIColor lightGrayColor];
    _iv_usercode_line.backgroundColor=[UIColor lightGrayColor];
}

#pragma mark -Network Resquest Method
- (void) fn_get_Web_addr_data
{
   [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    RequestContract *req_form = [[RequestContract alloc] init];
    AuthContract *auth=[[AuthContract alloc]init];
    auth.user_code=DEFAULT_USERCODE;
    auth.password=DEFAULT_PASSWORD;
    auth.system =DEFAULT_SYSTEM;
    auth.version=ITTRACKING_VERSION;
    auth.com_sys_code=_itf_system.text;
    auth.app_code=DEFAULT_APP_CODE;
    req_form.Auth =auth;
    
    Web_base *web_base=[[Web_base alloc]init];
    web_base.il_url=STR_CONFIG_URL;
    web_base.base_url=STR_BASE_URL;
    web_base.iresp_class=[Resp_app_config class];
    web_base.ilist_resp_mapping=[NSArray arrayWithPropertiesOfObject:[Resp_app_config class]];
    web_base.callBack=^(NSMutableArray *arr_resp_result,BOOL isTimeOut){
        if (isTimeOut) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            _timeOut_stage=kAppconfig_stage;
            [self fn_show_request_timeOut_alert];
            
        }else{
            if (arr_resp_result.count!=0) {
                [_dbLogin fn_delete_all_appConfig_data];
                [_dbLogin fn_save_app_config_data:arr_resp_result];
            }
            NSString* base_url=nil;
            NSString* sys_name=nil;
            if (arr_resp_result!=nil && [arr_resp_result count]!=0) {
                base_url=[[arr_resp_result objectAtIndex:0] valueForKey:@"web_addr"];
                sys_name=[[arr_resp_result objectAtIndex:0]valueForKey:@"sys_name"];
            }
            [self fn_get_RespusersLogin_data:base_url sys_name:sys_name];
        }
    };
    [web_base fn_get_data:req_form];
}
- (void) fn_get_RespusersLogin_data:(NSString*)base_url sys_name:(NSString*)sys_name{
    RequestContract *req_form = [[RequestContract alloc] init];
    AuthContract *auth=[[AuthContract alloc]init];
    auth.user_code=_itf_usercode.text;
    auth.password=_itf_password.text;
    auth.system =sys_name;
    auth.encrypted=IS_ENCRYPTED;
    auth.version=ITTRACKING_VERSION;
    req_form.Auth =auth;
    auth=nil;
    
    Web_base *web_base=[[Web_base alloc]init];
    web_base.il_url=STR_LOGIN_URL;
    web_base.base_url=base_url;
    web_base.iresp_class=[RespLogin class];
    web_base.ilist_resp_mapping=[NSArray arrayWithPropertiesOfObject:[RespLogin class]];
    web_base.callBack=^(NSMutableArray *arr_resp_result,BOOL isTimeOut){
        if (isTimeOut) {
            _timeOut_stage=kLogin_stage;
            [self fn_show_request_timeOut_alert];
        }else{
            if ([[[arr_resp_result firstObject]valueForKey:@"pass"]isEqualToString:@"true"]) {
                
                NSUserDefaults *user_isLogin=[NSUserDefaults standardUserDefaults];
                [user_isLogin setInteger:1 forKey:@"isLogin"];
                [user_isLogin synchronize];
                
                DB_login *dbLogin=[[DB_login alloc]init];
                NSString *user_logo=[[arr_resp_result firstObject]valueForKey:@"user_logo"];
                [dbLogin fn_save_data:_itf_usercode.text password:_itf_password.text system:sys_name logo:user_logo];
            
                //登录成功后，请求spara
                Web_request_data *web_request_obj=[[Web_request_data alloc]init];
                [web_request_obj fn_get_sypara_data:base_url];
                [web_request_obj fn_get_searchcriteria_data:base_url];
                [web_request_obj fn_get_allIcon];
                [self dismissViewControllerAnimated:YES completion:nil];
                if (_callBack) {
                    _callBack(_itf_usercode.text);
                }
                web_request_obj=nil;
                Web_get_permit *web_permit_obj=[[Web_get_permit alloc]init];
                [web_permit_obj fn_get_permit_data:base_url callBack:^(BOOL isSuccess){
                    
                }];
                
            }else{
                NSString *str_alert=@"User ID and Password do not match!";
                [self fn_PopUp_alert:str_alert];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }
        }
    };
    [web_base fn_get_data:req_form];
}

-(void)fn_PopUp_alert:(NSString*)str_alert{
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:nil message:str_alert delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alertView show];
}
- (void)fn_show_request_timeOut_alert{
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:nil message:@"Network request timed out, retry or cancel the request ?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Retry", nil];
    [alertView show];
}
#pragma mark -UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==[alertView firstOtherButtonIndex]) {
        if (_timeOut_stage==kAppconfig_stage) {
            [self fn_get_Web_addr_data];
        }else if (_timeOut_stage==kLogin_stage){
            NSString *base_url=[_dbLogin fn_get_field_content:kWeb_addr];
            NSString *sys_name=[_dbLogin fn_get_field_content:kSys_name];
            [self fn_get_RespusersLogin_data:base_url sys_name:sys_name];
            base_url=nil;
            sys_name=nil;
        }
    }
}


@end
