//
//  DetailScheduleViewController.m
//  worldtrans
//
//  Created by itdept on 14-4-19.
//  Copyright (c) 2014年 Worldtrans Logistics Services Ltd. . All rights reserved.
//

#import "DetailScheduleViewController.h"
#import "MZFormSheetController.h"
#import "SortByViewController.h"
#import "Cell_detail_schedule.h"
#import "Custom_backgroundView.h"
#import "DB_login.h"
#import "Web_base.h"
#import "RespSchedule.h"
#import "MBProgressHUD.h"
#import "PopViewManager.h"
#import "Calculate_lineHeight.h"
@interface DetailScheduleViewController ()
@property(nonatomic,strong)Calculate_lineHeight *cal_obj;
@end

@implementation DetailScheduleViewController
@synthesize ilist_schedule;
@synthesize imd_searchDic;
@synthesize cal_obj;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //searchBar的代理
    _is_seach_bar.delegate=self;
    [self fn_get_data:imd_searchDic];
    [self BtnGraphicMixed];
    [self fn_setExtraline_hidden];
    cal_obj=[[Calculate_lineHeight alloc]init];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//实现按钮的图文混排
-(void)BtnGraphicMixed{
    
    [_ibtn_sortBy_btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_ibtn_sortBy_btn setTitle:@"sort By" forState:UIControlStateNormal];
    [_ibtn_sortBy_btn setImage:[UIImage imageNamed:@"ic_sort"] forState:UIControlStateNormal];
    
    [_ibtn_sortBy_btn setTitleEdgeInsets:UIEdgeInsetsMake(0,0, -30, -5)];
    
    [_ibtn_sortBy_btn setImageEdgeInsets:UIEdgeInsetsMake(5, _ibtn_sortBy_btn.frame.size.width-30, 5, 0)];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [ilist_schedule count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell_detail_schedule";
    Cell_detail_schedule *cell=[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    if( [indexPath row] % 2){
        cell.backgroundView=nil;
        cell.backgroundColor=[UIColor blackColor];
    }else{
        cell.backgroundView=[[Custom_backgroundView alloc]init];
    }

    NSMutableDictionary *ldict_dictionary=[ilist_schedule objectAtIndex:indexPath.row]
    ;
    cell.ilb_vessel_voyage.text=[ldict_dictionary valueForKey:@"vessel_voyage"];
    cell.ilb_wh_address.text=[ldict_dictionary valueForKey:@"carrier_name"];
    
    NSString *str_cycut=[NSString stringWithFormat:@"CY Cut:%@",[ldict_dictionary valueForKey:@"cy_cut"]];
    cell.ilb_cyCut.attributedText=[self fn_different_fontcolor:str_cycut range:NSMakeRange(0, 7)];;
    
    NSString *str_cfscut=[NSString stringWithFormat:@"CFS Cut:%@",[ldict_dictionary valueForKey:@"cfs_cut"]];   cell.ilb_cfsCut.attributedText=[self fn_different_fontcolor:str_cfscut range:NSMakeRange(0, 8)];
    
    NSString *str_etd=[NSString stringWithFormat:@"ETD:%@",[ldict_dictionary valueForKey:@"etd"]];
    cell.ilb_etd.attributedText=[self fn_different_fontcolor:str_etd range:NSMakeRange(0, 4)];
    
    NSString *str_eta=[NSString stringWithFormat:@"ETA:%@",[ldict_dictionary valueForKey:@"eta"]];
    cell.ilb_eta.attributedText=[self fn_different_fontcolor:str_eta range:NSMakeRange(0, 4)];
    
    NSString *str_tt=[NSString stringWithFormat:@"T/T:%@",[ldict_dictionary valueForKey:@"port_tt"]];
    cell.ilb_tt.attributedText=[self fn_different_fontcolor:str_tt range:NSMakeRange(0, 4)];
    
    cell.ilb_load_port.text=[ldict_dictionary valueForKey:@"load_port"];
    cell.ilb_dish_port.text=[ldict_dictionary valueForKey:@"port_name"];
   
        // Configure the cell...
    CGFloat height=[cal_obj fn_heightWithString:cell.ilb_vessel_voyage.text font:cell.ilb_vessel_voyage.font constrainedToWidth:cell.ilb_vessel_voyage.frame.size.width];
    if (height<21) {
        height=21;
    }
    [cell.ilb_vessel_voyage setFrame:CGRectMake(cell.ilb_vessel_voyage.frame.origin.x, cell.ilb_vessel_voyage.frame.origin.y, cell.ilb_vessel_voyage.frame.size.width,height)];
    CGFloat height1=[cal_obj fn_heightWithString:cell.ilb_wh_address.text font:cell.ilb_wh_address.font constrainedToWidth:cell.ilb_wh_address.frame.size.width];
    if (height1<21) {
        height1=21;
    }
    [cell.ilb_wh_address setFrame:CGRectMake(cell.ilb_wh_address.frame.origin.x, cell.ilb_vessel_voyage.frame.origin.y+height+1, cell.ilb_wh_address.frame.size.width, height1)];
    return cell;
}
#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell_detail_schedule";
    Cell_detail_schedule *cell=[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NSMutableDictionary *ldict_dictionary=[ilist_schedule objectAtIndex:indexPath.row]
    ;
    NSString *str_vessel=[ldict_dictionary valueForKey:@"vessel_voyage"];
    CGFloat height=[cal_obj fn_heightWithString:str_vessel font:cell.ilb_vessel_voyage.font constrainedToWidth:cell.ilb_vessel_voyage.frame.size.width];    NSString *str_carrier_name=[ldict_dictionary valueForKey:@"carrier_name"];
    CGFloat height1=[cal_obj fn_heightWithString:str_carrier_name font:cell.ilb_wh_address.font constrainedToWidth:cell.ilb_wh_address.frame.size.width];
    if (height<21) {
        height=21;
    }
    if (height1<21) {
        height1=21;
    }
    return height+height1+108;
}
-(void)fn_setExtraline_hidden{
    UIView *view=[[UIView alloc]initWithFrame:self.view.bounds];
    view.backgroundColor=[UIColor clearColor];
    [self.tableView setTableFooterView:view];
}
#pragma mark 同一个Label显示不同颜色的文字方法
-(NSMutableAttributedString*)fn_different_fontcolor:(NSString*)_str range:(NSRange)_range{
    NSMutableAttributedString *str=[[NSMutableAttributedString alloc]initWithString:_str];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:_range];
    
    return str;
}
#pragma mark UISearchBarDelegate
//点击搜索按钮的cancel，键盘收起
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar{
    [_is_seach_bar resignFirstResponder];
}
//点击搜索的时候，触发的事件
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [ilist_schedule removeAllObjects];
    [self handleSearch:searchBar];
}

