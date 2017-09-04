//
//  PagedFlowView.m
//  taobao4iphone
//
//  Created by Lu Kejin on 3/2/12.
//  Copyright (c) 2012 geeklu.com. All rights reserved.
//

#import "PagedFlowView.h"
#import <QuartzCore/QuartzCore.h>

@interface PagedFlowView ()<UIScrollViewDelegate>
{
    CGFloat _lastOffSetX;
}

@property (nonatomic, assign, readwrite) NSInteger currentPageIndex;
@property(nonatomic, strong) UIScrollView *scrollView;
@property(nonatomic, assign) BOOL needsReload;
@property(nonatomic, assign) CGSize pageSize;
@property(nonatomic, assign) NSUInteger pageCount;
@property(nonatomic, strong) NSMutableArray *cells;
@property(nonatomic, assign) NSRange visibleRange;
@property(nonatomic, strong) NSMutableArray *reusableCells;

@end

@implementation PagedFlowView
@synthesize orientation;

////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private Methods
-(void)handleTapGesture:(UIGestureRecognizer*)gestureRecognizer{
    NSInteger tappedIndex = 0;
    CGPoint locationInScrollView = [gestureRecognizer locationInView:_scrollView];
    if (CGRectContainsPoint(_scrollView.bounds, locationInScrollView)) {
        tappedIndex = _currentPageIndex;
        if ([self.delegate respondsToSelector:@selector(flowView:didTapPageAtIndex:)]) {
            [self.delegate flowView:self didTapPageAtIndex:tappedIndex];
        }
    }
}

- (void)initialize{
    self.clipsToBounds = YES;
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self addGestureRecognizer:tapRecognizer];
    
    _pageControl = [[StyledPageControl alloc] initWithFrame:CGRectZero];
    _pageControl.pageControlStyle = PageControlStyleThumb;
    _pageControl.thumbImage = [UIImage imageNamed:@"banner导航点2"];
    _pageControl.selectedThumbImage = [UIImage imageNamed:@"banner导航点1"];
    [self addSubview:_pageControl];
    
    _needsReload = YES;
    _pageSize = self.bounds.size;
    _pageCount = 0;
    _currentPageIndex = 0;
    _lastOffSetX = 0;
    
    _minimumPageAlpha = 1.0;
    _minimumPageScale = 1.0;
    
    _visibleRange = NSMakeRange(0, 0);
    
    _reusableCells = [[NSMutableArray alloc] initWithCapacity:0];
    _cells = [[NSMutableArray alloc] initWithCapacity:0];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scrollView.delegate = self;
    _scrollView.pagingEnabled = YES;
    _scrollView.clipsToBounds = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;

    /*由于UIScrollView在滚动之后会调用自己的layoutSubviews以及父View的layoutSubviews
    这里为了避免scrollview滚动带来自己layoutSubviews的调用,所以给scrollView加了一层父View
     */
    UIView *superViewOfScrollView = [[UIView alloc] initWithFrame:self.bounds];
    [superViewOfScrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [superViewOfScrollView setBackgroundColor:[UIColor clearColor]];
    [superViewOfScrollView addSubview:_scrollView];
    [self addSubview:superViewOfScrollView];
    
}


- (void)dealloc{
    _scrollView.delegate = nil;
}

- (void)queueReusableCell:(UIView *)cell{
    [_reusableCells addObject:cell];
}

- (void)removeCellAtIndex:(NSInteger)index{
    UIView *cell = [_cells objectAtIndex:index];
    if ((NSObject *)cell == [NSNull null]) {
        return;
    }
    
    [self queueReusableCell:cell];
    
    if (cell.superview) {
        cell.layer.transform = CATransform3DIdentity;
        [cell removeFromSuperview];
    }
    
    [_cells replaceObjectAtIndex:index withObject:[NSNull null]];
}

