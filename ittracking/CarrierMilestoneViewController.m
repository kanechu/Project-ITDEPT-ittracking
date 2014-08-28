//
//  CarrierMilestoneViewController.m
//  ittracking
//
//  Created by itdept on 14-8-19.
//  Copyright (c) 2014年 ittracking Logistics Services Ltd. . All rights reserved.
//

#import "CarrierMilestoneViewController.h"
#import "RespExcntr_status.h"
#import "Web_base.h"
#import "MBProgressHUD.h"
#import "DB_login.h"
#import "DB_Excntr_status.h"
#import "Cell_Carrier_milestone.h"
#import "SKSTableViewCell.h"
#import "Calculate_lineHeight.h"
@interface CarrierMilestoneViewController ()
@property (nonatomic,strong)NSMutableArray *alist_excntr_status;
@property (nonatomic,strong)NSMutableArray *alist_filtered_data;
@property (nonatomic,strong)NSMutableArray *alist_groupAndnum;
@property (nonatomic,strong) Calculate_lineHeight *cal_obj;
@property (copy,nonatomic) NSString *is_hbl_uid;
@end

@implementation CarrierMilestoneViewController
@synthesize alist_excntr_status;
@synthesize alist_filtered_data;
@synthesize alist_groupAndnum;
@synthesize cal_obj;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self fn_set_array_pro];
    [self fn_set_headView];
    [self fn_get_excntr_status_data];
    self.skstableview.SKSTableViewDelegate=self;
    [self setExtraCellLineHidden];
    cal_obj=[[Calculate_lineHeight alloc]init];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)fn_set_array_pro{
    alist_filtered_data=[NSMutableArray array];
    DB_Excntr_status *db_excntr=[[DB_Excntr_status alloc]init];
    [db_excntr fn_delete_all_excntr_status_data];
}
-(void)fn_set_headView{
    
    _iv_headView.il_booking_hbl_no.text=[NSString stringWithFormat:@"%@ / %@",[self fn_get_subString:[_idic_detail valueForKey:@"so_no"]] , [_idic_detail valueForKey:@"hbl_no"]];
    _is_hbl_uid=[_idic_detail valueForKey:@"hbl_uid"];
}
-(NSString*)fn_get_subString:(NSString*)string{
    NSRange range=[string rangeOfString:@" "];
    if (range.location==NSNotFound ) {
        return string;
    }else{
        NSString *subString=[string substringToIndex:range.location];
        return subString;
    }
}
#pragma mark NetWork Request excntr_status_data
-(void)fn_get_excntr_status_data{
    //显示loading
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    RequestContract *req_form = [[RequestContract alloc] init];
    DB_login *dbLogin=[[DB_login alloc]init];
    req_form.Auth =[dbLogin WayOfAuthorization];
    SearchFormContract *search1 = [[SearchFormContract alloc]init];
    search1.os_column = @"hbl_uid";
    search1.os_value = _is_hbl_uid;
    req_form.SearchForm = [NSSet setWithObjects:search1,nil];
    Web_base *web_base = [[Web_base alloc] init];
    web_base.il_url =STR_EXCNTR_STATUS_URL;
    web_base.iresp_class =[RespExcntr_status class];
    
    web_base.ilist_resp_mapping =[NSArray arrayWithPropertiesOfObject:[RespExcntr_status class]];
    web_base.callBack=^(NSMutableArray *alist_result){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        DB_Excntr_status *db_excntr=[[DB_Excntr_status alloc]init];
        [db_excntr fn_save_excntr_status_data:alist_result];
        alist_excntr_status=[db_excntr fn_all_excntr_status_data];
        alist_groupAndnum=[db_excntr fn_get_groupAndNum];
        [self fn_get_filtered_data];
        [self.skstableview reloadData];
        if ([alist_groupAndnum count]==2) {
            [self.skstableview fn_expandall];
        }
    };
    [web_base fn_get_data:req_form];
}
#pragma mark filter array
-(void)fn_get_filtered_data{
    for (NSMutableDictionary *dic in alist_groupAndnum) {
        NSString *str_uid=[dic valueForKey:@"cntr_uid"];
        NSMutableArray *arr=[self fn_filtered_criteriaData:str_uid];
        if ([arr count]!=0) {
            [alist_filtered_data addObject:arr];
        }
    }
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    [dic setObject:@"Click the following Container to see the detail " forKey:@"cntr_uid"];
    [dic setObject:@"0" forKey:@"subrows"];
    [alist_groupAndnum insertObject:dic atIndex:0];
}


