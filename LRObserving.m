//
//  LRObserver.m
//
//  Created by Denis Smirnov on 12-05-31.
//  Copyright (c) 2012 Leetr Inc. All rights reserved.
//

#import "LRObserving.h"

@implementation LRObserving

@synthesize object, keyPath;

- (void)dealloc
{
    self.object = nil;
    self.keyPath = nil;
    
    [super dealloc];
}

@end