- (void)refreshVisibleCellAppearance{
    
    if (_minimumPageAlpha == 1.0 && _minimumPageScale == 1.0) {
        return;//无需更新
    }
    switch (orientation) {
        case PagedFlowViewOrientationHorizontal:{
            CGFloat offset = _scrollView.contentOffset.x;
            
            for (NSUInteger i = _visibleRange.location; i < _visibleRange.location + _visibleRange.length; i++) {
                UIView *cell = [_cells objectAtIndex:i];
                CGFloat origin = cell.frame.origin.x;
                CGFloat delta = fabs(origin - offset);
                CGFloat diff = origin - offset;
                
                [cell updateConstraints];
                
                /*
                if( i == 0 )
                {
                    cell.layer.anchorPoint = CGPointMake(0.77, 0.5);
                }
                else if( i == 1 )
                {
                    cell.layer.anchorPoint = CGPointMake(0.5, 0.5);
                }
                else{
                    cell.layer.anchorPoint = CGPointMake(0.23, 0.5);
                }
                */
                /*
                for( NSInteger i = 0; i < _cells.count; i++ )
                {
                    UIView *cell = _cells[i];
                    if( [cell isKindOfClass:[UIView class]] )
                    {
                        CGRect frame = [self convertRect:cell.frame fromView:_scrollView];
                        NSLog(@"i:%d, x:%f", i, frame.origin.x);
                        if( frame.origin.x < 0 )
                        {
                            if( CGPointEqualToPoint(cell.layer.anchorPoint, CGPointMake(0.5, 0.5)) )
                            {
                                cell.layer.anchorPoint = CGPointMake(0.77, 0.5);
                            }
                        }
                        else if( frame.origin.x > _scrollView.frame.origin.x + _scrollView.frame.size.width )
                        {
                            if( CGPointEqualToPoint(cell.layer.anchorPoint, CGPointMake(0.5, 0.5)) )
                            {
                                cell.layer.anchorPoint = CGPointMake(0.27, 0.5);
                            }
                        }
                    }
                }
                */
                CGFloat interval = 15;
                CGRect frame = [self convertRect:cell.frame fromView:_scrollView];
                NSLog(@"i:%d, x:%f", i, frame.origin.x);
                
                [UIView beginAnimations:@"CellAnimation" context:nil];
                if (delta < _pageSize.width) {
                    cell.alpha = 1 - (delta / _pageSize.width) * (1 - _minimumPageAlpha);
                    
                    CGFloat pageScale = 1 - (delta / _pageSize.width) * (1 - _minimumPageScale);
                    CGFloat yScale = pageScale;
                    
                    CGFloat maxOffsetX = (_pageSize.width * (1 - _minimumPageScale))/2;
                    CGFloat offsetX = ((-1) * diff / _pageSize.width) * maxOffsetX;
                    
                    if( diff < 0 )
                    {
                        if( frame.origin.x + frame.size.width + offsetX < interval
                           && frame.origin.x > -_pageSize.width )
                        {
                            //cell.layer.transform = CATransform3DTranslate(cell.layer.transform, offsetX, 0, 0);
                            yScale = pageScale - 0.3;
                        }
                    }
                    else
                    {
                        if( frame.origin.x + offsetX > self.bounds.size.width - interval
                           && frame.origin.x + offsetX < self.bounds.size.width + _pageSize.width )
                        {
                            //cell.layer.transform = CATransform3DTranslate(cell.layer.transform, offsetX, 0, 0);
                            yScale = pageScale - 0.3;
                        }
                    }
                    cell.layer.transform = CATransform3DMakeScale(pageScale, pageScale, 1);

                } else {
                    cell.alpha = _minimumPageAlpha;
                    CGFloat yScale = _minimumPageScale;
                    
                    /*
                    CGRect frame = [self convertRect:cell.frame fromView:_scrollView];
                    NSLog(@"i:%d, x:%f", i, frame.origin.x);
                    if( frame.origin.x < 0 )
                    {
                        CGFloat x = _pageSize.width * ( 1 - _minimumPageScale) + 15;
                        cell.layer.transform = CATransform3DTranslate(cell.layer.transform, x, 0, 0);
                    }
                    else if( frame.origin.x > _scrollView.frame.origin.x + _scrollView.frame.size.width )
                    {
                        CGFloat x = _pageSize.width * ( 1 - _minimumPageScale) + 15;
                        cell.layer.transform = CATransform3DTranslate(cell.layer.transform, -x, 0, 0);
                    }
                    */
                    CGFloat pass = 15;
                    if( frame.origin.x + frame.size.width < pass
                       && frame.origin.x > -_pageSize.width )
                    {
                        CGFloat offsetX = pass - (frame.origin.x + _pageSize.width * _minimumPageScale);
                        //cell.layer.transform = CATransform3DTranslate(cell.layer.transform, offsetX, 0, 0);
                        yScale = _minimumPageScale - 0.3;
                    }
                    else
                    {
                        if( frame.origin.x > self.bounds.size.width - pass
                           && frame.origin.x < self.bounds.size.width + _pageSize.width )
                        {
                            CGFloat offsetX = frame.origin.x - (self.bounds.size.width - pass);
                            //cell.layer.transform = CATransform3DTranslate(cell.layer.transform, -offsetX, 0, 0);
                            yScale = _minimumPageScale - 0.3;
                        }
                    }
                    cell.layer.transform = CATransform3DMakeScale(_minimumPageScale, _minimumPageScale, 1);
              }
                
                [UIView commitAnimations];
            }
            break;
        }
        case PagedFlowViewOrientationVertical:{
            CGFloat offset = _scrollView.contentOffset.y;
            
            for (NSUInteger i = _visibleRange.location; i < _visibleRange.location + _visibleRange.length; i++) {
                UIView *cell = [_cells objectAtIndex:i];
                CGFloat origin = cell.frame.origin.y;
                CGFloat delta = fabs(origin - offset);
                
                [cell updateConstraints];
                
                [UIView beginAnimations:@"CellAnimation" context:nil];
                if (delta < _pageSize.height) {
                    cell.alpha = 1 - (delta / _pageSize.height) * (1 - _minimumPageAlpha);
                    
                    CGFloat pageScale = 1 - (delta / _pageSize.height) * (1 - _minimumPageScale);
                    cell.layer.transform = CATransform3DMakeScale(pageScale, pageScale, 1);
                } else {
                    cell.alpha = _minimumPageAlpha;
                    cell.layer.transform = CATransform3DMakeScale(_minimumPageScale, _minimumPageScale, 1);
                }
                [UIView commitAnimations];
            }
        }
        default:
            break;
    }

}

