//
//  ExpandSearchCriteriaViewController.m
//  worldtrans
//
//  Created by itdept on 14-5-9.
//  Copyright (c) 2014年 Worldtrans Logistics Services Ltd. . All rights reserved.
//

#import "ExpandSearchCriteriaViewController.h"
#import "SKSTableView.h"
#import "SKSTableViewCell.h"
#import "DB_searchCriteria.h"
#import "DB_icon.h"
#import "Res_color.h"
#import "Cell_schedule_section1.h"
#import "Cell_schedule_section2_row1.h"
#import "Cell_schedule_section2_row3.h"

#import "ScheduleViewController.h"
#import "SearchPortNameViewController.h"
#import "KeyboardNoticeManager.h"
typedef NSString* (^pass_value)(NSInteger tag);
#define TEXTFIELD_TAG 100
@interface ExpandSearchCriteriaViewController ()
@property(nonatomic,strong)pass_value passValue;
//存储搜索标准数据
@property(nonatomic,strong)NSMutableArray *alist_searchCriteria;
//存储搜索标准的组名和该组的行数
@property(nonatomic,strong)NSMutableArray *alist_groupNameAndNum;
//存储过滤后的搜索标准数据
@property(nonatomic,strong)NSMutableArray *alist_filtered_data;
//搜索的条件，放到一个字典中
@property (strong,nonatomic) NSMutableDictionary *imd_searchDic;
//显示的内容，放到一个字典中
@property (strong,nonatomic) NSMutableDictionary *imd_displayDic;
@end

static NSInteger day=0;

