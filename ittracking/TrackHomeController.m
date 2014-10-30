//
//  FirstViewController.m
//  worldtrans
//
//  Created by itdept on 2/11/14.
//  Copyright (c) 2014 itdept. All rights reserved.
//

#import "TrackHomeController.h"

@interface TrackHomeController ()


@end

@implementation TrackHomeController

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    _ltf_search_no.delegate=self;
    _ltf_search_no.layer.cornerRadius=5;
    [_ltf_search_no becomeFirstResponder];
    [self fn_custom_GestureRecognizer];
    
    [self addBound:_lbtn_exhbl_search];
    [self addBound:_lbtn_aehbl_Search];
    [_lbtn_exhbl_search addTarget:self action:@selector(fn_click_seaExport) forControlEvents:UIControlEventTouchUpInside];
    [_lbtn_aehbl_Search addTarget:self action:@selector(fn_click_airExport) forControlEvents:UIControlEventTouchUpInside];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//给按钮添加边框的方法
-(void)addBound:(UIButton*)_sender{
   
    [_sender.layer setMasksToBounds:YES];
    [_sender.layer setContentsScale:22];
    [_sender.layer setCornerRadius:2.0];
    [_sender.layer setBorderWidth:1.0];
    CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();
    //前三位是RGB 0,0,255
    CGColorRef colorRef=CGColorCreate(colorSpace, (CGFloat[]){0,0,255,2});
    
    [_sender.layer setBorderColor:colorRef];
}
#pragma mark seaExport and airExport
-(void)fn_click_seaExport{
    if ([_ltf_search_no.text length]<1) {
        
        [self fn_show_prompt];
        
    }else{
        [self performSegueWithIdentifier:@"segue_exhbl" sender:self];
    }
    
}
-(void)fn_click_airExport{
    if ([_ltf_search_no.text length]<1) {
        
        [self fn_show_prompt];
        
    }else{
        [self performSegueWithIdentifier:@"segue_aehbl" sender:self];
    }
}
- (void)fn_show_prompt{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@" Booking / HBL/ HAWB No cannot be empty！" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
     if([segue.identifier isEqualToString:@"segue_exhbl"]){
        ExhblListController *exhbl_VC = (ExhblListController *)segue.destinationViewController;
        exhbl_VC.is_search_no =_ltf_search_no.text;
    }

    if([segue.identifier isEqualToString:@"segue_aehbl"]){
        AehblListController *aehbl_VC = (AehblListController *)segue.destinationViewController;
         aehbl_VC.is_search_no =_ltf_search_no.text;
    }
}
#pragma mark UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [_ltf_search_no resignFirstResponder];
    return YES;
}
#pragma mark 
-(void)fn_custom_GestureRecognizer{
    UITapGestureRecognizer *gestureRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(fn_hide_keyboard)];
    [self.view addGestureRecognizer:gestureRecognizer];

}
-(void)fn_hide_keyboard{
    [_ltf_search_no resignFirstResponder];
}
@end
