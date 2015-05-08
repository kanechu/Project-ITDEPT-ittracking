//
//  ExhblViewController.m
//  worldtrans
//
//  Created by itdept on 2/12/14.
//  Copyright (c) 2014 itdept. All rights reserved.
//

#import "ExhblListController.h"
#import "RespExhbl.h"
#import "Cell_exhbl_list.h"
#import "ExhblHomeController.h"
#import "ExhblGeneralController.h"
#import "MBProgressHUD.h"
#import "DB_login.h"
#import "Web_base.h"

@interface ExhblListController ()
@property (strong,nonatomic) NSMutableArray *ilist_exhbl;
@end

@implementation ExhblListController
@synthesize ilist_exhbl;
@synthesize iSearchBar;
@synthesize is_search_no;

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
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = iSearchBar.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor blackColor]CGColor], (id)[[UIColor whiteColor]CGColor], nil];
    [iSearchBar.layer insertSublayer:gradient atIndex:0];
    self.view.backgroundColor = [UIColor blackColor];
    iSearchBar.delegate = (id)self;
    [self setExtraCellLineHidden];
    CheckNetWork *check_obj=[[CheckNetWork alloc]init];
    if ([check_obj fn_isPopUp_alert]==NO) {
        [self fn_get_data:is_search_no];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableViewDataSource 
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [ilist_exhbl count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *ls_TableIdentifier = @"cell_exhbl_list";
    
    Cell_exhbl_list *cell = (Cell_exhbl_list *)[self.tableView dequeueReusableCellWithIdentifier:ls_TableIdentifier];
    NSMutableDictionary *ldict_dictionary = [ilist_exhbl objectAtIndex:indexPath.row];
    // Configure Cell
    if( [indexPath row] % 2)
        [cell setBackgroundColor:COLOR_DARK_JUNGLE_GREEN];
    else
        [cell setBackgroundColor:COLOR_EERIE_BLACK];
    
    cell.ilb_hbl_no.text = [NSString nullConvertEmpty:[ldict_dictionary valueForKey:@"hbl_no"]];

    cell.ilb_so_no.text = [NSString nullConvertEmpty:[ldict_dictionary valueForKey:@"so_no"]];
    cell.ilb_load_port.text = [NSString nullConvertEmpty:[ldict_dictionary valueForKey:@"load_port"]];
    cell.ilb_dest_port.text = [NSString nullConvertEmpty: [ldict_dictionary valueForKey:@"dest_name"]];
    cell.ilb_status_desc.text = [NSString nullConvertEmpty:[ldict_dictionary valueForKey:@"status_desc"]];
    NSString *str=nil;
    if ([[ldict_dictionary valueForKey:@"etd"] length]==0 || [[ldict_dictionary valueForKey:@"eta"] length]==0) {
        str=[NSString stringWithFormat:@"%@%@", [ldict_dictionary valueForKey:@"etd"], [ldict_dictionary valueForKey:@"eta"]];
    }else{
        str=[NSString stringWithFormat:@"%@/%@", [ldict_dictionary valueForKey:@"etd"], [ldict_dictionary valueForKey:@"eta"]];
    }
    cell.ilb_date.text =[NSString nullConvertEmpty:str];
    
    return cell;
}
#pragma mark UITableViewDelegate

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    static NSString *CellIdentifier = @"cell_exhbl_header";
    UITableViewCell *headerView = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (headerView == nil){
        [NSException raise:@"headerView == nil.." format:@"No cells with matching CellIdentifier loaded from your storyboard"];
    }
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 1 )
        return 0.000001f;
    else return 80; // put 22 in case of plain one..
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

