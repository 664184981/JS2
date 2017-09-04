//
//  BXTabBar.m
//  IrregularTabBar
//
//  Created by JYJ on 16/5/3.
//  Copyright © 2016年 baobeikeji. All rights reserved.
//

#import "BXTabBar.h"
#import "BXTabBarBigButton.h"


@interface BXTabBar ()
/** bigButton */
@property (nonatomic, strong) BXTabBarBigButton *bigButton;
@end

@implementation BXTabBar
- (BXTabBarBigButton *)bigButton {
    if (!_bigButton) {
        BXTabBarBigButton *bigButton = [[BXTabBarBigButton alloc] init];
        
        NSString *btnSelectedName = @"";
        [bigButton setImage:[UIImage imageNamed:@"tabbar_main_barItem_unselect"] forState:UIControlStateNormal];
        [bigButton setImage:[UIImage imageNamed:btnSelectedName] forState:UIControlStateHighlighted];
        [bigButton setImage:[UIImage imageNamed:btnSelectedName] forState:UIControlStateSelected];
        [bigButton addTarget:self action:@selector(bigButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        self.bigButton = bigButton;
    }
    return _bigButton;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self addSubview:self.bigButton];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tabbarClicked:) name:@"TabBarDidSelectNotification" object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)tabbarClicked:(NSNotification*)notification
{
    /*
    NSDictionary *dict = [notification userInfo];
    NSInteger selectIndex = [[dict objectForKey:@"TabbarSelectIndex"] integerValue];
    
    NSInteger indexOfCenterItem = 0;
    for(UINavigationController *nvc in self.refVC.viewControllers)
    {
        if([nvc.topViewController isKindOfClass:[MainCardsViewController class]])
        {
            break;
        }
        indexOfCenterItem++;
    }
    
    if(indexOfCenterItem > 0)
    {
        NSString *btnSelectedName = [[ThemeManager defaultThemeManager]getCurrentTabbarButtonImgName];
        if(selectIndex != indexOfCenterItem)
        {
            [self.bigButton setImage:[UIImage imageNamed:@"tabbar_main_barItem_unselect"] forState:UIControlStateNormal];
            [self.bigButton setTitleColor:[UIColor colorFromHexRGB:@"666666" alpha:1.0] forState:UIControlStateNormal];
        }
        else
        {
            [self.bigButton setImage:[UIImage imageNamed:btnSelectedName] forState:UIControlStateNormal];
            [self.bigButton setTitleColor:[[ThemeManager defaultThemeManager]getCurrentThemeColor] forState:UIControlStateNormal];
        }
    }
    */
}


- (void)bigButtonClick:(id)sender
{
    /*
    BXTabBarBigButton *button = (BXTabBarBigButton*)sender;
    
    NSString *btnSelectedName = [[ThemeManager defaultThemeManager]getCurrentTabbarButtonImgName];
    [button setImage:[UIImage imageNamed:btnSelectedName] forState:UIControlStateNormal];
    
    [self.refVC selectCenterBarItem:nil];
    */
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    //bigButton frame
    CGRect rect = self.bounds;
    CGFloat w = rect.size.width / self.items.count - 1;
    self.bigButton.frame = CGRectInset(rect, 2 * w, 0);
    [self bringSubviewToFront:self.bigButton];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.clipsToBounds || self.hidden || (self.alpha == 0.f)) {
        return nil;
    }
    
    CGPoint newPoint = [self convertPoint:point toView:self.bigButton.imageView];
    
    if ( [self.bigButton.imageView pointInside:newPoint withEvent:event])
    {
        return self.bigButton;
    }
    else
    {
        return [super hitTest:point withEvent:event];
    }
    
    return [super hitTest:point withEvent:event];
}

@end
