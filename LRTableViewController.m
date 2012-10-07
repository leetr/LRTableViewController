//
//  LRTableViewController.m
//
//  Created by Denis Smirnov on 12-05-28.
//  Copyright (c) 2012 Leetr.com. All rights reserved.
//
//  PullToRefresh code borrowed from Leah Culver's PullRefreshTableViewController
//  https://github.com/leah/PullToRefresh
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//
//  

#import <QuartzCore/QuartzCore.h>
#import "LRTableViewController.h"

@interface LRTableViewController () {
    NSMutableArray *_sections;
    float _refresh_header_height;
    BOOL _isUsingDefaultView;
    UIView *_pullToRefreshView;
}
 
- (void)setupPullToRefreshHeaderStrings;
- (void)addPullToRefreshHeader;
- (void)removePullToRefreshHeader;
- (void)showLoadingHeader;
- (UIView *)defaultViewForRefreshHeaderView;

@end

@implementation LRTableViewController

@synthesize tableView = _tableView;
@synthesize isPullToRefresh = _isPullToRefresh;
@synthesize refreshHeaderTextPull = _refreshHeaderTextPull;
@synthesize refreshHeaderTextRelease = _refreshHeaderTextRelease; 
@synthesize refreshHeaderTextLoading = _refreshHeaderTextLoading;
@synthesize refreshHeaderImageName = _refreshHeaderImageName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        _sections = [[NSMutableArray alloc] init];
        [self setupPullToRefreshHeaderStrings];
    }
    
    return self;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        _sections = [[NSMutableArray alloc] init];
        [self setupPullToRefreshHeaderStrings];
    }
    
    return self;
}

- (void)dealloc
{
    self.tableView = nil;
    [_sections release];
    _sections = nil;
    
    if (_isUsingDefaultView) {
        [refreshLabel release]; refreshLabel = nil;
        [refreshSpinner release]; refreshSpinner = nil;
        
        if (refreshArrow != nil) {
            [refreshArrow release]; refreshArrow = nil;
        }
    }
    
    [_refreshHeaderTextPull release]; _refreshHeaderTextPull = nil;
    [_refreshHeaderTextRelease release]; _refreshHeaderTextRelease = nil;
    [_refreshHeaderTextLoading release]; _refreshHeaderTextLoading = nil;
    [_refreshHeaderImageName release]; _refreshHeaderImageName = nil;
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (_isPullToRefresh) {
        [self addPullToRefreshHeader];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.tableView = nil;
}

- (void)removeSection:(LRTableViewSection *)section
{
    [self removeSection:section withAnimation:UITableViewRowAnimationNone];
}

- (void)removeSection:(LRTableViewSection *)section withAnimation:(UITableViewRowAnimation)animation
{
    int sectionIndex = [_sections indexOfObject:section];
    
    if (_sections.count > sectionIndex) {
        [_sections removeObjectAtIndex:sectionIndex];
    
        [self.tableView beginUpdates];
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:animation];
        [self.tableView endUpdates];
    }
}

- (void)addSection:(LRTableViewSection *)section
{
    [self addSection:section withAnimation:UITableViewRowAnimationNone];
}

- (void)addSection:(LRTableViewSection *)section withAnimation:(UITableViewRowAnimation)animation
{
    if (section != nil) {
        section.tableView = self.tableView;
        section.delegate = self;
        
        [_sections addObject:section];
        
        [self.tableView beginUpdates];
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:(_sections.count - 1)] withRowAnimation:animation];
        [self.tableView endUpdates];
    }
}

- (void)removeAllSections
{
    for (LRTableViewSection *section in _sections) {
        [self removeSection:section];
    }
}

#pragma mark PullToRefresh methods

- (void)updateRefreshHeaderForPull
{
    if (_isUsingDefaultView) {
        [UIView animateWithDuration:0.25 animations:^{
            refreshLabel.text = self.refreshHeaderTextPull;
            if (refreshArrow != nil) {
                [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
            }
        }];
    }
}

- (void)updateRefreshHeaderForRelease
{
    if (_isUsingDefaultView) {
        [UIView animateWithDuration:0.25 animations:^{
            refreshLabel.text = self.refreshHeaderTextRelease;
            
            if (refreshArrow != nil) {
                [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
            }
        }];
    }
}

- (void)updateRefreshHeaderForLoading;
{
    if (_isUsingDefaultView) {
        refreshLabel.text = self.refreshHeaderTextLoading;
        [refreshSpinner startAnimating];
        
        if (refreshArrow != nil) {
            refreshArrow.hidden = YES;
        }
    }
}

- (void)resetRefreshHeader 
{
    if (_isUsingDefaultView) {
        refreshLabel.text = self.refreshHeaderTextPull;
        [refreshSpinner stopAnimating];
        
        if (refreshArrow != nil) {
            [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
            refreshArrow.hidden = NO;
        }
    }
}

- (UIView *)viewForRefreshHeaderView {
    return nil;
}

- (UIView *)defaultViewForRefreshHeaderView
{
    float viewHeight = 52.0f;
    
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, viewHeight)];
    container.backgroundColor = [UIColor clearColor];
    
    refreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, viewHeight)];
    refreshLabel.backgroundColor = [UIColor clearColor];
    refreshLabel.font = [UIFont boldSystemFontOfSize:12.0];
    refreshLabel.textAlignment = UITextAlignmentCenter;
    
    if (_refreshHeaderImageName != nil) {
        refreshArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:_refreshHeaderImageName]];
        refreshArrow.frame = CGRectMake(floorf((viewHeight - 27) / 2),
                                        (floorf(viewHeight - 44) / 2),
                                        27, 44);
        
        [container addSubview:refreshArrow];
    }
    
    refreshSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    refreshSpinner.frame = CGRectMake(floorf(floorf(viewHeight - 20) / 2), floorf((viewHeight - 20) / 2), 20, 20);
    refreshSpinner.hidesWhenStopped = YES;
    
    [container addSubview:refreshLabel];
    [container addSubview:refreshSpinner];
    
    return [container autorelease];
}