- (void)handleSearch:(UISearchBar *)searchBar {
    NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
    [dic setObject:searchBar.text forKey:@"vessel"];
    [self fn_get_data:dic];
    // if you want the keyboard to go away
    [searchBar resignFirstResponder];
}
#pragma mark NetWork Request
-(void)fn_get_data:(NSMutableDictionary*)as_search_dic{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    RequestContract *req_form=[[RequestContract alloc]init];
    DB_login *dbLogin=[[DB_login alloc]init];
    req_form.Auth=[dbLogin WayOfAuthorization];
    if ([as_search_dic count]==1) {
        SearchFormContract *search=[[SearchFormContract alloc]init];
        search.os_column=@"vessel_voyage";
        search.os_value=[as_search_dic valueForKey:@"vessel"];
        req_form.SearchForm=[NSSet setWithObjects:search, nil];
    }else{
        NSEnumerator *keys=[as_search_dic keyEnumerator];
        NSMutableArray *arr_searchForm=[NSMutableArray array];
        for (NSString *key in keys) {
            SearchFormContract *search=[[SearchFormContract alloc]init];
            search.os_column=key;
            search.os_value=[as_search_dic valueForKey:key];
            [arr_searchForm addObject:search];
        }
        req_form.SearchForm=[NSSet setWithArray:arr_searchForm];
    }
    Web_base *web_base=[[Web_base alloc]init];
    web_base.il_url =STR_SCHEDULE_URL;
    web_base.iresp_class =[RespSchedule class];
    
    web_base.ilist_resp_mapping =[NSArray arrayWithPropertiesOfObject:[RespSchedule     class]];
    web_base.callBack=^(NSMutableArray *alist_result){
        ilist_schedule=alist_result;
        //默认以etd排序
        [self fn_sort_schedule:@"etd"];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    };
    [web_base fn_get_data:req_form];
    
}
#pragma mark 点击右上角的sortBy Button触发的方法
- (IBAction)fn_click_sortBy_btn:(id)sender {
    SortByViewController *sortByVC=[self.storyboard instantiateViewControllerWithIdentifier:@"SortByViewController"];
    sortByVC.callback=^(NSString *type){
        [self fn_sort_schedule:type];
    };
    PopViewManager *popV=[[PopViewManager alloc]init];
    [popV PopupView:sortByVC Size:CGSizeMake(250, 300) uponView:self];
}
#pragma mark 排序调用的方法
-(void)fn_sort_schedule:(NSString*)is_sortBy_name{
    //如果需要降序，那么将ascending由YES改为NO
    NSSortDescriptor *sortByName=[NSSortDescriptor sortDescriptorWithKey:is_sortBy_name ascending:YES];
    NSArray *sortDescriptors=[NSArray arrayWithObject:sortByName];
    NSMutableArray *sortedArray=[[ilist_schedule sortedArrayUsingDescriptors:sortDescriptors]mutableCopy];
    //重新排序后，存回给原来的数组
    ilist_schedule=sortedArray;
    [self.tableView reloadData];
}
@end
