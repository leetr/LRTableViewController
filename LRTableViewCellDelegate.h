//
//  LRTableViewCellDelegate.h
//  Rowporter
//
//  Created by Denis Smirnov on 12-06-05.
//  Copyright (c) 2012 Leetr Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LRTableViewCellDelegate <NSObject>

- (void)tableViewCell:(UITableViewCell *)cell didSelectView:(UIView *)view;

@end
