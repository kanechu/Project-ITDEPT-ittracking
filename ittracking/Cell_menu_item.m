//
//  Cell_menu_item.m
//  worldtrans
//
//  Created by itdept on 28/3/14.
//  Copyright (c) 2014 itdept. All rights reserved.
//

#import "Cell_menu_item.h"

@implementation Cell_menu_item
@synthesize ilb_label;
@synthesize itemButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)layoutSubviews{
    [super layoutSubviews];
    //生成圆角图片，值越大，越圆
    itemButton.layer.cornerRadius=7;
}
@end
