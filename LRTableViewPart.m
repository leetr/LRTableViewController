//
//  LRTableViewPart.m
//  OttrJam
//
//  Created by Denis Smirnov on 12-05-28.
//  Copyright (c) 2012 Leetr.com. All rights reserved.
//

#import "LRTableViewPart.h"
#import "UITableViewCell+cellTypeToString.h"

@interface LRTableViewPart ()

- (UITableViewCell *)cellFromNibNamed:(NSString *)nibName;
- (void)populateCell:(UITableViewCell *)cell forRow:(NSInteger)row;

@end


@implementation LRTableViewPart

@synthesize cellIdentifier;
@synthesize cellStyle = _cellStyle;
@synthesize data = _data;
@synthesize tableView = _tableView;
@synthesize bindings;
@synthesize cellHeight = _cellHeight;

- (id)init
{
    self = [super init];
    
    if (self) {
        _data = nil;
        _tableView = nil;
        _cellStyle = UITableViewCellStyleDefault;
        _cellHeight = 0;
    }
    
    return self;
}

- (void)dealloc
{
    self.data = nil;
    self.tableView = nil;
    self.cellIdentifier = nil;
    
    [super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    //TODO: add check for correct keypath change
    if (_tableView != nil) {
        [_tableView reloadData];
    }
    
}

- (void)setData:(NSArray *)data
{
    if (data != _data) {
        
        if (_data != nil) {
            [self removeObserver:self forKeyPath:@"data"];
            [_data release];
        }
        
        _data = data;
        
        if (_data != nil) {
            [_data retain];
            [self addObserver:self forKeyPath:@"data" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
        }
    }
}

- (NSInteger)numberOfRows
{
    return (_data == nil) ? 0 : _data.count;
}

- (UITableViewCell *)cellFromNibNamed:(NSString *)nibName
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];
    
    UITableViewCell *cell;
    
    for (id currentObject in topLevelObjects) {
        if ([currentObject isKindOfClass:[UITableViewCell class]]) {
            cell = (UITableViewCell *)currentObject;
            break;
        }
    }
    
    return cell;
}

//
- (void)populateCell:(UITableViewCell *)cell forRow:(NSInteger)row
{
    if (self.bindings != nil) {
        for (NSString *cellKeyPath in self.bindings) {
            NSString *dataKeyPath = [self.bindings valueForKeyPath:cellKeyPath];
            [cell setValue:[[self.data objectAtIndex:row] valueForKeyPath:dataKeyPath] forKeyPath:cellKeyPath];
        }
    }
}

//
- (UITableViewCell *)cellForRow:(NSInteger)row
{
    UITableViewCell *cell;
    
    if (self.cellIdentifier != nil) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
        
        if (cell == nil) {
            cell = [self cellFromNibNamed:self.cellIdentifier];
        }
    } else {
        NSString *identifier = [UITableViewCell cellTypeToString:self.cellStyle];
        cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                           reuseIdentifier:[UITableViewCell cellTypeToString:self.cellStyle]] autorelease];
        }
    }
    
    [self populateCell:cell forRow:row];
    
    return cell;
}

//
- (CGFloat)heightForRow:(NSInteger)row
{
    return 44;
}

- (void)didSelectRow:(NSInteger)row realIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
