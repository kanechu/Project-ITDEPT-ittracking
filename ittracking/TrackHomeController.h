//
//  FirstViewController.h
//  worldtrans
//
//  Created by itdept on 2/11/14.
//  Copyright (c) 2014 itdept. All rights reserved.
//
#import "ExhblListController.h"
#import "AehblListController.h"
#import <UIKit/UIKit.h>
@interface TrackHomeController : UIViewController<UIAlertViewDelegate,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *lbtn_exhbl_search;
@property (weak, nonatomic) IBOutlet UIButton *lbtn_aehbl_Search;
@property (weak, nonatomic) IBOutlet UITextField *ltf_search_no;
@end
