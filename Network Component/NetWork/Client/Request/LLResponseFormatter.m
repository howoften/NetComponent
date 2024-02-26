//
//  LLResponseFormatter.m
//  WXCitizenCard
//
//  Created by 刘江 on 2018/8/13.
//  Copyright © 2018年 Liujiang. All rights reserved.
//

#import "LLResponseFormatter.h"
#import "ServerConfig.h"
#define Cannot_Serialize_Response_Code @(-5000)
#define Parse_Response_Faile @(-5001)
#define Unpresent_Response_Code @(-4004)

@interface LLResponseFormatter ()

@property (nonatomic, strong)NSDictionary *explainForError;

@property (nonatomic, strong)NSDictionary *standardResponse;

@end

@implementation LLResponseFormatter

+ (instancetype)formatter {
    return [[LLResponseFormatter alloc] init];
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static LLResponseFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [super allocWithZone:zone];
    });
    return formatter;
}

+ (NSDictionary *)formatServerResponse:(id)response {
    if (!response || [response isKindOfClass:[NSNull class]]) {
        return @{@"code":Cannot_Serialize_Response_Code, @"data":@{}, @"msg":@"still cannot serialize server response"};
    } if ([response isKindOfClass:[NSError class]]) {
        return [[LLResponseFormatter formatter] handleErrorResponse:response];
    }else if ([response isKindOfClass:[NSDictionary class]]) {
        return [[LLResponseFormatter formatter] handleNormalResponse:response];
    }else if ([response isKindOfClass:[NSData class]]){
        NSError *serializeError = nil;
        id obj = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:&serializeError];
        if (serializeError) {
            NSString *respStr = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
            return [self formatServerResponse:respStr];
        }else {
            return [self formatServerResponse:obj];
        }
    }else {
        return [[LLResponseFormatter formatter] handleInformalResponse:response];
    }
}

- (NSDictionary *)handleErrorResponse:(NSError *)error {
    return @{
             @"code":@(error.code),
             @"msg":error.localizedDescription,
             @"data":@{},
             @"uiMsg":[self explainErrorType:@(error.code)],
             };
}

- (NSDictionary *)handleNormalResponse:(NSDictionary *)response {
    NSArray *codeSet = self.standardResponse[@"code"];
    NSString *_msg = @"Server response body ";
    __block NSNumber *code = Unpresent_Response_Code;
    [codeSet enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *key = [NSString stringWithFormat:@"%@", obj];
        if (!response[key]) { return; }
        if ([response[key] respondsToSelector:@selector(integerValue)]) {
            code = [NSNumber numberWithInteger:[response[key] integerValue]];
            *stop = YES;
        }
        code = response[key];
        *stop = YES;
    }];
    
    if ([code isEqualToNumber:Unpresent_Response_Code]) {
        _msg = [_msg stringByAppendingString:@"'code',"];
    }
    
    NSArray *dataSet = self.standardResponse[@"data"];
    __block NSDictionary *data = response;
    [dataSet enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *key = [NSString stringWithFormat:@"%@", obj];
        if (!response[key]) { return; }
        data = response[key];
        *stop = YES;
        
    }];
    
    if (data == response) {
        _msg = [_msg stringByAppendingString:@" 'data',"];
    }
    
    
    NSArray *msgSet = self.standardResponse[@"msg"];
    __block NSString *msg;
    [msgSet enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *key = [NSString stringWithFormat:@"%@", obj];
        if (!response[key]) { return; }
        msg = [NSString stringWithFormat:@"%@", response[key]];
        *stop = YES;
    }];
    
    if (msg.length < 1) {
        _msg = [_msg stringByAppendingString:@" 'msg', "];
    }
    
    if ([_msg containsString:@"code"] || [_msg containsString:@"data"] || [_msg containsString:@"msg"]) {
        _msg = [_msg stringByAppendingString:@"not present or not correct formate"];
    }else {
        _msg = msg;
    }
    
    [self responseNullSafe:data];
    
    return [self appendUIMessageInResponseBody: @{@"code":code, @"data":data, @"msg":_msg}];
}

- (NSDictionary *)appendUIMessageInResponseBody:(NSDictionary *)dic {
    if (!dic[@"code"]) {
        return dic;
    }
    NSMutableDictionary *mutableDic = [dic mutableCopy];
    [mutableDic addEntriesFromDictionary:@{@"uiMsg":[self explainErrorType:dic[@"code"]]}];
    
    return [mutableDic copy];
}

