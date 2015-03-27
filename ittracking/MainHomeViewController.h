//
//  MainHomeViewController.h
//  worldtrans
//
//  Created by itdept on 14-3-28.
//  Copyright (c) 2014年 itdept. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Menu_home;
@interface MainHomeViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UICollectionView *iui_collectionview;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

@property (strong,nonatomic) NSMutableArray *ilist_menu;
@property (assign,nonatomic)NSInteger badge_Num;
@property (nonatomic,weak)Menu_home *menu_item;

@end
