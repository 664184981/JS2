//
//  AFHTTPRequestOperationManagerEx.m
//  Recruitment
//
//  Created by McKee on 16/3/25.
//  Copyright © 2016年 OA.NETEASE. All rights reserved.
//


#import "AFHTTPRequestOperationManagerEx.h"
#import "AFJSONResponseSerializerEx.h"

@implementation AFHTTPRequestOperationManagerEx


+ (instancetype)manager {
    AFHTTPRequestOperationManagerEx *manager = [[[super class] alloc] initWithBaseURL:nil];
    manager.responseSerializer = [[AFJSONResponseSerializerEx alloc] init];
    return manager;
}


- (AFHTTPRequestOperation *)HTTPRequestOperationWithHTTPMethod:(NSString *)method
                                                     URLString:(NSString *)URLString
                                                    parameters:(id)parameters
                                                       success:(AF_HTTP_REQUEST_SUCCESS)success
                                                       failure:(AF_HTTP_REQUEST_FAILURE)failure
{
    NSError *serializationError = nil;
    NSString *url = [[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString];
    
    NSMutableURLRequest *request =
    [self.requestSerializer requestWithMethod:method
                                    URLString:url
                                   parameters:parameters
                                        error:&serializationError];
    if (serializationError) {
        if (failure) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
            dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(nil, serializationError);
            });
#pragma clang diagnostic pop
        }
        
        return nil;
    }
    
    [self addExtralDataToRequest:request];
    
    AF_HTTP_REQUEST_FAILURE failureEX = ^(AFHTTPRequestOperation *operation, NSError *error){
        if( failure )
        {
            DEBUGLOG(@"\n<<<<<\n%@\n>>>>>", error);
            NSError *underiyingError = [error.userInfo objectForKey:@"NSUnderlyingError"];
            NSDictionary *info = underiyingError.userInfo;
            NSData *errData = [info objectForKey:@"com.alamofire.serialization.response.error.data"];
            if( errData.length > 0 )
            {
                NSString *errString = [[NSString alloc] initWithData:errData encoding:NSUTF8StringEncoding];
                if( errString.length > 0 )
                {
                    DEBUGLOG(@"\n%@\n>>>>\n", errString);
                }
            }
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:0];
            [userInfo setObject:@"发送请求失败，请稍后重试" forKey:NSLocalizedDescriptionKey];
            [userInfo setObject:error forKey:@"error"];
            
            NSError *err = [NSError errorWithDomain:@"network error"
                                               code:9999
                                           userInfo:userInfo];
            failure(operation, err);
        }
    };
    
    DEBUGLOG(@"%@\nheaders:%@\nparams:%@", URLString, request.allHTTPHeaderFields, parameters);
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:success
                                                                      failure:failureEX];
    
    AF_CHALLENGE_BLK blk = ^(NSURLConnection *connection,
                             NSURLAuthenticationChallenge *challenge){
        NSString *method = challenge.protectionSpace.authenticationMethod;
        if ([method isEqualToString:NSURLAuthenticationMethodServerTrust])
        {
            DEBUGLOG(@"NSURLAuthenticationMethodServerTrust");
            SecTrustRef trust = [challenge.protectionSpace serverTrust];
            NSURLCredential *credential = [NSURLCredential credentialForTrust:trust];
            [[challenge sender] useCredential:credential
                   forAuthenticationChallenge:challenge];
        }
        else if([method isEqualToString:NSURLAuthenticationMethodClientCertificate])
        {
            DEBUGLOG(@"NSURLAuthenticationMethodClientCertificate");
        }
        else
        {
            DEBUGLOG(@"Auth Challenge Failed");
            [[challenge sender]cancelAuthenticationChallenge:challenge];
        }
    };
    
    [operation setWillSendRequestForAuthenticationChallengeBlock:blk];
    
    return operation;

}

- (void)addExtralDataToRequest:(NSMutableURLRequest *)request
{
}

@end
