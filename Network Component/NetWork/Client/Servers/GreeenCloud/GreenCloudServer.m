//
//  AppleServer.m
//  SJTransport
//
//  Created by 刘江 on 2018/8/27.
//  Copyright © 2018年 Liujiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GreenCloudServer.h"
#import "LLAppContext.h"
#import "LLSignatureGenerator.h"

@implementation GreenCloudServer

@synthesize developApiBaseUrl = _developApiBaseUrl, testApiBaseUrl = _testApiBaseUrl, prereleaseApiBaseUrl = _prereleaseApiBaseUrl, releaseApiBaseUrl = _releaseApiBaseUrl, customApiBaseUrl = _customApiBaseUrl;
+ (id<LLBaseServiceProtocol>)sharedInstance {
    static GreenCloudServer *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[GreenCloudServer alloc] init];
    });
    return shared;
}

- (NSString *)developApiBaseUrl {
    if (!_developApiBaseUrl) {
        _developApiBaseUrl = @"http://10.3.152.16:9009";
    }
    return _developApiBaseUrl;
}

- (NSString *)testApiBaseUrl {
    if (!_testApiBaseUrl) {
        _testApiBaseUrl = @"http://10.3.152.16:9009";
    }
    return _testApiBaseUrl;
}

- (NSString *)prereleaseApiBaseUrl {
    if (!_prereleaseApiBaseUrl) {
        _prereleaseApiBaseUrl = @"http://10.3.152.16:9009";
    }
    return _prereleaseApiBaseUrl;
}

- (NSString *)releaseApiBaseUrl {
    if (!_releaseApiBaseUrl) {
        _releaseApiBaseUrl = @"http://10.3.152.16:9009";
    }
    return _releaseApiBaseUrl;
}


- (NSString *)publicKey {
    if (self.environmentType == LLEnvironmentTypeTest) {
        return @"01430734";
    }
    return @"01430734";
}
- (NSString *)privateKey {
    if (self.environmentType == LLEnvironmentTypeTest) {
        return @"F446BF1CD08C11EEBAEDCB210A871BA9";
    }
    return @"F446BF1CD08C11EEBAEDCB210A871BA9";
}


- (NSDictionary *)commonRequestHeaderParametersFor:(LLBaseRequestModel *)requestEntity {
    LLAppContext *appContext = [[LLAppContext alloc] init];
    NSString *ts= [NSString stringWithFormat:@"%ld", [[NSDate date] timeIntervalSince1970]*1000];
    NSDictionary *commonHeader = @{@"User-Agent":[self userAgent],
                                  @"X-Gw-Key": self.publicKey,
                                  @"Accept": @"application/json",
                                  @"X-Gw-Nonce": appContext.device_id,
                                  @"X-Gw-Timestamp": ts,
                                  @"X-Gw-Signature": [self signwithTimestamp:ts uuid:appContext.device_id path:requestEntity.requestPath],
                                   
    };
    
    return commonHeader;
}

- (NSDictionary *)commonRequestParametersFor:(LLBaseRequestModel *)requestEntity {
    NSDictionary *commonParam = @{
        @"hotelCode": @"0",
        @"hotelGroupCode": @"GREENTREE-TEST",
        @"channel": @"GLAPP"
    };
    
    return commonParam;
}

- (NSString *)userAgent {
    LLAppContext *app = [[LLAppContext alloc] init];
    
    NSString *bunldId = app.bundle_id;
    NSString *appVersion = [@"V" stringByAppendingString:app.app_version];
    NSString *osKern = @"Unix";
    NSString *systemVersion = [[[[UIDevice currentDevice] systemName] stringByAppendingString:@" "] stringByAppendingString:[[UIDevice currentDevice] systemVersion]];
    NSString *language = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
    NSString *deviceModel = app.device_model;
    NSString *brand_Model = [@"Build/Apple-" stringByAppendingString:deviceModel];
    NSString *buildVersion = [@"BuildCode/" stringByAppendingString:app.build_version];
    
    NSString *user_agent = [[[[[[[[[[[[[[[bunldId stringByAppendingString:@"/"] stringByAppendingString:appVersion] stringByAppendingString:@" ("] stringByAppendingString:osKern] stringByAppendingString:@"; "] stringByAppendingString:systemVersion] stringByAppendingString:@"; "] stringByAppendingString:language] stringByAppendingString:@"; "] stringByAppendingString:deviceModel] stringByAppendingString:@" "] stringByAppendingString:brand_Model] stringByAppendingString:@" "] stringByAppendingString:buildVersion] stringByAppendingString:@")"];
    
    return user_agent;
}

- (NSString *)signwithTimestamp:(NSString *)ts uuid:(NSString *)uuid path:(NSString *)path {
    NSString *key = self.privateKey;
    NSMutableString *plainText = [NSMutableString string];
    
    [plainText appendString:@"POST\n"]; //HTTPMethod
    [plainText appendString:@"application/json\n"];  //Accept
    [plainText appendString:@"\n"];  //Content-MD5
    [plainText appendString:@"application/json\n"];  //Content-Type
    [plainText appendString:@"\n"];  //Date
    //Headers
    [plainText appendFormat:@"x-gw-key:%@\n", self.publicKey];
    [plainText appendFormat:@"x-gw-nonce:%@\n", uuid];
    [plainText appendFormat:@"x-gw-timestamp:%@\n", ts];
    //Url
    [plainText appendString:path];
    
    NSString *signResult = [LLSignatureGenerator hmacSha256AndBase64:plainText encryptKey:key];
    return signResult;
}
@end