- (void)tableView: (UITableView *)tableView
didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"segue_exhbl_home" sender:self];
}
#pragma mark - set footview
- (void)setExtraCellLineHidden
{
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [self.tableView setTableFooterView:view];
    [self.tableView setScrollEnabled:YES];
}
-(void)fn_show_no_data_msg{
    Custom_backgroundView *bg_view=[[Custom_backgroundView alloc]initWithFrame:self.view.frame];
    bg_view.str_msg=@"No Sea Export Data";
    bg_view.flag_bgView_type=kBgView_alert;
    [self.tableView setTableFooterView:bg_view];
    [self.tableView setScrollEnabled:NO];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSString *ls_hbl_uid = @"";
    NSString *ls_so_uid = @"";
    NSString *ls_os_column = @"";
    NSString *ls_os_value = @"";
    NSIndexPath *selectedRowIndex = [self.tableView indexPathForSelectedRow];
    
    NSMutableDictionary *ldict_dictionary = [ilist_exhbl objectAtIndex:selectedRowIndex.row];    // Configure Cell
    ls_hbl_uid = [ldict_dictionary valueForKey:@"hbl_uid"];
    ls_so_uid = [ldict_dictionary valueForKey:@"so_uid"];
    
    if ([ls_hbl_uid length] > 0) {
        ls_os_column = @"hbl_uid";
        ls_os_value = ls_hbl_uid;
    }
    else {
        
        ls_os_column = @"so_uid";
        ls_os_value = ls_so_uid;
    }
    
    if ([[segue identifier] isEqualToString:@"segue_exhbl_home"]) {
        ExhblHomeController *exhblHomeController = [segue destinationViewController];
        exhblHomeController.is_search_column = ls_os_column;
        exhblHomeController.is_search_value = ls_os_value;
        exhblHomeController.idic_exhbl=ldict_dictionary;
    }
}
#pragma mark NetWork Request
- (void) fn_get_data: (NSString*)as_search_no
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    RequestContract *req_form = [[RequestContract alloc] init];
    
    DB_login *dbLogin=[[DB_login alloc]init];
    req_form.Auth =[dbLogin WayOfAuthorization];
    SearchFormContract *search = [[SearchFormContract alloc]init];
    search.os_column = @"search_no";
    search.os_value = as_search_no;
    
    req_form.SearchForm = [NSSet setWithObjects:search, nil];
    
    Web_base *web_base = [[Web_base alloc] init];
    web_base.il_url =STR_SEA_URL;
    web_base.base_url=[dbLogin fn_get_field_content:kWeb_addr];
    web_base.iresp_class =[RespExhbl class];
   
    web_base.ilist_resp_mapping =[NSArray arrayWithPropertiesOfObject:[RespExhbl class]];
    web_base.callBack=^(NSMutableArray *alist_result,BOOL isTimeOut){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (isTimeOut) {
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:nil message:@"Network request timed out, retry or cancel the request ?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Retry", nil];
            [alertView show];
        }else{
            ilist_exhbl = alist_result;
            if ([alist_result count]==0) {
                [self fn_show_no_data_msg];
            }
            [self.tableView reloadData];
        }
    };
    [web_base fn_get_data:req_form];
    req_form=nil;
    dbLogin=nil;
    search=nil;
    web_base=nil;
    
}

#pragma mark -UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex!=[alertView cancelButtonIndex]) {
        CheckNetWork *check_obj=[[CheckNetWork alloc]init];
        if ([check_obj fn_isPopUp_alert]==NO) {
            if ([iSearchBar.text length]==0) {
                [self fn_get_data:is_search_no];
                
            }else{
                [self fn_get_data:iSearchBar.text];
            }
        }
        check_obj=nil;
    }
}
#pragma mark UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self handleSearch:searchBar];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    NSLog(@"User canceled search");
    [searchBar resignFirstResponder]; // if you want the keyboard to go away
}
- (void)handleSearch:(UISearchBar *)searchBar {
    CheckNetWork *check_obj=[[CheckNetWork alloc]init];
    if ([check_obj fn_isPopUp_alert]==NO) {
        [self fn_get_data:searchBar.text];
    }
    // if you want the keyboard to go away
    [searchBar resignFirstResponder];
    
}

@end