- (NSDictionary *)handleInformalResponse:(id)response {
    return @{
             @"code":Parse_Response_Faile,
             @"msg":[@"cannot parse response data, " stringByAppendingFormat:@"<%@>", response],
             @"data":@{},
             @"uiMsg":@"服务出错, 请与我们联系",
             };
}

- (NSString *)explainErrorType:(id)code {
    if (![code respondsToSelector:@selector(integerValue)]) return @"未知错误";
    NSInteger codeInteger = [code integerValue];
    if ([code isKindOfClass:NSString.class] && codeInteger == 0) {
        if ([code length] > 1 || [code length] < 1) return @"未知错误";
        if (![code isEqualToString:@"0"]) return @"未知错误";
    }
    if (Response_Success_Code(codeInteger)) return @"成功";
    NSString *explain = nil;
    switch (codeInteger) {
        case NSURLErrorUnknown:
            explain = @"未知错误, 请稍后再试";
            break;
        case NSURLErrorCancelled:
            explain = @"您操作的太过频繁";
            break;
        case NSURLErrorBadURL:
        case NSURLErrorUnsupportedURL:
        case NSURLErrorHTTPTooManyRedirects:
            explain = @"请尝试更新或重装app, 如果还遇到此类问题请与我们联系";
            break;
        case NSURLErrorTimedOut:
            explain = @"您的网络不太给力";
            break;
        case NSURLErrorCannotFindHost:
        case NSURLErrorDNSLookupFailed:
        case NSURLErrorBadServerResponse:
        case NSURLErrorZeroByteResource:
        case NSURLErrorCannotParseResponse:
        case NSURLErrorCannotDecodeRawData:
        case NSURLErrorCannotDecodeContentData:
        case NSURLErrorAppTransportSecurityRequiresSecureConnection:
        case -4004:
        case -5000:
            explain = @"服务出错, 请与我们联系";
            break;
        case NSURLErrorCannotConnectToHost:
        case -5001:
            explain = @"服务正忙, 请稍后再试";
            break;
        case NSURLErrorNetworkConnectionLost:
            explain = @"已断开与服务连接";
            break;
        case NSURLErrorResourceUnavailable:
            explain = @"您还没有权限浏览";
            break;
        case NSURLErrorNotConnectedToInternet:
            explain = @"您还没有连接到互联网";
            break;
        case NSURLErrorRedirectToNonExistentLocation:
            explain = @"该资源还未开放, 尽请期待";
            break;
        case NSURLErrorUserCancelledAuthentication:
            explain = @"请打开我们的访问权限";
            break;
        case NSURLErrorUserAuthenticationRequired:
            explain = @"需要许可我们的访问权限";
            break;
        case NSURLErrorFileDoesNotExist:
        case NSURLErrorFileIsDirectory:
        case NSURLErrorFileOutsideSafeArea:
            explain = @"访问本地文件出错, 请尝试升级或重装app";
            break;
        case NSURLErrorNoPermissionsToReadFile:
            explain = @"请允许我们访问本地文件";
            break;
        case NSURLErrorDataLengthExceedsMaximum:
            explain = @"访问本地文件出错, 请尝试删除本地文稿";
            break;
        case NSURLErrorSecureConnectionFailed:
            explain = @"无法与服务建立安全连接, 请与我们联系";
            break;
        case NSURLErrorServerCertificateHasBadDate:
            explain = @"安全连接已过期, 请与我们联系";
            break;
        case NSURLErrorServerCertificateUntrusted:
            explain = @"安全证书不被信任, 请与我们联系";
            break;
        case NSURLErrorServerCertificateHasUnknownRoot:
            explain = @"未知安全证书, 请与我们联系";
            break;
        case NSURLErrorServerCertificateNotYetValid:
            explain = @"无效安全证书, 请与我们联系";
            break;
        case NSURLErrorClientCertificateRejected:
            explain = @"安全证书被拒绝, 请与我们联系";
            break;
        case NSURLErrorClientCertificateRequired:
            explain = @"需要安全证书以建立安全连接";
            break;
        case NSURLErrorCannotLoadFromNetwork:
        case NSURLErrorInternationalRoamingOff:
        case NSURLErrorCallIsActive:
        case NSURLErrorDataNotAllowed:
        case NSURLErrorRequestBodyStreamExhausted:
            explain = @"网络错误, 请与我们联系";
            break;
        case NSURLErrorCannotCreateFile:
        case NSURLErrorCannotWriteToFile:
        case NSURLErrorCannotRemoveFile:
        case NSURLErrorCannotMoveFile:
        case NSURLErrorDownloadDecodingFailedMidStream:
        case NSURLErrorDownloadDecodingFailedToComplete:
            explain = @"无法保存内容, 请稍后再试";
            break;
        case NSURLErrorCannotOpenFile:
            explain = @"无法读取文件, 请稍后再试";
            break;
        case NSURLErrorCannotCloseFile:
            explain = @"无法关闭文件, 请稍后再试";
            break;
        case NSURLErrorBackgroundSessionRequiresSharedContainer:
        case NSURLErrorBackgroundSessionInUseByAnotherProcess:
        case NSURLErrorBackgroundSessionWasDisconnected:
            explain = @"后台任务出错, 请重试";
            break;
        case 200:
            explain = @"成功";
            break;
        default:
            explain = @"未知错误";
            break;
    }
    return explain;
}