- (void)setPageAtIndex:(NSInteger)pageIndex{
    NSParameterAssert(pageIndex >= 0 && pageIndex < [_cells count]);
    
    UIView *cell = [_cells objectAtIndex:pageIndex];
    
    if ((NSObject *)cell == [NSNull null]) {
        cell = [_dataSource flowView:self cellForPageAtIndex:pageIndex];
        NSAssert(cell!=nil, @"datasource must not return nil");
        [_cells replaceObjectAtIndex:pageIndex withObject:cell];
        
        
        switch (orientation) {
            case PagedFlowViewOrientationHorizontal:
            {
                cell.frame = CGRectMake(_pageSize.width * pageIndex, 0, _pageSize.width, _pageSize.height);
            }
                break;
            case PagedFlowViewOrientationVertical:
                cell.frame = CGRectMake(0, _pageSize.height * pageIndex, _pageSize.width, _pageSize.height);
                break;
            default:
                break;
        }
        
        if (!cell.superview) {
            [_scrollView addSubview:cell];
        }
    }
}


- (void)setPagesAtContentOffset:(CGPoint)offset{
    
    NSUInteger cellCount = [self.cells count];
    
    if (cellCount == 0) return;
    
    // scrollView的大小是由pageSize决定的，然后放置于PagedFlowView的正中心
    CGPoint startPoint = CGPointMake(offset.x - CGRectGetMinX(_scrollView.frame), offset.y - CGRectGetMinY(_scrollView.frame));
    CGPoint endPoint = CGPointMake(startPoint.x + CGRectGetWidth(self.bounds), startPoint.y + CGRectGetHeight(self.bounds));
    
    
    switch (orientation) {
        case PagedFlowViewOrientationHorizontal:{
            NSUInteger startIndex = 0;
            if (startPoint.x > 0) {
                startIndex = floor(startPoint.x / self.pageSize.width);
            }
            
            NSInteger endIndex = ceil(endPoint.x / self.pageSize.width);
            if (endIndex > cellCount - 1) {
                endIndex = cellCount - 1;
            }
            
            //可见页分别向前向后扩展一个，提高效率
            if (startIndex > 0) {
                startIndex -= 1;
            }
            if (endIndex < cellCount - 1) {
                endIndex += 1;
            }
            
            /*
            if( startIndex >= 0 )
            {
                UIView *leftCell = _cells[startIndex];
                if( [leftCell isKindOfClass:[UIView class]] )
                {
                    leftCell.layer.anchorPoint = CGPointMake(0.77, 0.5);
                }
                
                UIView *centerCell = _cells[startIndex+1];
                if( [leftCell isKindOfClass:[UIView class]] )
                {
                    centerCell.layer.anchorPoint = CGPointMake(0.5, 0.5);
                }
            }
            else if( startIndex == 0 )
            {
                UIView *leftCell = _cells[startIndex];
                if( [leftCell isKindOfClass:[UIView class]] )
                {
                    leftCell.layer.anchorPoint = CGPointMake(0.5, 0.5);
                }
            }
            
            if( endIndex <= _cells.count-1 )
            {
                UIView *rightCell = _cells[endIndex];
                if( [rightCell isKindOfClass:[UIView class]] )
                {
                    rightCell.layer.anchorPoint = CGPointMake(0.23, 0.5);
                }
            }
            else if( endIndex == _cells.count-1 )
            {
                UIView *rightCell = _cells[endIndex];
                if( [rightCell isKindOfClass:[UIView class]] )
                {
                    rightCell.layer.anchorPoint = CGPointMake(0.5, 0.5);
                }
            }
            */
            
            
            if (_visibleRange.location == startIndex &&
                _visibleRange.length == (endIndex - startIndex + 1)) {
                return;
            }
            
            _visibleRange.location = startIndex;
            _visibleRange.length = endIndex - startIndex + 1;
            
            for (NSUInteger i = startIndex; i <= endIndex; i++) {
                [self setPageAtIndex:i];
            }
            
            for (int i = 0; i < startIndex; i ++) {
                [self removeCellAtIndex:i];
            }
            
            for (NSUInteger i = endIndex + 1; i < [_cells count]; i ++) {
                [self removeCellAtIndex:i];
            }
            break;
        }
        case PagedFlowViewOrientationVertical:{
            NSInteger startIndex = 0;
            NSUInteger cellCount = [self.cells count];
            if (startPoint.y > 0) {
                startIndex = floor(startPoint.y / self.pageSize.height);
            }
            
            NSInteger endIndex = ceil(endPoint.y / self.pageSize.height);
            if (endIndex > cellCount - 1) {
                endIndex = cellCount - 1;
            }
            
            //可见页分别向前向后扩展一个，提高效率
            if (startIndex > 0) {
                startIndex -= 1;
            }
            
            if (endIndex < cellCount - 1) {
                endIndex += 1;
            }
            
            if (_visibleRange.location == startIndex &&
                _visibleRange.length == (endIndex - startIndex + 1)) {
                return;
            }
            
            _visibleRange.location = startIndex;
            _visibleRange.length = endIndex - startIndex + 1;
            
            for (NSUInteger i = startIndex; i <= endIndex; i++) {
                [self setPageAtIndex:i];
            }
            
            for (int i = 0; i < startIndex; i ++) {
                [self removeCellAtIndex:i];
            }
            
            for (NSUInteger i = endIndex + 1; i < [_cells count]; i ++) {
                [self removeCellAtIndex:i];
            }
            break;
        }
        default:
            break;
    }
    
    
    
}




