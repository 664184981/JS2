//
//  AFJSONResponseSerializerEx.m
//  Recruitment
//
//  Created by McKee on 16/3/25.
//  Copyright © 2016年 OA.NETEASE. All rights reserved.
//

#import "AFJSONResponseSerializerEx.h"
#import "GTMNSString+HTML.h"

@implementation AFJSONResponseSerializerEx

- (instancetype)init
{
    self = [super init];
    if( self )
    {
        NSSet *set = [NSSet setWithObjects:@"application/json",
                      @"text/json",
                      @"text/javascript",
                      @"text/html",
                      @"text/plain",
                      nil];
        
        self.acceptableContentTypes = set;
    }
    return self;
}

- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error
{
    id responseObject = [super responseObjectForResponse:response data:data error:error];
    
    if( responseObject )
    {
        NSStringEncoding stringEncoding = self.stringEncoding;
        if (response.textEncodingName)
        {
            CFStringRef nameRef = (__bridge CFStringRef)response.textEncodingName;
            CFStringEncoding encoding = CFStringConvertIANACharSetNameToEncoding(nameRef);
            if (encoding != kCFStringEncodingInvalidId)
            {
                stringEncoding = CFStringConvertEncodingToNSStringEncoding(encoding);
            }
        }
        
        NSString *responseString =
        [[NSString alloc] initWithData:data encoding:stringEncoding];
        
        if( !responseString ){
            NSStringEncoding gbkEncoding =
            CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
            
            responseString = [[NSString alloc] initWithData:data encoding:gbkEncoding];
            DEBUGLOG(@"-----------------");
        }
        
        if( !responseString ){
            
            responseString =
            [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            DEBUGLOG(@"=============");
        }
        
        if( responseString )
        {
            NSString *ouput = responseString;
            ouput = [ouput stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
            ouput = [ouput gtm_stringByUnescapingFromHTML];
            ouput = [ouput stringByRemoveControlCharacter];
            NSString *url = response.URL.absoluteString;
            DEBUGLOG(@"\n%@\nreturn:\n%@", url, ouput);
        }
    }
    
    return responseObject;
}


@end
