//
//  UIImage+Ex.m
//  Demo
//
//  Created by McKee on 2017/6/20.
//  Copyright © 2017年 OA.NetEase. All rights reserved.
//

#import "UIImage+Ex.h"

@implementation UIImage (Ex)

+ (instancetype)fromColor:(UIColor *)clr
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [clr CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

@end
