//
//  ExpandSearchCriteriaViewController.h
//  worldtrans
//
//  Created by itdept on 14-5-9.
//  Copyright (c) 2014年 Worldtrans Logistics Services Ltd. . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKSTableView.h"
#import "Custom_SearchBtn.h"
@class DB_searchCriteria;
@interface ExpandSearchCriteriaViewController : UIViewController<UITextFieldDelegate,UIPickerViewDataSource,UIPickerViewDelegate,SKSTableViewDelegate>

//存储图片
@property(nonatomic,strong)NSMutableArray *alist_icon;
//用来标记点击的UITextfield；
@property(nonatomic)UITextField *checkText;

//dateType下拉列表数据
@property (strong,nonatomic) NSMutableArray *ia_listData;
@property (strong,nonatomic) NSMutableArray *ilist_dateType;
//用来记录选择的datetype所在的行数
@property (assign,nonatomic)NSInteger select_row;
@property (strong,nonatomic) UIPickerView *ipic_drop_view;
@property (strong,nonatomic)UIDatePicker *idp_picker;
//id_startdate用来记录日期拾取器获取的日期
@property (copy,nonatomic)NSDate *id_startdate;

@property (weak, nonatomic) IBOutlet Custom_SearchBtn *ibt_search_btn;
@property (weak, nonatomic) IBOutlet SKSTableView *skstableView;

- (IBAction)fn_click_portBtn:(id)sender;

- (IBAction)fn_end_edit_textfield:(id)sender;

- (IBAction)fn_click_subBtn:(id)sender;
- (IBAction)fn_click_addBtn:(id)sender;
- (IBAction)fn_click_day:(id)sender;
- (IBAction)fn_begin_click_day:(id)sender;

- (IBAction)fn_click_searchBtn:(id)sender;

@end
