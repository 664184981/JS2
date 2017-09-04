//
//  BannerView.m
//  JewelryStore
//
//  Created by McKee on 2017/9/3.
//  Copyright © 2017年 McKee. All rights reserved.
//

#import "BannerView.h"
#import "PagedFlowView.h"
#import "StyledPageControl.h"
#import "BannerCell.h"
#import "NSArray+Util.h"

@interface BannerView ()<PagedFlowViewDataSource,PagedFlowViewDelegate>
{
    PagedFlowView *_pageFlowView;
    StyledPageControl *_pageControl;
    NSMutableArray *_cells;
}

@end

@implementation BannerView

+ (CGFloat)height
{
    return 225;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if( self )
    {
        _cells = [NSMutableArray arrayWithCapacity:0];
        _pageFlowView = [[PagedFlowView alloc] initWithFrame:CGRectZero];
        _pageFlowView.delegate = self;
        _pageFlowView.dataSource = self;
        [self addSubview:_pageFlowView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _pageFlowView.frame = self.bounds;
}


#pragma mark- PagedFlowViewDataSource

- (NSInteger)numberOfPagesInFlowView:(PagedFlowView *)flowView
{
    return 3;
}

- (UIView *)flowView:(PagedFlowView *)flowView cellForPageAtIndex:(NSInteger)index
{
    NSString *icon;
    if( index == 0 )
    {
        icon = @"爆款精品";
    }
    else if( index == 1 )
    {
        icon = @"抽奖";
    }
    else if( index == 2 )
    {
        icon = @"爆款精品";
    }
    
    BannerCell *cell = (BannerCell*)[_cells objectInIndex:index];
    if( !cell )
    {
        cell = [[BannerCell alloc] initWithFrame:_pageFlowView.bounds];
        [_cells addObject:cell];
    }
    cell.iv.image = [UIImage imageNamed:icon];
    cell.index = index;
    cell.iv.layer.cornerRadius = 6;
    cell.iv.layer.shadowColor = [UIColor redColor].CGColor;
    cell.iv.layer.shadowOffset = CGSizeMake(0, -5);
    cell.iv.layer.masksToBounds = YES;
    return cell;
}

#pragma mark PagedFlowView Delegate

- (CGSize)sizeForPageInFlowView:(PagedFlowView *)flowView
{
    CGFloat width = flowView.bounds.size.width;
    CGFloat height = flowView.bounds.size.height;
    return CGSizeMake(width*0.84, height*0.846);
}

- (void)flowView:(PagedFlowView *)flowView didScrollToPageAtIndex:(NSInteger)index {
    BannerCell *cell = (BannerCell*)[_cells objectInIndex:index];
    cell.positonType = 0;
    [cell setNeedsLayout];
    
    BannerCell *leftCell = (BannerCell*)[_cells objectInIndex:index-1];
    leftCell.positonType = -1;
    [leftCell setNeedsLayout];
    
    BannerCell *rightCell = (BannerCell*)[_cells objectInIndex:index+1];
    rightCell.positonType = 1;
    [rightCell setNeedsLayout];
}

- (void)flowView:(PagedFlowView *)flowView didTapPageAtIndex:(NSInteger)index{
    NSLog(@"Tapped on page # %ld", (long)index);
}

@end
