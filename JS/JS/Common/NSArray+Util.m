//
//  NSArray+Util.m
//  JewelryStore
//
//  Created by McKee on 2017/9/3.
//  Copyright © 2017年 McKee. All rights reserved.
//

#import "NSArray+Util.h"

@implementation NSArray (Util)

- (NSObject*)objectInIndex:(NSInteger)index
{
    if( self.count == 0 || index > self.count - 1 || index < 0 )
    {
        return nil;
    }
    return [self objectAtIndex:index];
}

@end
