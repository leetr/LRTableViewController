//
//  LRObserver.h
//  Rowporter
//
//  Created by Denis Smirnov on 12-05-31.
//  Copyright (c) 2012 Tasol Global. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LRObserving : NSObject

@property (nonatomic, strong) id object;
@property (nonatomic, copy) NSString *keyPath;

@end
