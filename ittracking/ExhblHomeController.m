
//
//  ExhblHomeController.m
//  worldtrans
//
//  Created by itdept on 2/24/14.
//  Copyright (c) 2014 itdept. All rights reserved.
//

#import "ExhblHomeController.h"
#import "ExhblGeneralController.h"
#import "MilestoneController.h"
#import "CarrierMilestoneViewController.h"
#import "DB_sypara.h"
@interface ExhblHomeController ()

@end
@implementation ExhblHomeController

@synthesize segmentedControl;
@synthesize contentView;
@synthesize currentViewController;
@synthesize is_search_column;
@synthesize is_search_value;

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
    [self fn_isShow_carrierMilestone];
    // for adjust segment widths based on their content widths
    [self.segmentedControl setApportionsSegmentWidthsByContent:YES];
    
    // add viewController so you can switch them later.
    UIViewController *vc = [self viewControllerForSegmentIndex:self.segmentedControl.selectedSegmentIndex];
    [self addChildViewController:vc];
    self.contentView.frame=CGRectMake(CGRectGetMinX(self.contentView.frame), CGRectGetMinY(self.contentView.frame), [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-CGRectGetMinY(self.contentView.frame));
    vc.view.frame=self.contentView.bounds;
    [self.contentView addSubview:vc.view];
    self.currentViewController = vc;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)fn_isShow_carrierMilestone{
    DB_sypara *db_sypara=[[DB_sypara alloc]init];
    NSMutableArray *arr_sypara=[db_sypara fn_get_sypara_data];
    NSInteger flag_isShow=0;
    for (NSMutableDictionary *dic in arr_sypara) {
        NSString *para_code=[Common_methods fn_cut_whitespace:[dic valueForKey:@"para_code"]];
        NSString *data1=[dic valueForKey:@"data1"];
        if ([para_code isEqualToString:@"ANDRDHASCARRMS"]&&[data1 isEqualToString:@"1"]) {
            flag_isShow=1;
        }
    }
    if (flag_isShow==0) {
        [segmentedControl removeSegmentAtIndex:2 animated:NO];
        [segmentedControl setFrame:CGRectMake(segmentedControl.frame.origin.x, segmentedControl.frame.origin.y, 140, segmentedControl.frame.size.height)];
    }
}

- (UIViewController *)viewControllerForSegmentIndex:(NSInteger)index {
    
    ExhblGeneralController *vc;
    MilestoneController *a;
    CarrierMilestoneViewController *carrierVC;
    switch (index) {
        case 0:
            vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ExhblGeneralController"];
            vc.is_search_value = self.is_search_value;
            vc.is_search_column = self.is_search_column;
            return vc;
            break;
        case 1:
            a = [self.storyboard instantiateViewControllerWithIdentifier:@"MilestoneController"];
            if ([vc.is_search_column rangeOfString:@"so"].location>0) {
                a.is_docu_type = @"exso";
            } else {
                a.is_docu_type = @"exhbl";
            }
            a.is_docu_uid = self.is_search_value;
            
            return a;
            break;
        case 2:
            carrierVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CarrierMilestoneViewController"];
            carrierVC.idic_detail=_idic_exhbl;
            return carrierVC;
            break;
    }
    return vc;
}

- (IBAction)segmentChanged:(UISegmentedControl *)sender {
    UIViewController *vc = [self viewControllerForSegmentIndex:sender.selectedSegmentIndex];
    [self addChildViewController:vc];
    [self transitionFromViewController:self.currentViewController toViewController:vc duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [self.currentViewController.view removeFromSuperview];
        vc.view.frame = self.contentView.bounds;
        [self.contentView addSubview:vc.view];
    } completion:^(BOOL finished) {
        [vc didMoveToParentViewController:self];
        [self.currentViewController removeFromParentViewController];
        self.currentViewController = vc;
    }];
    self.navigationItem.title = vc.title;
}
@end