- (void)setupPullToRefreshHeaderStrings
{
    _refreshHeaderTextPull = [[NSString alloc] initWithString:@"Pull down to refresh..."];
    _refreshHeaderTextRelease = [[NSString alloc] initWithString:@"Release to refresh..."];
    _refreshHeaderTextLoading = [[NSString alloc] initWithString:@"Loading..."];
    _refreshHeaderImageName = nil;
}

- (void)addPullToRefreshHeader 
{
    UIView *refreshHeaderView = [self viewForRefreshHeaderView];
    
    if (refreshHeaderView == nil) {
        refreshHeaderView = [self defaultViewForRefreshHeaderView];
        _isUsingDefaultView = YES;
    } else {
        _isUsingDefaultView = NO;
    }
    
    CGRect frame = refreshHeaderView.frame;
    _refresh_header_height = frame.size.height;
    frame.origin.y = 0 - _refresh_header_height;
    refreshHeaderView.frame = frame;
    
    _pullToRefreshView = [refreshHeaderView retain];
    
    [self.tableView addSubview:refreshHeaderView];
}

- (void)removePullToRefreshHeader
{
    if (_pullToRefreshView != nil && _pullToRefreshView.superview != nil) {
        [_pullToRefreshView removeFromSuperview];
        [_pullToRefreshView release];
        _pullToRefreshView = nil;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView 
{
    if (!_isPullToRefresh || isLoading) {
        return;
    }
    isDragging = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView 
{
    if (_isPullToRefresh && isLoading) {
        
        if (scrollView.contentOffset.y > 0) {
            self.tableView.contentInset = UIEdgeInsetsZero;
        } else if (scrollView.contentOffset.y >= -_refresh_header_height) {
            self.tableView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
        }
    } else if (_isPullToRefresh && isDragging && scrollView.contentOffset.y < 0) {
        
        if (scrollView.contentOffset.y < -_refresh_header_height) {
            [self updateRefreshHeaderForRelease];
        } else {
            [self updateRefreshHeaderForPull];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate 
{
    if (!_isPullToRefresh || isLoading) {
        return;
    }
    
    isDragging = NO;
    
    if (scrollView.contentOffset.y <= -_refresh_header_height) {
        // Released above the header
        [self startLoading];
    }
}

- (void)showLoadingHeader
{
    if (!_isPullToRefresh) {
        [self addPullToRefreshHeader];
    }
    
    [self updateRefreshHeaderForLoading];
    
    // Show the header
    [UIView animateWithDuration:0.3 animations:^{
        self.tableView.contentInset = UIEdgeInsetsMake(_refresh_header_height, 0, 0, 0);    
    }];
}

- (void)startLoading 
{
    isLoading = YES;
    
    [self showLoadingHeader];
    
    // Refresh action!
    [self refresh];
}

- (void)stopLoading 
{
    isLoading = NO;
    
    // Hide the header
    [UIView animateWithDuration:0.3 animations:^{
        self.tableView.contentInset = UIEdgeInsetsZero;
    } 
                     completion:^(BOOL finished) {
                         [self performSelector:@selector(stopLoadingComplete:finished:context:)];
                     }];
}

- (void)stopLoadingComplete:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context 
{
    if (!_isPullToRefresh) {
        if (_isUsingDefaultView) {
            [self removePullToRefreshHeader];
        }
    }
    [self resetRefreshHeader];
}

- (void)refresh 
{
    // This is just a demo. Override this method with your custom reload action.
    // Don't forget to call stopLoading at the end.
    [self performSelector:@selector(stopLoading) withObject:nil afterDelay:2.0];
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)sectionNum
{
    LRTableViewSection *section = (LRTableViewSection *)[_sections objectAtIndex:sectionNum];
    return section.headerTitle;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)sectionNum
{
    LRTableViewSection *section = (LRTableViewSection *)[_sections objectAtIndex:sectionNum];
    return section.headerView;
}

-(float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)sectionNum {
    
    LRTableViewSection *section = (LRTableViewSection *)[_sections objectAtIndex:sectionNum];
    if (section.headerView == nil && section.headerTitle == nil) {
        return 0;
    }
    
    if (section.headerView != nil) {
        return section.headerView.frame.size.height;
    } else {
        return 22;
    }
}

#pragma mark - LRTableViewSectionDelegate

- (void)tableViewSection:(LRTableViewSection *)section insertRowsInIndexSet:(NSIndexSet *)indexset withRowAnimation:(UITableViewRowAnimation)animation
{
    if (section != nil && indexset != nil) {
        int sectionNum = [_sections indexOfObject:section];
        NSMutableArray *indexPaths = [NSMutableArray array];
        
        [indexset enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:sectionNum];
            [indexPaths addObject:indexPath];
        }];
        
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];
        [self.tableView endUpdates];
    }
}

- (void)tableViewSection:(LRTableViewSection *)section deleteRowsInIndexSet:(NSIndexSet *)indexset withRowAnimation:(UITableViewRowAnimation)animation
{
    if (section != nil && indexset != nil) {
        int sectionNum = [_sections indexOfObject:section];
        NSMutableArray *indexPaths = [NSMutableArray array];
        
        [indexset enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:sectionNum];
            [indexPaths addObject:indexPath];
        }];
        
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];
        [self.tableView endUpdates];
    }
}

@end
