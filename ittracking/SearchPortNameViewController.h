//
//  SearchPortNameViewController.h
//  worldtrans
//
//  Created by itdept on 14-4-23.
//  Copyright (c) 2014年 Worldtrans Logistics Services Ltd. . All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^callBack_portName)(NSMutableDictionary*);
@interface SearchPortNameViewController : UIViewController<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>
@property (strong,nonatomic) callBack_portName callBack;
@property (strong,nonatomic) NSMutableArray *ilist_portname;
@property (nonatomic,copy)NSString *is_placeholder;

@property (weak, nonatomic) IBOutlet UISearchBar *is_search_portName;
@property (weak, nonatomic) IBOutlet UITableView *it_table_portname;


- (IBAction)fn_click_close:(id)sender;

@end
