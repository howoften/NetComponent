//
//  AppleServer.m
//  SJTransport
//
//  Created by 刘江 on 2018/8/27.
//  Copyright © 2018年 Liujiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GreenTreeServer.h"
#import "LLAppContext.h"
#import "LLSignatureGenerator.h"

@implementation GreenTreeServer

@synthesize developApiBaseUrl = _developApiBaseUrl, testApiBaseUrl = _testApiBaseUrl, prereleaseApiBaseUrl = _prereleaseApiBaseUrl, releaseApiBaseUrl = _releaseApiBaseUrl, customApiBaseUrl = _customApiBaseUrl;
+ (id<LLBaseServiceProtocol>)sharedInstance {
    static GreenTreeServer *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[GreenTreeServer alloc] init];
    });
    return shared;
}

- (NSString *)developApiBaseUrl {
    if (!_developApiBaseUrl) {
        _developApiBaseUrl = @"GTAPIHost";
    }
    return _developApiBaseUrl;
}

- (NSString *)testApiBaseUrl {
    if (!_testApiBaseUrl) {
        _testApiBaseUrl = @"GTAPIHost";
    }
    return _testApiBaseUrl;
}

- (NSString *)prereleaseApiBaseUrl {
    if (!_prereleaseApiBaseUrl) {
        _prereleaseApiBaseUrl = @"GTAPIHost";
    }
    return _prereleaseApiBaseUrl;
}

- (NSString *)releaseApiBaseUrl {
    if (!_releaseApiBaseUrl) {
        _releaseApiBaseUrl = @"GTAPIHost";
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
    NSDictionary *commonHeader = @{
        @"versionCode": @"1",
        @"clientVer": appContext.app_version,
        @"model":  appContext.device_model,
        @"macAddress": appContext.device_id,
        @"platform": @"WinPhone",
        @"weblogid": @"weblogid",
        @"sourceId": @"YOUPIN_GUANWANG",
        @"subSourceId": @"YOUPIN_GUANWANG",
        @"screenSize": [NSString stringWithFormat:@"%dx%d", (int)appContext.screenSize.width, (int)appContext.screenSize.height],
        @"protocolVer": @"1.0.0",
        @"carrier": appContext.carrierName ?: @"null",
        @"deviceId": appContext.device_id,
        @"session": @"1",
        
    };
    
    return commonHeader;
}

- (NSDictionary *)commonRequestParametersFor:(LLBaseRequestModel *)requestEntity {
    return nil;
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