@implementation ExpandSearchCriteriaViewController
@synthesize checkText;
@synthesize ia_listData;
@synthesize ipic_drop_view;
@synthesize ilist_dateType;
@synthesize imd_searchDic;
@synthesize idp_picker;
@synthesize id_startdate;
@synthesize select_row;
@synthesize skstableView;
@synthesize alist_searchCriteria;
@synthesize alist_groupNameAndNum;
@synthesize alist_filtered_data;
@synthesize alist_icon;
@synthesize imd_displayDic;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
       
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder{
    self=[super initWithCoder:aDecoder];
    if (self) {
        //ios7的navigation不占位置，所以scollview自动空出一个nav的高度
        if ([[[UIDevice currentDevice]systemVersion]floatValue]>=7.0) {
            
            if ([self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)]) {
                self.automaticallyAdjustsScrollViewInsets = NO;
            }
        }
       
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self fn_init_global_Variable];
    [self fn_sort_criteriaData];
    self.skstableView.SKSTableViewDelegate=self;
    //创建一个UIDatePicker
    [self fn_create_datePick];
    
    //创建一个UIPickerView
    [self fn_create_pickerView];
    [self fn_create_image];
    
    [self fn_get_searchCriteria_data];
    //注册通知
    //[self fn_register_notifiction];
    [KeyboardNoticeManager sharedKeyboardNoticeManager];
    //loadview的时候，打开所有expandable
    [self.skstableView fn_expandall];
    
    [self setExtraCellLineHidden:skstableView];
   	// Do any additional setup after loading the view.
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark 对数组进行排序
-(void)fn_sort_criteriaData{
    //如果需要降序，那么将ascending由YES改为NO
    NSSortDescriptor *sortByName1=[NSSortDescriptor sortDescriptorWithKey:@"seq" ascending:YES];
    
    NSArray *sortDescriptors=[NSArray arrayWithObjects:sortByName1,nil];
    NSMutableArray *sortedArray=[[alist_searchCriteria sortedArrayUsingDescriptors:sortDescriptors]mutableCopy];
    //重新排序后，存回给原来的数组
    alist_searchCriteria=sortedArray;
}
#pragma mark 对数组进行过滤
-(NSArray*)fn_filtered_criteriaData:(NSString*)key{
    NSArray *filtered=[alist_searchCriteria filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(group_name==%@)",key]];
    return filtered;
}

-(void)fn_init_global_Variable{
    DB_searchCriteria *db=[[DB_searchCriteria alloc]init];
    alist_searchCriteria=[db fn_get_all_data];
    alist_groupNameAndNum=[db fn_get_groupNameAndNum];
    DB_icon *db_icon=[[DB_icon alloc]init];
    alist_icon=[db_icon fn_get_all_iconData];
    imd_searchDic=[[NSMutableDictionary alloc]initWithCapacity:10];
    imd_displayDic=[[NSMutableDictionary alloc]initWithCapacity:1];
    ilist_dateType=[[NSMutableArray alloc]initWithCapacity:10];
    ia_listData=[[NSMutableArray alloc]initWithCapacity:10];
    alist_filtered_data=[[NSMutableArray alloc]initWithCapacity:10];
    for (NSMutableDictionary *dic in alist_groupNameAndNum) {
        NSString *str=[dic valueForKey:@"group_name"];
        NSArray *arr=[self fn_filtered_criteriaData:str];
        if (arr!=nil) {
            [alist_filtered_data addObject:arr];
        }
    }
}

//将额外的cell的线隐藏
- (void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}
//截取搜索标准的有用数据
-(void)fn_get_searchCriteria_data{
    DB_searchCriteria *db=[[DB_searchCriteria alloc]init];
    if ([db fn_get_all_data].count!=0) {
        _ibt_search_btn.hidden=NO;
    }
    for (NSMutableDictionary *dic in [db fn_get_all_data]) {
        //获取date Range默认的天数
        if ([[dic valueForKey:@"col_type"] isEqualToString:@"int"]) {
            day=[[dic valueForKey:@"col_def"] integerValue];
            NSString *col_code=[dic valueForKey:@"col_code"];
            if ([col_code length]!=0) {
                [imd_displayDic setObject:@(day).stringValue forKey:col_code];
                [imd_searchDic setObject:[self fn_get_finishDate:day]forKey:col_code];
            }
            
        }
        //获取option 的数据
        if ([[dic valueForKey:@"col_type"] isEqualToString:@"combo"]) {
            NSString *str=[dic valueForKey:@"col_option"];
            //date type display
            NSArray *option=[str componentsSeparatedByString:@";"];
            NSArray *option1=nil;
            for (NSString *str in option) {
                option1=[str componentsSeparatedByString:@":"];
                if (option1.count>=2) {
                    //date type display
                    [ia_listData addObject:[option1 objectAtIndex:0]];
                    //value
                    [ilist_dateType addObject:[option1 objectAtIndex:1]];
                }
            }
            NSString *col_def=[dic valueForKey:@"col_def"];
            NSInteger i=0;
            for (NSString *str in ilist_dateType) {
                if ([str isEqualToString:col_def]) {
                    break;
                }
                i++;
            }
            if ([col_def length]!=0) {
                [imd_searchDic setObject:col_def forKey:[dic valueForKey:@"col_code"]];
                [imd_displayDic setObject:[ia_listData objectAtIndex:i] forKey:[dic valueForKey:@"col_code"]];
            }
        }
    }
}

-(void)fn_create_image{
    UIImageView *image=[[UIImageView alloc]initWithFrame:CGRectMake(_ibt_search_btn.frame.origin.x+10, 5, 30, _ibt_search_btn.frame.size.height-10)];
    image.image=[UIImage imageNamed:@"search"];
    [_ibt_search_btn addSubview:image];
    
}
#pragma mark UItextfieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField{
     checkText = textField;//设置被点击的对象
}
#pragma mark create toolbar
-(UIToolbar*)fn_create_toolbar{
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [toolbar setBarStyle:UIBarStyleBlackOpaque];
    [toolbar sizeToFit];
    UIBarButtonItem *buttonflexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *buttonDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(fn_Click_done:)];
    
    [toolbar setItems:[NSArray arrayWithObjects:buttonflexible,buttonDone, nil]];
    return toolbar;
}
-(void)fn_Click_done:(id)sender{
    [self.skstableView reloadData];
}
#pragma mark pickerView
-(void)fn_create_pickerView{
    ipic_drop_view=[[UIPickerView alloc]initWithFrame:CGRectMake(0, 225, 0,0)];
    [ipic_drop_view setAutoresizingMask:(UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight)];
    ipic_drop_view.delegate=self;
    //显示选中框
    ipic_drop_view.showsSelectionIndicator=YES;
    
    
}
#pragma mark UIPickerViewDataSource
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [ia_listData count];
}
#pragma mark UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [ia_listData objectAtIndex:row];
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    select_row=row;
    
}
#pragma mark UIDatePick
-(void)fn_create_datePick{
    //初始化UIDatePicker
    idp_picker=[[UIDatePicker alloc]init];
    [idp_picker setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"en"]];
    
    [idp_picker setAutoresizingMask:(UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight)];
    //设置UIDatePicker的显示模式
    [idp_picker setDatePickerMode:UIDatePickerModeDate];
    id_startdate=[idp_picker date];
    //当值发生改变的时候调用的方法
    [idp_picker addTarget:self action:@selector(fn_change_date) forControlEvents:UIControlEventValueChanged];
    
}
-(void)fn_change_date{
    //获得当前UIPickerDate所在的日期
    id_startdate=[idp_picker date];
    
}
#pragma mark sent event
- (IBAction)fn_click_portBtn:(id)sender{
    Custom_Button *Btn=(Custom_Button*)sender;
    NSString *col_code=_passValue(Btn.tag);
    NSString *str_placeholder=@"";
    if ([col_code isEqualToString:@"load_port"]) {
        str_placeholder=@"Load Port";
    }
    if ([col_code isEqualToString:@"dish_port"]) {
        str_placeholder=@"Discharge Port";
    }
    [self fn_popup_searchPortNameView:str_placeholder col_code:col_code];
}

