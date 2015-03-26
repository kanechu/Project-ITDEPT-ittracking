//
//  MainHomeViewController.m
//  worldtrans
//
//  Created by itdept on 14-3-28.
//  Copyright (c) 2014年 itdept. All rights reserved.
//

#import "MainHomeViewController.h"
#import "LoginViewController.h"
#import "MZFormSheetController.h"
#import "Web_base.h"
#import "Web_get_alert.h"
#import "DB_login.h"
#import "DB_alert.h"
#import "DB_sypara.h"
#import "CustomBadge.h"
#import "Menu_home.h"
#import "Cell_menu_item.h"
#import "LogoutViewController.h"
#import "TrackHomeController.h"
#import "AlertController.h"
#import "DB_portName.h"
#import "PopViewManager.h"
#import "NSDictionary.h"
@interface MainHomeViewController ()

@end
#define LOGINSHEETSIZE CGSizeMake(280, 220)
#define SHEETSIZE1 CGSizeMake(280, 250)
#define SHEETSIZE2 CGSizeMake(280, 180)

@implementation MainHomeViewController
@synthesize ilist_menu;
@synthesize iui_collectionview;
@synthesize badge_Num;
@synthesize menu_item;
CustomBadge *iobj_customBadge;

-(id)initWithCoder:(NSCoder *)aDecoder{
    self=[super initWithCoder:aDecoder];
    if (self) {
        //[self fn_get_allIcon];
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self fn_refresh_menu];
    [self fn_isLogin_ITTracking];
    [_loginBtn addTarget:self action:@selector(fn_logout_ITTracking:) forControlEvents:UIControlEventTouchUpInside];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self gettingNotification];
        dispatch_async( dispatch_get_main_queue(), ^{
            
            [NSTimer scheduledTimerWithTimeInterval: 120.0 target: self
                                           selector: @selector(gettingNotification) userInfo: nil repeats: YES];
            // Add code here to update the UI/send notifications based on the
            // results of the background processing
            
        });
    });
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)gettingNotification {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //background task here
        Web_get_alert *web_get_alert =[Web_get_alert fn_get_shareInstance];
        web_get_alert.callBack=^(NSMutableArray *alist_result,BOOL isTimeOut){
            DB_alert * ldb_alert = [[DB_alert alloc] init];
            [ldb_alert fn_save_data:alist_result];
        };
        NSUserDefaults *user_isLogin=[NSUserDefaults standardUserDefaults];
        NSInteger flag_isLogin=[user_isLogin integerForKey:@"isLogin"];
        if (flag_isLogin==1) {
            [web_get_alert fn_get_data];
        }
        dispatch_async( dispatch_get_main_queue(), ^{
            // update UI here
            [self fn_set_unread_msg_badge];
        });
    });
}
- (void)fn_set_unread_msg_badge{
    DB_alert * ldb_alert = [[DB_alert alloc] init];
    NSInteger li_alert_count = [ldb_alert fn_get_unread_msg_count];
    [iobj_customBadge removeFromSuperview];
    iobj_customBadge = nil;
    badge_Num=li_alert_count;
    [iui_collectionview reloadData];
}
#pragma mark function options
- (void) fn_refresh_menu;
{
    ilist_menu = [[NSMutableArray alloc] init];
    [ilist_menu addObject:[Menu_home fn_create_item:@"Tracking" image:@"ic_ct" segue:@"segue_trackHome"]];
    [ilist_menu addObject:[Menu_home fn_create_item:@"Alert" image:@"alert" segue:@"segue_alert"]];
    [ilist_menu addObject:[Menu_home fn_create_item:@"Schedule" image:@"schedule_icon" segue:@"Segue_ExpandSearch"]];
    self.iui_collectionview.delegate = self;
    
    self.iui_collectionview.dataSource = self;
    
    [self.iui_collectionview registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell_menu"];
    
    [iobj_customBadge removeFromSuperview];
    iobj_customBadge = nil;
    
    [self.iui_collectionview reloadData];
}
- (IBAction)fn_menu_btn_clicked:(id)sender {
    UIButton *button=(UIButton*)sender;
    //button.tag用来区分点击那个Item
    menu_item=[ilist_menu objectAtIndex:button.tag];
    [self performSegueWithIdentifier:menu_item.is_segue sender:self];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(fn_set_unread_msg_badge) name:@"update" object:nil];
}

