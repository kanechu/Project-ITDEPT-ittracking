//
//  Common_methods.m
//  ittracking
//
//  Created by itdept on 14-11-3.
//  Copyright (c) 2014年 ittracking Logistics Services Ltd. . All rights reserved.
//

#import "Common_methods.h"

@implementation Common_methods
/**
 *  去掉字符串前后空格
 *
 *  @param str 带有前后空格的字符串
 *
 *  @return 返回没有前后空格的字符串
 */
+(NSString*)fn_cut_whitespace:(NSString*)str{
    NSString *subStr=[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return subStr;
}

@end
