//
//  BannerCell.m
//  JewelryStore
//
//  Created by McKee on 2017/9/3.
//  Copyright © 2017年 McKee. All rights reserved.
//

#import "BannerCell.h"

#define topMargin           45
#define bottomMargin        20
#define horizontalMargin    14

@interface BannerCell ()
{
    
}

@end

@implementation BannerCell

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
        self.backgroundColor = [UIColor clearColor];
        _iv = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:_iv];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    CGFloat w = width - 2 * horizontalMargin;
    CGFloat h = height  - topMargin - bottomMargin;
    if( _positonType == 0 )
    {
        _iv.frame = self.bounds;
    }
    else if( _positonType == 1 )
    {
        _iv.frame = CGRectMake(horizontalMargin, topMargin, w, h);
    }
    else if( _positonType == -1 )
    {
        _iv.frame = CGRectMake(width - horizontalMargin - w, topMargin, w, h);
    }
}

@end
