//
//  LRTableViewController.m
//  OttrJam
//
//  Created by Denis Smirnov on 12-05-28.
//  Copyright (c) 2012 Leetr.com. All rights reserved.
//  
//  TODO: Move didSelectCell to a block
//

#import "LRTableViewController.h"

@interface LRTableViewController () {
    NSMutableArray *_sections;
}
    
@end

@implementation LRTableViewController

@synthesize tableView = _tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        _sections = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    self.tableView = nil;
    [_sections release];
    
    [super dealloc];
}

- (void)addSection:(LRTableViewSection *)section
{
    section.tableView = self.tableView;
    [_sections addObject:section];
}

#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [(LRTableViewSection *)[_sections objectAtIndex:section] numberOfRows];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LRTableViewSection *section = (LRTableViewSection *)[_sections objectAtIndex:indexPath.section];
    return [section cellForRow:indexPath.row];
}

#pragma mark UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LRTableViewSection *section = (LRTableViewSection *)[_sections objectAtIndex:indexPath.section];
    return [section heightForRow:indexPath.row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LRTableViewSection *section = (LRTableViewSection *)[_sections objectAtIndex:indexPath.section];
    [section didSelectRowAtIndexPath:indexPath];
}

@end
