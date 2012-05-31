//
//  UITableViewCell+enumToStyle.m
//  OttrJam
//
//  Created by Denis Smirnov on 12-05-30.
//  Copyright (c) 2012 Leetr.com. All rights reserved.
//

#import "UITableViewCell+cellTypeToString.h"

@implementation UITableViewCell (cellTypeToString)

+ (NSString *)cellTypeToString:(UITableViewCellStyle)style
{
    switch (style) {
        case UITableViewCellStyleDefault:
            return @"UITableViewCellStyleDefault";
            break;
        
        case UITableViewCellStyleSubtitle:
            return @"UITableViewCellStyleSubtitle";
            break;
            
        case UITableViewCellStyleValue1:
            return @"UITableViewCellStyleValue1";
            break;
            
        case UITableViewCellStyleValue2:
            return @"UITableViewCellStyleValue2";
            break;
        default:
            break;
    }
    return nil;
}

@end
