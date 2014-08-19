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
@interface DetailScheduleViewController ()

@end

@implementation DetailScheduleViewController
@synthesize ilist_schedule;
@synthesize imd_searchDic;

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
    NSLog(@"%@",imd_searchDic);
    [self BtnGraphicMixed];

}
//实现按钮的图文混排
-(void)BtnGraphicMixed{
    
    [_ibtn_sortBy_btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_ibtn_sortBy_btn setTitle:@"sort By" forState:UIControlStateNormal];
    [_ibtn_sortBy_btn setImage:[UIImage imageNamed:@"ic_sort"] forState:UIControlStateNormal];
    
    [_ibtn_sortBy_btn setTitleEdgeInsets:UIEdgeInsetsMake(0,0, -30, -5)];
    
    [_ibtn_sortBy_btn setImageEdgeInsets:UIEdgeInsetsMake(5, _ibtn_sortBy_btn.frame.size.width-30, 5, 0)];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  
    if (ilist_schedule==nil || ilist_schedule==NULL) {
        return 0;
    }else{
        return [ilist_schedule count];
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell_detail_schedule";
    Cell_detail_schedule *cell=[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell==nil) {
        NSArray *nib=[[NSBundle mainBundle]loadNibNamed:@"Cell_detail_schedule" owner:self options:nil];
        cell=[nib objectAtIndex:0];
    }
    if( [indexPath row] % 2){
        cell.backgroundView=nil;
        cell.backgroundColor=[UIColor blackColor];
    }else{
        cell.backgroundView=[[Custom_backgroundView alloc]init];
    }

    NSMutableDictionary *ldict_dictionary=[[NSMutableDictionary alloc]init];
    ldict_dictionary=[ilist_schedule objectAtIndex:indexPath.row]
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
    
    return cell;
}
#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (ilist_schedule==nil||ilist_schedule==NULL||ilist_schedule.count==0) {
        return 40;
    }else{
        return 145;
    }
}
-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}
#pragma mark 同一个Label显示不同颜色的文字方法
-(NSMutableAttributedString*)fn_different_fontcolor:(NSString*)_str range:(NSRange)_range{
    NSMutableAttributedString *str=[[NSMutableAttributedString alloc]initWithString:_str];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:_range];
    
    return str;
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
#pragma mark UISearchBarDelegate
//点击搜索按钮的cancel，键盘收起
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar{
    [_is_seach_bar resignFirstResponder];
}
//点击搜索的时候，触发的事件
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    ilist_schedule=nil;
    [self.tableView reloadData];
    [self handleSearch:searchBar];
}


- (void)handleSearch:(UISearchBar *)searchBar {
    NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
    [dic setObject:searchBar.text forKey:@"vessel"];
    [self fn_get_data:dic];
    // if you want the keyboard to go away
    [searchBar resignFirstResponder];
}
#pragma mark 按条件获取服务器的数据
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
        SearchFormContract *search=[[SearchFormContract alloc]init];
        search.os_column=[as_search_dic valueForKey:@"load_port_column"];
        search.os_value=[as_search_dic valueForKey:@"load_port_value"];
        
        SearchFormContract *search1=[[SearchFormContract alloc]init];
        search1.os_column=[as_search_dic valueForKey:@"dish_port_column"];
        search1.os_value=[as_search_dic valueForKey:@"dish_port_value"];
        
        SearchFormContract *search2=[[SearchFormContract alloc]init];
        search2.os_column=[as_search_dic valueForKey:@"datetype_column"];
        search2.os_value=[as_search_dic valueForKey:@"datetype_value"];
        
        SearchFormContract *search3=[[SearchFormContract alloc]init];
        search3.os_column=[as_search_dic valueForKey:@"datefm_column"];
        search3.os_value=[as_search_dic valueForKey:@"datefm_value"];
        
        SearchFormContract *search4=[[SearchFormContract alloc]init];
        search4.os_column=[as_search_dic valueForKey:@"dateto_column"];
        search4.os_value=[as_search_dic valueForKey:@"dateto_value"];
        req_form.SearchForm=[NSSet setWithObjects:search,search1,search2,search3,search4, nil];
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
