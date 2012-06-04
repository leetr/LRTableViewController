//
//  LRTableViewPart.m
//  OttrJam
//
//  Created by Denis Smirnov on 12-05-28.
//  Copyright (c) 2012 Leetr.com. All rights reserved.
//

#import "LRTableViewPart.h"
#import "UITableViewCell+cellTypeToString.h"
#import "LRObserving.h"

@interface LRTableViewPart ()
{
    LRObserving *_observing;
}

- (UITableViewCell *)cellFromNibNamed:(NSString *)nibName;
- (void)populateCell:(UITableViewCell *)cell forRow:(NSInteger)row;

@end


@implementation LRTableViewPart

@synthesize cellIdentifier;
@synthesize cellStyle = _cellStyle;
@synthesize tableView = _tableView;
@synthesize bindings;
@synthesize cellHeight = _cellHeight;
@synthesize onCellSelectedBlock;

+ (LRTableViewPart *)partWithCellStyle:(UITableViewCellStyle)style
{
    LRTableViewPart *part = [[[LRTableViewPart alloc] init] autorelease];
    part.cellStyle = style;
    
    return part;
}

+ (LRTableViewPart *)partWithCellIdentifier:(NSString *)identifier
{
    LRTableViewPart *part = [[[LRTableViewPart alloc] init] autorelease];
    part.cellIdentifier = identifier;
    
    return part;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        _tableView = nil;
        _cellStyle = UITableViewCellStyleDefault;
        _cellHeight = 0;
        _observing = [[LRObserving alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    [_observing release];
    
    self.tableView = nil;
    self.cellIdentifier = nil;
    self.onCellSelectedBlock = nil;
    
    [_observing.object removeObserver:self];
    [_observing release];    
    
    [super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    //TODO: add check for correct keypath change
    if (_tableView != nil && [keyPath isEqualToString:_observing.keyPath]) {
        [_tableView reloadData];
    }
    
}

- (void)observeObject:(id)object forKeyPath:(NSString *)keyPath
{
    _observing.object = object;
    _observing.keyPath = keyPath;
    
    [object addObserver:self forKeyPath:keyPath options:0 context:nil];
}

- (NSInteger)numberOfRows
{
    return (_observing.object == nil) ? 0 : [(NSArray *)[_observing.object valueForKeyPath:_observing.keyPath] count];
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
            [cell setValue:[[(NSArray *)[_observing.object valueForKeyPath:_observing.keyPath] objectAtIndex:row] valueForKeyPath:dataKeyPath] forKeyPath:cellKeyPath];
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
    return (self.cellHeight == 0) ? 44 : self.cellHeight;
}

//
- (void)didSelectRow:(NSInteger)row realIndexPath:(NSIndexPath *)indexPath
{
    if (self.onCellSelectedBlock != nil) {
        self.onCellSelectedBlock(self.tableView, indexPath, row);
    }
}

@end