////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Override Methods

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self initialize];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    CGFloat x = 10;
    CGFloat h = 7;
    CGFloat w = width - 2 * x;
    CGFloat y = height - 5 - h;
    _pageControl.frame = CGRectMake(x, y, w, h);
    
    if (_needsReload) {
        //如果需要重新加载数据，则需要清空相关数据全部重新加载
        
        
        //重置pageCount
        if (_dataSource && [_dataSource respondsToSelector:@selector(numberOfPagesInFlowView:)]) {
            _pageCount = [_dataSource numberOfPagesInFlowView:self];
            
            if (self.pageControl && [self.pageControl respondsToSelector:@selector(setNumberOfPages:)]) {
                [self.pageControl setNumberOfPages:_pageCount];
            }
        }
        
        //重置pageWidth
        if (_delegate && [_delegate respondsToSelector:@selector(sizeForPageInFlowView:)]) {
            _pageSize = [_delegate sizeForPageInFlowView:self];
        }
        
        [_reusableCells removeAllObjects];
        _visibleRange = NSMakeRange(0, 0);
        
        //从supperView上移除cell
        for (NSInteger i=0; i<[_cells count]; i++) {
            [self removeCellAtIndex:i];
        }
        
        //填充cells数组
        [_cells removeAllObjects];
        for (NSInteger index=0; index<_pageCount; index++)
        {
            [_cells addObject:[NSNull null]];
        }
        
        // 重置_scrollView的contentSize
        switch (orientation) {
            case PagedFlowViewOrientationHorizontal://横向
                _scrollView.frame = CGRectMake(0, 0, _pageSize.width, _pageSize.height);
                _scrollView.contentSize = CGSizeMake(_pageSize.width * _pageCount,_pageSize.height);
                CGPoint theCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
                _scrollView.center = theCenter;
                break;
                
            case PagedFlowViewOrientationVertical:{
                _scrollView.frame = CGRectMake(0, 0, _pageSize.width, _pageSize.height);
                _scrollView.contentSize = CGSizeMake(_pageSize.width ,_pageSize.height * _pageCount);
                CGPoint theCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
                _scrollView.center = theCenter;
                break;
            }
            default:
                break;
        }
    }
    

    [self setPagesAtContentOffset:_scrollView.contentOffset];//根据当前scrollView的offset设置cell
    
    [self refreshVisibleCellAppearance];//更新各个可见Cell的显示外貌
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark PagedFlowView API

