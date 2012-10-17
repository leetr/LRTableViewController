//
//  LRObserver.h
//
//  Created by Denis Smirnov on 12-05-31.
//  Copyright (c) 2012 Leetr Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LRObserving : NSObject

@property (nonatomic, weak) NSObject *object;
@property (nonatomic, copy) NSString *keyPath;

@end
