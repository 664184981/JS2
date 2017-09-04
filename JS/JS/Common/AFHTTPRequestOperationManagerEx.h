//
//  AFHTTPRequestOperationManagerEx.h
//  Recruitment
//
//  Created by McKee on 16/3/25.
//  Copyright © 2016年 OA.NETEASE. All rights reserved.
//

#import "AFNetworking.h"
#import "AFHTTPRequestOperationManager.h"

/**
 *  请求成功时的回调
 *
 *  @param operation AFHTTPRequestOperation实例
 *  @param response  返回的数据，正常为一个NSDictionary实例
 */
typedef void (^AF_HTTP_REQUEST_SUCCESS) (AFHTTPRequestOperation *operation, id response);

/**
 *  请求失败时的回调
 *
 *  @param operation AFHTTPRequestOperation实例
 *  @param error     NSError实例
 */
typedef void (^AF_HTTP_REQUEST_FAILURE) (AFHTTPRequestOperation *operation, NSError *error);

/*
 *  HTTPS发起握手之前的回调
 *  @param connection NSURLConnection实例
 *  @param challenge  NSURLAuthenticationChallenge 实例
 */
typedef void (^AF_CHALLENGE_BLK)(NSURLConnection *connection,
                                 NSURLAuthenticationChallenge *challenge);



/**
 *  AFHTTPRequestOperationManager子类，主要是为了在请求发出前做下统一处理，如数据加密、设置请求头字段等
 */
@interface AFHTTPRequestOperationManagerEx : AFHTTPRequestOperationManager

/**
 *  在请求发出去之前，给请求添加额外数据，如请求头等，可以由子类重写
 *  方法在父类构造请求后，发送请求前被父类调用
 *  @param request  NSMutableURLRequest实例
 */
- (void)addExtralDataToRequest:(NSMutableURLRequest*)request;

@end
