//
//  AppHelper.m
//  JS
//
//  Created by McKee on 2017/9/4.
//  Copyright © 2017年 MCKEE. All rights reserved.
//

#import "AppHelper.h"

@implementation AppHelper

+ (instancetype)helper
{
    static AppHelper *gAppHelper;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        gAppHelper = [[AppHelper alloc] init];
    });
    return gAppHelper;
}

- (instancetype)init
{
    self = [super init];
    if( self )
    {
        _host = @"";
    }
    return self;
}

@end
