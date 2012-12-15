//
//  LRTableViewPart.m
//
//  Created by Denis Smirnov on 12-05-28.
//  Copyright (c) 2012 Leetr.com. All rights reserved.
//

#import "LRTableViewPart.h"
#import "UITableViewCell+cellTypeToString.h"
#import "LRObserving.h"
#import "LRCellHeight.h"

const NSUInteger kRowViewTag = 99119922;

@interface LRTableViewPart ()
{
    LRObserving *_observing;
    NSMutableArray *_observingKeyPaths;
    UITableViewCell *_heightCell;
}

- (UITableViewCell *)cellFromNibNamed:(NSString *)nibName;
- (void)populateCell:(UITableViewCell *)cell forRow:(NSInteger)row;
- (void)setRowNum:(NSInteger)row forCell:(UITableViewCell *)cell;
- (NSInteger)getRowNumForCell:(UITableViewCell *)cell;
- (void)removeObserverFromSubitems;
- (void)observeSubitems;
@end


@implementation LRTableViewPart

@synthesize cellIdentifier;
@synthesize cellStyle = _cellStyle;
@synthesize tableView = _tableView;
@synthesize bindings;
@synthesize cellHeight = _cellHeight;
@synthesize onCellSelectedBlock = _onCellSelectedBlock;
@synthesize onViewSelectedBlock = _onViewSelectedBlock;
@synthesize onPartCellViewSelected = _onPartCellViewSelected;
@synthesize onPartCellSelected = _onPartCellSelected;
@synthesize delegate = _partDelegate;
@synthesize rowAnimation = _rowAnimation;

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
        _observingKeyPaths = [[NSMutableArray alloc] init];
        _rowAnimation = UITableViewRowAnimationNone;
        _onPartCellSelected = nil;
        _onPartCellViewSelected = nil;
        _heightCell = nil;
    }
    
    return self;
}

- (void)dealloc
{
    self.tableView = nil;
    self.cellIdentifier = nil;
    self.onCellSelectedBlock = nil;
    self.onViewSelectedBlock = nil;
    
    self.onPartCellSelected = nil;
    self.onPartCellViewSelected = nil;
    
    [self removeObserverFromSubitems];
    [_observingKeyPaths release]; _observingKeyPaths = nil;
    
    [_observing.object removeObserver:self forKeyPath:_observing.keyPath];
    [_observing release]; _observing = nil;
    
    [super dealloc];
}

- (void)setOnPartCellSelected:(void(^)(LRTableViewPart *part, UITableView *tableView, NSIndexPath *indexPath, NSInteger partRow))block
{
    Block_release(_onPartCellSelected);
    _onPartCellSelected = Block_copy(block);
}

- (void)setOnPartCellViewSelected:(void(^)(LRTableViewPart *part, UIView *view, NSInteger partRow))block
{
    Block_release(_onPartCellViewSelected);
    _onPartCellViewSelected = Block_copy(block);
}

