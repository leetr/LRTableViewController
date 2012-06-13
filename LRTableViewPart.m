//
//  LRTableViewPart.m
//
//  Created by Denis Smirnov on 12-05-28.
//  Copyright (c) 2012 Leetr.com. All rights reserved.
//

#import "LRTableViewPart.h"
#import "UITableViewCell+cellTypeToString.h"
#import "LRObserving.h"

const NSUInteger kRowViewTag = 99119922;

@interface LRTableViewPart ()
{
    LRObserving *_observing;
}

- (UITableViewCell *)cellFromNibNamed:(NSString *)nibName;
- (void)populateCell:(UITableViewCell *)cell forRow:(NSInteger)row;
- (void)setRowNum:(NSInteger)row forCell:(UITableViewCell *)cell;
- (NSInteger)getRowNumForCell:(UITableViewCell *)cell;
@end


@implementation LRTableViewPart

@synthesize cellIdentifier;
@synthesize cellStyle = _cellStyle;
@synthesize tableView = _tableView;
@synthesize bindings;
@synthesize cellHeight = _cellHeight;
@synthesize onCellSelectedBlock;
@synthesize onViewSelectedBlock;

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
    self.tableView = nil;
    self.cellIdentifier = nil;
    self.onCellSelectedBlock = nil;
    self.onViewSelectedBlock = nil;
    
    [_observing.object removeObserver:self forKeyPath:_observing.keyPath];
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
    if (_observing.object == nil) {
        return 0;
    }
    NSObject *obj = [_observing.object valueForKeyPath:_observing.keyPath];
    BOOL isArray = ([obj isKindOfClass:[NSArray class]]);
    
    return (!isArray) ? 1 : [(NSArray *)obj count];
}

- (void)setRowNum:(NSInteger)row forCell:(UITableViewCell *)cell
{
    //OMG HACK ALERT!!!
    UIView *v = [cell viewWithTag:kRowViewTag];
    
    if (v == nil) {
        v = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)] autorelease];
        v.tag = kRowViewTag;
        
        UIView *subV = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)] autorelease];
        [v addSubview:subV];
        
        [cell addSubview:v];
    }
    
    UIView *tagView = [[v subviews] objectAtIndex:0];
    tagView.tag = row;
}

- (NSInteger)getRowNumForCell:(UITableViewCell *)cell
{
    UIView *v = [cell viewWithTag:kRowViewTag];
    
    if (v != nil) {
       UIView *tagView = [[v subviews] objectAtIndex:0];
        return tagView.tag;
    }
    
    return -1;
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
        
        NSObject *obj = [_observing.object valueForKeyPath:_observing.keyPath];
        
        if ([obj isKindOfClass:[NSArray class]]) {
            obj = [(NSArray *)obj objectAtIndex:row]; 
        } 
        
        for (NSString *cellKeyPath in self.bindings) {
            NSString *dataKeyPath = [self.bindings valueForKeyPath:cellKeyPath];
            [cell setValue:[obj valueForKeyPath:dataKeyPath] forKeyPath:cellKeyPath];
        }
    }
    
    [self setRowNum:row forCell:cell];
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
    
    cell.tag = row;
    
    if ([cell respondsToSelector:NSSelectorFromString(@"delegate")] ){
        [cell setValue:self forKey:@"delegate"];
    }
    
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

#pragma mark - LRTableViewCellDelegate

- (void)tableViewCell:(UITableViewCell *)cell didSelectView:(UIView *)view
{
    if (self.onViewSelectedBlock != nil) {
        self.onViewSelectedBlock(view, [self getRowNumForCell:cell]);
    }
}

@end
