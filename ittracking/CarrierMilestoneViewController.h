//
//  CarrierMilestoneViewController.h
//  ittracking
//
//  Created by itdept on 14-8-19.
//  Copyright (c) 2014年 ittracking Logistics Services Ltd. . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Custom_headView.h"
#import "SKSTableView.h"
@interface CarrierMilestoneViewController : UIViewController<SKSTableViewDelegate>
@property (copy,nonatomic) NSString *is_hbl_uid;
@property (copy,nonatomic) NSString *is_doc_type;
@property (strong,nonatomic) NSMutableDictionary *idic_detail;

@property (weak, nonatomic) IBOutlet Custom_headView *iv_headView;
@property (weak, nonatomic) IBOutlet SKSTableView *skstableview;

@end
