//
//  ExhblHomeController.h
//  worldtrans
//
//  Created by itdept on 2/24/14.
//  Copyright (c) 2014 itdept. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExhblHomeController : UIViewController

@property (nonatomic, strong) UIViewController *currentViewController;
@property (nonatomic, strong) NSMutableDictionary *idic_exhbl;

@property(nonatomic,copy) NSString *is_search_column;
@property(nonatomic,copy) NSString *is_search_value;

@property (nonatomic,weak) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic,weak) IBOutlet UIView *contentView;

- (IBAction)segmentChanged:(UISegmentedControl *)sender;

@end