-(NSMutableArray*)fn_filtered_criteriaData:(NSString*)key{
    NSMutableArray *filtered=[[alist_excntr_status filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(cntr_uid==%@)",key]]mutableCopy];
    NSString *key_uid=[NSString stringWithFormat:@"Container Milestone:%@",key];
    NSMutableDictionary *dic=[NSMutableDictionary dictionaryWithObject:key_uid forKey:@"prompt"];
    [filtered insertObject:dic atIndex:0];
    return filtered;
}
#pragma mark SKSTableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [alist_groupAndnum count];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
-(NSInteger)tableView:(SKSTableView *)tableView numberOfSubRowsAtIndexPath:(NSIndexPath *)indexPath{
    NSString *numofrow=[[alist_groupAndnum objectAtIndex:indexPath.section]valueForKey:@"subrows"];
    return [numofrow integerValue];
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"SKSTableViewCellCustom";
    SKSTableViewCell *cell =nil;
    if (!cell){
        cell = [[SKSTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(10, 2, 310, 21)];
        label.tag=200;
        [cell.contentView addSubview:label];
    }
    UILabel *il_title=(UILabel*)[cell.contentView viewWithTag:200];
    NSMutableDictionary *dic=[alist_groupAndnum objectAtIndex:indexPath.section];
    if (indexPath.section==0) {
        cell.backgroundColor=[UIColor whiteColor];
        il_title.font=[UIFont boldSystemFontOfSize:14.0f];
        il_title.text=[dic valueForKey:@"cntr_uid"];
        cell.expandable=NO;
    }else{
        [cell setBackgroundColor:COLOR_LIGHT_BLUE];
        il_title.textColor=[UIColor redColor];
        il_title.text=[NSString stringWithFormat:@"%@   Size:%@",[dic valueForKey:@"cntr_uid"],[dic valueForKey:@"size_type_word"]];
        il_title.font=[UIFont systemFontOfSize:16.0f];
        cell.expandable=YES;
    }
    cell.selectedBackgroundView=[[UIView alloc]initWithFrame:cell.bounds];
    cell.selectedBackgroundView.backgroundColor=[UIColor blueColor];
    [cell setExpanded:YES];
    return cell;
}
-(UITableViewCell*)tableView:(SKSTableView *)tableView cellForSubRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    if (indexPath.section!=0) {
        dic=[alist_filtered_data objectAtIndex:indexPath.section-1][indexPath.subRow-1];
    }
    if (indexPath.subRow==1) {
        static NSString *CellIdentifier = @"UITableViewCell";
        UITableViewCell *cell = [self.skstableview dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            UILabel *lable=[[UILabel alloc]initWithFrame:CGRectMake(10, 2, 300, 21)];
            lable.tag=100;
            lable.font=[UIFont boldSystemFontOfSize:14.0f];
            [cell.contentView addSubview:lable];
        }
        UILabel *il_title=(UILabel*)[cell.contentView viewWithTag:100];
        il_title.text=[dic valueForKey:@"prompt"];
        cell.backgroundColor=[UIColor whiteColor];
        return cell;
    }else{
        static NSString *cellIndentifier=@"Cell_Carrier_milestone";
        Cell_Carrier_milestone *cell=[self.skstableview dequeueReusableCellWithIdentifier:cellIndentifier forIndexPath:indexPath];
        if (!cell) {
            cell=[self.skstableview dequeueReusableCellWithIdentifier:cellIndentifier];
        }
        if( ([indexPath subRow]-1) % 2==0)
            [cell setBackgroundColor:COLOR_DARK_JUNGLE_GREEN];
        else
            [cell setBackgroundColor:COLOR_EERIE_BLACK];
        cell.il_remark.text=[dic valueForKey:@"remark"];
        cell.il_location.text=[dic valueForKey:@"location"];
        cell.il_act_status_date.text=[dic valueForKey:@"act_status_date"];
        cell.il_eventtransportmode.text=[dic valueForKey:@"eventtransportmode"];
        
        CGFloat height=[cal_obj fn_heightWithString:cell.il_remark.text font:cell.il_remark.font constrainedToWidth:cell.il_remark.frame.size.width];
        if (height<21) {
            height=21;
        }
        [cell.il_remark setFrame:CGRectMake(cell.il_remark.frame.origin.x, cell.il_remark.frame.origin.y, cell.il_remark.frame.size.width, height)];
        return cell;
    }
    
    return nil;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        return 30;
    }else{
        return 31;
    }
}
-(CGFloat)tableView:(SKSTableView *)tableView heightForSubRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.subRow==1) {
        return 30;
    }else{
        NSMutableDictionary *dic=[NSMutableDictionary dictionary];
        if (indexPath.section!=0) {
            dic=[alist_filtered_data objectAtIndex:indexPath.section-1][indexPath.subRow-1];
        }
        NSString *str=[dic valueForKey:@"remark"];
        CGFloat height=[cal_obj fn_heightWithString:str font:[UIFont systemFontOfSize:15.0f] constrainedToWidth:200.0f];
        if (height<21) {
            height=21;
        }
        return height+35;
    }
}
-(void)setExtraCellLineHidden
{
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [self.skstableview setTableFooterView:view];
}
@end
