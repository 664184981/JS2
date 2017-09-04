//
//  BannerCell.h
//  JewelryStore
//
//  Created by McKee on 2017/9/3.
//  Copyright © 2017年 McKee. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BannerView;

@interface BannerCell : UIView

@property UIImageView *iv;

@property NSInteger index;

@property NSInteger positonType; // -1:left; 0:middle; 1:right

@property (weak) BannerView *bannerView;

@end
