//
//  ExhblGeneralController.h
//  worldtrans
//
//  Created by itdept on 2/24/14.
//  Copyright (c) 2014 itdept. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DB_login.h"
@interface ExhblGeneralController : UITableViewController

@property(nonatomic) NSString *is_search_column;
@property(nonatomic) NSString *is_search_value;

@property (strong,nonatomic) NSMutableArray *ilist_exhbl;
@property (strong,nonatomic)DB_login *dbLogin;

@end