- (IBAction)fn_end_edit_textfield:(id)sender {
    UITextField *textfield=(UITextField*)sender;
    NSString *col_code=_passValue(textfield.tag);
    if ([col_code isEqualToString:@"datetype"]) {
        [imd_searchDic setObject:[ilist_dateType objectAtIndex:select_row] forKey:col_code];
        [imd_displayDic setObject:[ia_listData objectAtIndex:select_row] forKey:col_code];
    }
    if ([col_code isEqualToString:@"date"]) {
        
        [imd_searchDic setObject:[self fn_DateToStringDate:id_startdate] forKey:col_code];
        [imd_displayDic setObject:[self fn_DateToStringDate:id_startdate] forKey:col_code];
    }
    
}
-(void)fn_popup_searchPortNameView:(NSString*)placeholder col_code:(NSString*)col_code{
    SearchPortNameViewController *VC=(SearchPortNameViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"SearchPortNameViewController"];
    VC.callBack=^(NSMutableDictionary *idic_name){
        [imd_searchDic setObject:[idic_name valueForKey:@"data"] forKey:col_code];
        [imd_displayDic setObject:[idic_name valueForKey:@"display"] forKey:col_code];
        [self.skstableView reloadData];
    };
    VC.is_placeholder=placeholder;
    [self presentViewController:VC animated:YES completion:nil];
}

- (IBAction)fn_click_subBtn:(id)sender {
    day--;
    if (day<0) {
        day=0;
    }
    UIButton *ibtn=(UIButton*)sender;
    NSString *col_code=_passValue(ibtn.tag);
    [imd_searchDic setObject:@(day).stringValue forKey:col_code];
    [imd_displayDic setObject:@(day).stringValue forKey:col_code];
    [self.skstableView reloadData];
}

- (IBAction)fn_click_addBtn:(id)sender {
    day++;
    UIButton *ibtn=(UIButton*)sender;
    NSString *col_code=_passValue(ibtn.tag);
    [imd_searchDic setObject:@(day).stringValue forKey:col_code];
    [imd_displayDic setObject:@(day).stringValue forKey:col_code];
    [self.skstableView reloadData];
}
//输入天数结束的时候(endEdit)，触发的方法
- (IBAction)fn_click_day:(id)sender {
    UITextField *textfield=(UITextField*)sender;
    NSString *col_code=_passValue(textfield.tag);
    day=[textfield.text integerValue];
    if ([[self fn_get_finishDate:day]length]!=0) {
        [imd_searchDic setObject:[self fn_get_finishDate:day]forKey:col_code];
    }
    [imd_displayDic setObject:@(day).stringValue forKey:col_code];
    [self.skstableView reloadData];
}

