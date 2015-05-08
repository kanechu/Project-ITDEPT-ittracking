//
//  Custom_backgroundView.m
//  worldtrans
//
//  Created by itdept on 14-4-29.
//  Copyright (c) 2014年 Worldtrans Logistics Services Ltd. . All rights reserved.
//

#import "Custom_backgroundView.h"
#define HEIGHT 42
@implementation Custom_backgroundView

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
// An empty implementation adversely affects performance during animation.*/
- (void)drawRect:(CGRect)rect
{
    if (_flag_bgView_type==kBgView_colorAndAlert || _flag_bgView_type==kBgView_color) {
        CGContextRef context=UIGraphicsGetCurrentContext();
        CGColorSpaceRef colorSpaceRef=CGColorSpaceCreateDeviceRGB();
        CGColorRef endColor=CGColorCreate(colorSpaceRef, (CGFloat[]){0.0f,0.0f,0.0f,1.0f});
        CGColorRef beginColor=[UIColor grayColor].CGColor;
        CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();
        CGFloat locations[]={0.0,1.0};
        NSArray *colors=[NSArray arrayWithObjects:(__bridge id)beginColor,(__bridge id)endColor,nil];
        CGGradientRef gradient=CGGradientCreateWithColors(colorSpace, (CFArrayRef)CFBridgingRetain(colors), locations);
        CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
        CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
        
        CGContextSaveGState(context);
        CGContextAddRect(context, rect);
        CGContextClip(context);
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
        CGContextRestoreGState(context);
        CGGradientRelease(gradient);
        CGColorSpaceRelease(colorSpace);
    }
}
- (void)fn_creat_label{
    UILabel *ilb_alert=[[UILabel alloc]initWithFrame:CGRectMake(0, self.frame.size.height/2-64, self.frame.size.width, HEIGHT)];
    ilb_alert.lineBreakMode=NSLineBreakByCharWrapping;
    ilb_alert.numberOfLines=0;
    ilb_alert.textAlignment=NSTextAlignmentCenter;
    ilb_alert.font=[UIFont systemFontOfSize:24];
    ilb_alert.textColor=[UIColor lightGrayColor];
    ilb_alert.text=_str_msg;
    [self addSubview:ilb_alert];
}
-(void)layoutSubviews{
    [super layoutSubviews];
    if (_flag_bgView_type==kBgView_alert || _flag_bgView_type==kBgView_colorAndAlert) {
      [self fn_creat_label];
    }
}
@end