//登陆后显示logo图片
-(void)fn_show_user_logo{
    DB_login *dbLogin=[[DB_login alloc]init];
    NSString *logo=@"";
    if ([[dbLogin fn_get_all_msg]count]!=0) {
        logo= [[[dbLogin fn_get_all_msg] objectAtIndex:0] valueForKey:@"user_logo"];
    }
    //如果logo为空的话，是不能进行Base64编码的，需进行容错处理
    if (logo==NULL || logo==nil || logo.length==0) {
        _imageView.image=nil;
    }else{
        NSData *data=[[NSData alloc]initWithBase64EncodedString:logo options:0];
        _imageView.image=[UIImage imageWithData:data];
    }
    
}
//实现按钮的图文混排
-(void)fn_BtnGraphicMixed:(NSString*)user_code{
    [_loginBtn setTitle:user_code forState:UIControlStateNormal];
    [_loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_loginBtn setImage:[UIImage imageNamed:@"userImage"] forState:UIControlStateNormal];
    if ([user_code length]<=2) {
        [_loginBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -50, 0, 0)];        }
    else if([user_code length]<16){
        NSInteger left=-(45+(user_code.length-2)/2*10+30);
        [_loginBtn setTitleEdgeInsets:UIEdgeInsetsMake(0,left , 0, 0)];
    }else{
        [_loginBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -150, 0, 0)];
    }
    [_loginBtn setImageEdgeInsets:UIEdgeInsetsMake(0, _loginBtn.frame.size.width-35, 0, 0)];
    
}
- (void)fn_isLogin_ITTracking{
    NSUserDefaults *user_isLogin=[NSUserDefaults standardUserDefaults];
    NSInteger flag_isLogin=[user_isLogin integerForKey:@"isLogin"];
    if (flag_isLogin==0) {
        LoginViewController *VC=[self.storyboard instantiateViewControllerWithIdentifier:@"Login"];
        VC.callBack=^(NSString* user_id){
            [self fn_after_login:user_id];
        };
        [self presentViewController:VC animated:NO completion:nil];
    }else{
        DB_login *dbLogin=[[DB_login alloc]init];
        NSString *user_code=[[[dbLogin fn_get_all_msg]firstObject]valueForKey:@"user_code"];
        [self fn_show_user_logo];
        [self fn_BtnGraphicMixed:user_code];
    }
}
#pragma mark -user logout
- (void)fn_logout_ITTracking:(id)sender {
    DB_login *dbLogin=[[DB_login alloc]init];
    PopViewManager *popV=[[PopViewManager alloc]init];
    //点击用户名称项，执行下面的语句
    LogoutViewController *VC=[self.storyboard instantiateViewControllerWithIdentifier:@"Logout"];
    VC.callback=^(){
        [self fn_user_logout];
        
    };
    NSString *logo=@"";
    if ([[dbLogin fn_get_all_msg]count]!=0) {
        logo=[[[dbLogin fn_get_all_msg] objectAtIndex:0] valueForKey:@"user_logo"];
    }
    //如果logo为空的话，弹出的视图size变小
    if (logo==NULL || logo==nil || logo.length==0) {
        [popV PopupView:VC Size:SHEETSIZE2 uponView:self];
    }else{
        [popV PopupView:VC Size:SHEETSIZE1 uponView:self];
    }
    
}
//登录成功后，导航的按钮项显示为用户的名称
-(void)fn_after_login:(NSString*)userName{
    
    [self fn_BtnGraphicMixed:userName];
    //登陆后显示logo图片
    [self fn_show_user_logo];
}
//退出登录后
- (void)fn_user_logout{
    
    DB_login *dbLogin=[[DB_login alloc]init];
    [dbLogin fn_delete_record];
    _imageView.image=nil;
    //清除portName的缓存
    DB_portName *db=[[DB_portName alloc]init];
    [db fn_delete_all_data];
    //清除sypara的缓存
    DB_sypara *db_sypara=[[DB_sypara alloc]init];
    [db_sypara fn_delete_all_sypara_data];
    LoginViewController *VC=[self.storyboard instantiateViewControllerWithIdentifier:@"Login"];
    VC.callBack=^(NSString* user_id){
        [self fn_after_login:user_id];
    };
    [self presentViewController:VC animated:YES completion:nil];
    VC=nil;
}

#pragma mark - UICollectionView Datasource
// 1
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    
    return [self.ilist_menu count];
}
// 一个collectionView中的分区数
- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}
// 3
- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    Cell_menu_item *cell = [cv dequeueReusableCellWithReuseIdentifier:@"cell_menu_item" forIndexPath:indexPath];
    NSInteger li_item = [indexPath item];
    menu_item =  [ilist_menu objectAtIndex:li_item];
    cell.ilb_label.text = menu_item.is_label;
    [cell.itemButton setImage:[UIImage imageNamed:menu_item.is_image] forState:UIControlStateNormal];
    cell.itemButton.tag=indexPath.item;
    
    if (li_item == 1) {
        
        iobj_customBadge=[CustomBadge customBadgeWithString:@(badge_Num).stringValue withStringColor:[UIColor whiteColor] withInsetColor:[UIColor redColor] withBadgeFrame:YES withBadgeFrameColor:[UIColor whiteColor] withScale:0.7 withShining:YES];
        [iobj_customBadge setFrame:CGRectMake(cell.itemButton.frame.size.width-iobj_customBadge.frame.size.width+4,cell.itemButton.frame.origin.y-12, iobj_customBadge.frame.size.width-5, iobj_customBadge.frame.size.height-5)];
        DB_login *dbLogin=[[DB_login alloc]init];
        //登陆后和有新通知的时候，才显示badge
        if ([dbLogin isLoginSuccess]) {
            if (badge_Num>0) {
                [cell.itemButton addSubview:iobj_customBadge];
            }
            else
            {
                [iobj_customBadge removeFromSuperview];
                iobj_customBadge = nil;
            }
        }
        
    }
    return cell;
}

-(BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

#pragma mark – UICollectionViewDelegateFlowLayout


// 3
- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
        
    return UIEdgeInsetsMake(0, 5, 0, 13);
   
}

@end
