//
//  ScheduleViewController.h
//  ittracking
//
//  Created by itdept on 14-10-24.
//  Copyright (c) 2014年 ittracking Logistics Services Ltd. . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScheduleViewController : UIViewController<UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate>
@property (strong,nonatomic) NSMutableArray *ilist_schedule;
@property (strong,nonatomic) NSMutableDictionary *imd_searchDic;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UISearchBar *is_seach_bar;
@property (weak, nonatomic) IBOutlet UIButton *ibtn_sortBy_btn;

- (IBAction)fn_click_sortBy_btn:(id)sender;

@end
