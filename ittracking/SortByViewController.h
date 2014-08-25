//
//  SortByViewController.h
//  worldtrans
//
//  Created by itdept on 14-4-21.
//  Copyright (c) 2014年 Worldtrans Logistics Services Ltd. . All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^callBack_type)(NSString *);
@interface SortByViewController : UITableViewController

@property (strong,nonatomic)callBack_type callback;
- (IBAction)fn_disappear_sortBy:(id)sender;

@end