- (IBAction)fn_begin_click_day:(id)sender {
    UITextField *textfield=(UITextField*)sender;
    textfield.inputAccessoryView=[self fn_create_toolbar];
}

#pragma mark 开始日期加天数，得结束日期
-(NSString*)fn_get_finishDate:(NSInteger)_days{
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSTimeInterval interval=60*60*24*_days;
    NSString *finishDate=[formatter stringFromDate:[id_startdate initWithTimeInterval:interval sinceDate:id_startdate]];
    return finishDate;
}
#pragma mark DateToStringDate
-(NSString*)fn_DateToStringDate:(NSDate*)date{
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *str=[dateFormatter stringFromDate:date];
    return str;
}

#pragma mark segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segue_Schedule"]) {
        ScheduleViewController *VC=[segue destinationViewController];
        VC.imd_searchDic=self.imd_searchDic;
    }
    
}

#pragma mark 点击search按钮后，开始按条件获取数据
- (IBAction)fn_click_searchBtn:(id)sender {
    
    NSInteger flag=0;
    for (NSMutableDictionary *dic in alist_searchCriteria) {
        if ([[dic valueForKey:@"is_mandatory"] isEqualToString:@"1"]) {
            if ([[imd_searchDic valueForKey:[dic valueForKey:@"col_code"]] length]==0) {
                flag++;
            }
            if (flag==1) {
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@ cannot be empty!",[dic valueForKey:@"col_label"]] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alert show];
                break;
            }
        }
    }
    if (flag==0) {
        [self performSegueWithIdentifier:@"segue_Schedule" sender:self];
    }
    
}
#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [alist_groupNameAndNum count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)tableView:(SKSTableView *)tableView numberOfSubRowsAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *numOfrow=[[alist_groupNameAndNum objectAtIndex:indexPath.section] valueForKey:@"COUNT(group_name)"];
    return [numOfrow integerValue];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SKSTableViewCell";
    SKSTableViewCell *cell = [self.skstableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
        cell = [[SKSTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    //设置文本字体的颜色
    cell.textLabel.textColor=COLOR_PINK;
    cell.textLabel.font=[UIFont systemFontOfSize:15];
    cell.textLabel.text =[[alist_groupNameAndNum objectAtIndex:indexPath.section] valueForKey:@"group_name"];
    cell.expandable = YES;
    return cell;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForSubRowAtIndexPath:(NSIndexPath *)indexPath
{
    //提取每行的数据
    NSMutableDictionary *dic=alist_filtered_data[indexPath.section][indexPath.subRow-1];
    //显示的提示名称
    NSString *col_label=[dic valueForKey:@"col_label"];
    //传上服务器的volumn
    NSString *col_code=[dic valueForKey:@"col_code"];
    //类型，用于判断使用的cell
    NSString *col_type=[dic valueForKey:@"col_type"];
    //每行的显示的图片
    NSString *icon_name=[dic valueForKey:@"icon_name"];
    __block ExpandSearchCriteriaViewController *blockSelf=self;
    _passValue=^NSString*(NSInteger tag){
        NSMutableDictionary *dic=blockSelf->alist_filtered_data[tag/100-1][tag-TEXTFIELD_TAG-(tag/100-1)*100];
        return [dic valueForKey:@"col_code"];
    };
    if ([col_type isEqualToString:@"LOOKUP"] || [col_type isEqualToString:@"lookup"]) {
        
        static NSString *CellIdentifier = @"Cell_schedule_section11";
        Cell_schedule_section1 *cell = [self.skstableView dequeueReusableCellWithIdentifier:CellIdentifier ];
        if (cell==nil) {
            cell=[[Cell_schedule_section1 alloc]init];
        }
        UIImage *nav_img=[UIImage imageWithData:[self fn_get_imageData:icon_name]];
        cell.im_navigate_img.image=nav_img;
        if (nav_img==nil) {
            if ([col_code isEqualToString:@"load_port"]) {
                cell.im_navigate_img.image=[UIImage imageNamed:@"navigate-up"];
            }else if([col_code isEqualToString:@"dish_port"]){
                cell.im_navigate_img.image=[UIImage imageNamed:@"navigate-down"];
            }
        }
        cell.ilb_port.text=col_label;
        cell.ilb_show_portName.tag=TEXTFIELD_TAG+indexPath.section*100+indexPath.subRow-1;
        cell.ilb_show_portName.label.text=[imd_displayDic valueForKey:col_code];
        return cell;
    }
    
    if ([col_type isEqualToString:@"combo"] || [col_type isEqualToString:@"date"]){
        static NSString *CellIdentifier = @"Cell_schedule_section2_row11";
        Cell_schedule_section2_row1 *cell = [self.skstableView dequeueReusableCellWithIdentifier:CellIdentifier ];
        if (cell==nil) {
            cell=[[Cell_schedule_section2_row1 alloc]init];
        }
        cell.itf_show_dateType.delegate=self;
        cell.ilb_show_dateAndtype.text=col_label;
        cell.itf_show_dateType.tag=TEXTFIELD_TAG+indexPath.section*100+indexPath.subRow-1;
        UIImage *combo_img=[UIImage imageWithData:[self fn_get_imageData:icon_name]];
        if(combo_img==nil){
            combo_img=[UIImage imageNamed:@"ic_date"];
        }
        cell.ii_calendar_img.image=combo_img;
        cell.itf_show_dateType.text=[imd_displayDic valueForKey:col_code];
            ;
        if ([col_type isEqualToString:@"combo"]) {
            cell.itf_show_dateType.inputView=ipic_drop_view;
            cell.itf_show_dateType.inputAccessoryView=[self fn_create_toolbar];
        }
        if ([col_type isEqualToString:@"date"]) {
            cell.itf_show_dateType.inputView=idp_picker;
            cell.itf_show_dateType.inputAccessoryView=[self fn_create_toolbar];
            NSString *str_date=[self fn_DateToStringDate:id_startdate];
            cell.itf_show_dateType.text=str_date;
            [imd_searchDic setObject:str_date forKey:col_code];
        }
        return cell;
    }
    if ([col_type isEqualToString:@"int"]) {
        static NSString *CellIdentifier = @"Cell_schedule_section2_row31";
        Cell_schedule_section2_row3 *cell = [self.skstableView dequeueReusableCellWithIdentifier:CellIdentifier ];
        if (cell==nil) {
            cell=[[Cell_schedule_section2_row3 alloc]init];
        }
        cell.ibt_add_btn.tag=TEXTFIELD_TAG+indexPath.section*100+indexPath.subRow-1;
        cell.ibt_decrease_btn.tag=TEXTFIELD_TAG+indexPath.section*100+indexPath.subRow-1;
        cell.ict_show_days.tag=TEXTFIELD_TAG+indexPath.section*100+indexPath.subRow-1;
        cell.ict_show_days.text=[imd_displayDic valueForKey:col_code];
        cell.ict_show_days.delegate=self;
        UIImage *add_image=[UIImage imageWithData:[self fn_get_imageData:@"int_minus"]];
        if (add_image==nil) {
            add_image=[UIImage imageNamed:@"ic_minus"];
        }
        [cell.ibt_add_btn setImage:add_image forState:UIControlStateNormal];
        UIImage *minus_image=[UIImage imageWithData:[self fn_get_imageData:@"int_add"]];
        if (minus_image==nil) {
            minus_image=[UIImage imageNamed:@"ic_add"];
        }
        [cell.ibt_decrease_btn setImage:minus_image forState:UIControlStateNormal];
        cell.ii_calendar_img.image=[UIImage imageWithData:[self fn_get_imageData:icon_name]];
        return cell;
    }
      // Configure the cell...
    return nil;
}
#pragma mark UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}
#pragma mark 遍历数组
-(NSData*)fn_get_imageData:(NSString*)str{
    for (NSMutableDictionary *dic in alist_icon) {
        if ([[dic valueForKey:@"ic_name"] isEqualToString:str]) {
            NSString *icon=[dic valueForKey:@"ic_content"];
            NSData *data=[[NSData alloc]initWithBase64EncodedString:icon options:0];
            return data;
        }
    }
    return nil;
}

@end