- (void)reloadData
{
    _needsReload = YES;
    
    [self setNeedsLayout];
}


- (UIView *)dequeueReusableCell{
    UIView *cell = [_reusableCells lastObject];
    if (cell)
    {
        [_reusableCells removeLastObject];
    }
    
    return cell;
}

- (void)scrollToPage:(NSUInteger)pageNumber {
    if (pageNumber < _pageCount) {
        switch (orientation) {
            case PagedFlowViewOrientationHorizontal:
                [_scrollView setContentOffset:CGPointMake(_pageSize.width * pageNumber, 0) animated:YES];
                break;
            case PagedFlowViewOrientationVertical:
                [_scrollView setContentOffset:CGPointMake(0, _pageSize.height * pageNumber) animated:YES];
                break;
        }
        [self setPagesAtContentOffset:_scrollView.contentOffset];
        [self refreshVisibleCellAppearance];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark hitTest

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if ([self pointInside:point withEvent:event]) {
        CGPoint newPoint = CGPointZero;
        newPoint.x = point.x - _scrollView.frame.origin.x + _scrollView.contentOffset.x;
        newPoint.y = point.y - _scrollView.frame.origin.y + _scrollView.contentOffset.y;
        if ([_scrollView pointInside:newPoint withEvent:event]) {
            return [_scrollView hitTest:newPoint withEvent:event];
        }
        
        return _scrollView;
    }
    
    return nil;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIScrollView Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if( scrollView.contentOffset.x > _lastOffSetX )
    {
        NSLog(@"--->");
    }
    else if( scrollView.contentOffset.x < _lastOffSetX )
    {
        NSLog(@"<----");
    }
    NSLog(@"***********\nscrollView.contentOffSet.x:%f _lastOffSetX:%f", scrollView.contentOffset.x, _lastOffSetX);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if( orientation == PagedFlowViewOrientationHorizontal ) //禁止垂直滚动
    {
        CGPoint point = scrollView.contentOffset;
        point.y = 0;
        scrollView.contentOffset = point;
    }
    else if( orientation == PagedFlowViewOrientationVertical ) //禁止水平滚动
    {
        CGPoint point = scrollView.contentOffset;
        point.x = 0;
        scrollView.contentOffset = point;
    }
    
    [self setPagesAtContentOffset:scrollView.contentOffset];
    
    if( scrollView.contentOffset.x > _lastOffSetX )
    {
        NSLog(@"--->");
    }
    else if( scrollView.contentOffset.x < _lastOffSetX )
    {
        NSLog(@"<----");
    }
    
    NSLog(@"***********\nscrollView.contentOffSet.x:%f _lastOffSetX:%f", scrollView.contentOffset.x, _lastOffSetX);
    
    NSLog(@"=============offset.x:%f", scrollView.contentOffset.x);
    NSLog(@"=============");
    
    [self refreshVisibleCellAppearance];
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    //如果有PageControl，计算出当前页码，并对pageControl进行更新
    
    NSInteger pageIndex;
    
    switch (orientation) {
        case PagedFlowViewOrientationHorizontal:
            pageIndex = floor(MAX(_scrollView.contentOffset.x, 0) / (_pageSize.width - 5.0));/*减5是可能有计算偏差值，导致无法正常滚动*/
            break;
        case PagedFlowViewOrientationVertical:
            pageIndex = floor(MAX(_scrollView.contentOffset.y, 0) / _pageSize.height);
            break;
        default:
            break;
    }
    
    if (self.pageControl && [self.pageControl respondsToSelector:@selector(setCurrentPage:)]) {
        [self.pageControl setCurrentPage:pageIndex];
    }
    
    /*
    
    UIView *cell = _cells[pageIndex];
    cell.center = cell.superview.center;
    
    if( pageIndex - 1 >= 0 )
    {
        UIView *leftCell = _cells[pageIndex-1];
        UIView *ssView = leftCell.superview.superview;
        CGRect cellFrame = [ssView convertRect:leftCell.frame fromView:leftCell.superview];
        if( cellFrame.origin.x < 0 )
        {
            cellFrame.origin.x = 10 - cellFrame.size.width;
            leftCell.frame = [ssView convertRect:cellFrame toView:leftCell.superview];
        }
    }
    
    if( pageIndex + 1 <= _cells.count - 1 )
    {
        UIView *rightCell = _cells[pageIndex+1];
        UIView *ssView = rightCell.superview.superview;
        CGRect cellFrame = [ssView convertRect:rightCell.frame fromView:rightCell.superview];
        if( cellFrame.origin.x > ssView.bounds.size.width )
        {
            cellFrame.origin.x = ssView.bounds.size.width - 10;
            rightCell.frame = [ssView convertRect:cellFrame toView:rightCell.superview];
        }
    }
    */
    
    if ([_delegate respondsToSelector:@selector(flowView:didScrollToPageAtIndex:)] && _currentPageIndex != pageIndex) {
        [_delegate flowView:self didScrollToPageAtIndex:pageIndex];
    }
    
    _currentPageIndex = pageIndex;
    _lastOffSetX = _scrollView.contentOffset.x;
    
    UIView *centerCell = _cells[pageIndex];
    centerCell.layer.anchorPoint = CGPointMake(0.5, 0.5);
}

@end