- (NSDictionary *)explainForError {
    if(!_explainForError) {
        _explainForError = @{
                             @(NSURLErrorUnknown):@"未知错误, 请稍后再试",
                             @(NSURLErrorTimedOut):@"您的网络不太给力",
                             @(NSURLErrorBadURL):@"请尝试更新或重装app, 如果还遇到此类问题请与我们联系", //url格式错误
                             @(NSURLErrorCancelled):@"您操作的太过频繁",
                             @(NSURLErrorUnsupportedURL):@"请尝试更新或重装app, 如果还遇到此类问题请与我们联系",
                             @(NSURLErrorCannotFindHost):@"服务出错, 请与我们联系",
                             @(NSURLErrorCannotConnectToHost):@"服务正忙, 请稍后再试",
                             @(NSURLErrorNetworkConnectionLost):@"已断开与服务链接",
                             @(NSURLErrorDNSLookupFailed):@"",
                             Cannot_Serialize_Response_Code:@"服务正忙, 请稍后再试",
                             };
    }
    return _explainForError;
}

- (void)responseNullSafe:(id)jsonContainer {
    if ([jsonContainer isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *transDic = jsonContainer;
        if (![transDic isKindOfClass:[NSMutableDictionary class]]) {
            transDic = [jsonContainer mutableCopy];
        }
        
        [[jsonContainer copy] enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[NSNull class]]) {
                [transDic removeObjectForKey:key];
            }else if ([obj isKindOfClass:[NSArray class]] || [obj isKindOfClass:[NSDictionary class]] || [obj isKindOfClass:[NSSet class]]) {
                [self responseNullSafe:obj];
            }
        }];
        jsonContainer = transDic;
    }else if ([jsonContainer isKindOfClass:[NSArray class]]) {
        NSMutableArray *transArr = jsonContainer;
        if (![transArr isKindOfClass:[NSMutableArray class]]) {
            transArr = [jsonContainer mutableCopy];
        }
        [[jsonContainer copy] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[NSNull class]]) {
                [transArr removeObject:obj];
            }else if ([obj isKindOfClass:[NSArray class]] || [obj isKindOfClass:[NSDictionary class]] || [obj isKindOfClass:[NSSet class]]) {
                [self responseNullSafe:obj];
            }
        }];
      
        jsonContainer = transArr;
    }else if ([jsonContainer isKindOfClass:[NSSet class]]) {
        NSMutableArray *transArr = [[(NSSet *)jsonContainer allObjects] mutableCopy];
        jsonContainer = transArr;
        [self responseNullSafe:jsonContainer];
    }else {
        if ([jsonContainer isKindOfClass:[NSNull class]]) {
            jsonContainer = nil;
        }
    }
    
}

- (NSDictionary *)standardResponse {
    if (!_standardResponse) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"responseFormat" ofType:@"plist"];
        _standardResponse = [NSDictionary dictionaryWithContentsOfFile:filePath];
        if (!_standardResponse || _standardResponse.allKeys.count < 3) {
            _standardResponse = @{@"code":@[@"code"], @"data":@[@"data"], @"msg":@[@"msg"]};
        }
        
    }
    return _standardResponse;
}

@end