- (void)setTableView:(UITableView *)tableView
{
    if (tableView != _tableView) {
        if (_tableView != nil) {
            [_tableView release];
            _tableView = nil;
        }
        
        _tableView = tableView;
        
        if (_tableView != nil) {
            [_tableView retain];
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    //TODO: add check for correct keypath change
    //TODO: when main observed keyPath changes, needs to change observed subitems
    
    if (change != nil) {
        NSKeyValueChange kind = [[change valueForKey:NSKeyValueChangeKindKey] intValue];
        NSIndexSet *indexes = [change valueForKey:@"indexes"];
        
        switch (kind) {
            case NSKeyValueChangeInsertion:
                if (self.delegate != nil && [self.delegate conformsToProtocol:@protocol(LRTableViewPartDelegate)]) {
                    [self.delegate tableViewPart:self insertRowsInIndexSet:indexes withRowAnimation:self.rowAnimation];
                }
                break;
            case NSKeyValueChangeRemoval:
                //remove
                if (self.delegate != nil && [self.delegate conformsToProtocol:@protocol(LRTableViewPartDelegate)]) {
                    [self.delegate tableViewPart:self deleteRowsInIndexSet:indexes withRowAnimation:self.rowAnimation];
                }
                break;
                
            default:
                [_tableView reloadData];
                break;
        }
    }
}

- (void)observeObject:(id)object forKeyPath:(NSString *)keyPath
{
    [self stopObserving];
    
    _observing.object = object;
    _observing.keyPath = keyPath;
    
    [object addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:@"LRTableViewPart"];
    
//    if (![[_observing.object valueForKeyPath:_observing.keyPath] isKindOfClass:[NSArray class]]) {
//        //if an individual item, we can observe it's subitems
//        [self observeSubitems];
//    } 
}

- (void)stopObserving
{
    if (_observing && _observing.object && _observing.keyPath) {
        [_observing.object removeObserver:self forKeyPath:_observing.keyPath];
        _observing.object = nil;
        _observing.keyPath = nil;
    }
}

- (void)removeObserverFromSubitems
{
    for (NSString *keyPath in _observingKeyPaths) {
        [_observing.object removeObserver:self forKeyPath:keyPath];
    }
}

- (void)observeSubitems
{
    
    for (NSString *key in self.bindings) {
        NSString *newKeyPath = [NSString stringWithFormat:@"%@.%@", _observing.keyPath, [self.bindings valueForKey:key]];
        [_observing.object addObserver:self forKeyPath:newKeyPath options:0 context:nil];
        [_observingKeyPaths addObject:newKeyPath];
    }
}

- (NSInteger)numberOfRows
{
    if (_observing.object == nil) {
        return 0;
    }
    NSObject *obj = [_observing.object valueForKeyPath:_observing.keyPath];
    BOOL isArray = ([obj isKindOfClass:[NSArray class]]);
    
    NSInteger numRows = (!isArray) ? ( (obj) ? 1 : 0) : [(NSArray *)obj count];
    
    return numRows;
}

- (void)setRowNum:(NSInteger)row forCell:(UITableViewCell *)cell
{
    //OMG HACK ALERT!!!
    UIView *v = [cell viewWithTag:kRowViewTag];
    
    if (v == nil) {
        v = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)] autorelease];
        v.hidden = YES;
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
    
    UITableViewCell *cell = nil;
    
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
            
            if ([dataKeyPath isEqualToString:@"[self]"] || [dataKeyPath isEqualToString:@"[object]"]) {
                [cell setValue:obj forKeyPath:cellKeyPath];
            }
            else if ([dataKeyPath hasPrefix:@"[value]"]) {
                [cell setValue:[dataKeyPath substringFromIndex:7] forKeyPath:cellKeyPath];
            }
            else if ([dataKeyPath hasPrefix:@"[string]"]) {
                [cell setValue:[dataKeyPath substringFromIndex:8] forKeyPath:cellKeyPath];
            }
            else if ([dataKeyPath hasPrefix:@"[int]"]) {
                NSString *parsed = [dataKeyPath substringFromIndex:5];
                NSNumber *num = [NSNumber numberWithInt:[parsed intValue]];
                [cell setValue:num forKey:cellKeyPath];
            }
            else {
                NSString *value = [obj valueForKeyPath:dataKeyPath];
                
                if (value && ![value isKindOfClass:[NSNull class]]) {
                    if (value && [value hasPrefix:@"[image]"]) {
                        UIImage *image = [UIImage imageNamed:[value substringFromIndex:7]];
                        [cell setValue:image forKeyPath:cellKeyPath];
                    }
                    else {
                        [cell setValue:value forKeyPath:cellKeyPath];
                    }
                }
            }
        }
    }
    
    [self setRowNum:row forCell:cell];
}

- (UITableViewCell *)partCell
{
    UITableViewCell *cell;
    
    if (self.cellIdentifier != nil) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
        
        if (cell == nil) {
            cell = [self cellFromNibNamed:self.cellIdentifier];
        }
    }
    else {
        NSString *identifier = [UITableViewCell cellTypeToString:self.cellStyle];
        cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:self.cellStyle
                                           reuseIdentifier:[UITableViewCell cellTypeToString:self.cellStyle]] autorelease];
        }
    }
    
    return cell;
}

//
- (UITableViewCell *)cellForRow:(NSInteger)row
{
    UITableViewCell *cell = [self partCell];
    
//    if (self.cellIdentifier != nil) {
//        cell = [self.tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
//        
//        if (cell == nil) {
//            cell = [self cellFromNibNamed:self.cellIdentifier];
//        }
//    } else {
//        NSString *identifier = [UITableViewCell cellTypeToString:self.cellStyle];
//        cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
//        if (cell == nil) {
//            cell = [[[UITableViewCell alloc] initWithStyle:self.cellStyle 
//                                           reuseIdentifier:[UITableViewCell cellTypeToString:self.cellStyle]] autorelease];
//        }
//    }
    
    [self populateCell:cell forRow:row];
    
    cell.tag = row;
    
    if ([cell respondsToSelector:@selector(setDelegate:)] ){
        [cell setValue:self forKey:@"delegate"];
    }
    
    return cell;
}

//
- (CGFloat)heightForRow:(NSInteger)row
{
    if (self.cellHeight == -1) {
        
        if (_heightCell == nil) {
            _heightCell = [self partCell];
        }
        
        if (_heightCell != nil && [_heightCell conformsToProtocol:@protocol(LRCellHeight)]) {
            [self populateCell:_heightCell forRow:row];
            return [(UITableViewCell<LRCellHeight> *)_heightCell height];
        }
    } else if (self.cellHeight == 0) {
        
        
    } else {
        return self.cellHeight;
    }
    
    return 44;
}

//
- (void)didSelectRow:(NSInteger)row realIndexPath:(NSIndexPath *)indexPath
{
    if (self.onPartCellSelected != nil) {
        self.onPartCellSelected(self, self.tableView, indexPath, row);
    }
    else if (self.onCellSelectedBlock != nil) {
        self.onCellSelectedBlock(self.tableView, indexPath, row);
    }
}

#pragma mark - LRTableViewCellDelegate

- (void)tableViewCell:(UITableViewCell *)cell didSelectView:(UIView *)view
{
    if (self.onPartCellViewSelected != nil) {
        self.onPartCellViewSelected(self, view, [self getRowNumForCell:cell]);
    }
    else if (self.onViewSelectedBlock != nil) {
        self.onViewSelectedBlock(view, [self getRowNumForCell:cell]);
    }
}

@end
