//
//  BannerView.h
//  JewelryStore
//
//  Created by McKee on 2017/9/3.
//  Copyright © 2017年 McKee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BannerCell.h"

@protocol BannerViewDelegate <NSObject>

@optional

- (void)didSelectItemAtIndex:(NSInteger)index;

@end



@interface BannerView : UIView

@property (weak) id<BannerViewDelegate> delegate;

+ (CGFloat)height;

- (void)onTapCell:(BannerCell*)cell;

@end
