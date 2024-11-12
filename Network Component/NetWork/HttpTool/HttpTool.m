//
//  HttpTool.m
//  WXCitizenCard
//
//  Created by 刘江 on 2018/8/10.
//  Copyright © 2018年 Liujiang. All rights reserved.
//

#import "HttpTool.h"
#import "HttpLog.h"
#import <AFNetworking/AFNetworking.h>

@interface HttpTool()

@property (nonatomic, strong)AFHTTPSessionManager *afManager;
@property (nonatomic, strong)AFHTTPSessionManager *jsonManager;

@property (nonatomic, strong)NSArray *traceUrls;

@property (nonatomic, strong)NSMutableArray *halfwayLogs;

@property (nonatomic, strong)NSDateFormatter *formatter;
@end

@implementation HttpTool
static BOOL _disableProxySetting = NO;
+ (HttpTool *)shareManager {
    static HttpTool *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[HttpTool alloc] init];
    });
    return manager;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *config = NSURLSessionConfiguration.defaultSessionConfiguration;
        HttpTool.disableProxySetting ? config.connectionProxyDictionary = @{} : NULL;
        self.afManager = [[AFHTTPSessionManager alloc] initWithBaseURL:nil sessionConfiguration:config];
        self.afManager.requestSerializer = [AFHTTPRequestSerializer serializer];
        self.afManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        self.afManager.operationQueue.maxConcurrentOperationCount = 5;//请求队列最大并发数
        self.afManager.requestSerializer.timeoutInterval = 12; //请求超时时间
        self.afManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/plain",@"text/html", nil];
            
        config = NSURLSessionConfiguration.defaultSessionConfiguration;
        HttpTool.disableProxySetting ? config.connectionProxyDictionary = @{} : NULL;
        self.jsonManager = [AFHTTPSessionManager manager];
        self.jsonManager.requestSerializer = [AFJSONRequestSerializer serializer];
        self.jsonManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        self.jsonManager.operationQueue.maxConcurrentOperationCount = 5;//请求队列最大并发数
        self.jsonManager.requestSerializer.timeoutInterval = 12; //请求超时时间
        self.jsonManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/plain",@"text/html", nil];

        [self loadTraceHttpURL];
    }
    return self;
}

- (void)loadTraceHttpURL {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"HttpRequestTrace" ofType:@"plist"];
    if (filePath.length > 0) {
        self.traceUrls = [NSArray arrayWithContentsOfFile:filePath];
        if (!self.traceUrls) {
            NSLog(@"[HttpTool] The http request trace has not build yet");
        }else {
            self.halfwayLogs = [NSMutableArray arrayWithCapacity:0];
        }
    }
}

- (void)refreshHTTPRequestHeader:(NSDictionary<NSString *, NSString *> *)header {
    [self refreshRequestHeader:header];
}

- (void)refreshRequestHeader:(NSDictionary *)dic {
    [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [self.afManager.requestSerializer setValue:[NSString stringWithFormat:@"%@", obj] forHTTPHeaderField:key];
        [self.jsonManager.requestSerializer setValue:[NSString stringWithFormat:@"%@", obj] forHTTPHeaderField:key];
    }];
}

- (NSURLSessionDataTask *)getWithURLString:(NSString *)urlString parameters:(NSDictionary *)parameters progress:(void(^)(NSProgress *progress))progress success:(void(^)(id responseObject))success failure:(void(^)(NSError *error))failure {
    __block HttpLog *log = [self bornHttpLog:@"GET" urlString:urlString param:parameters];
    return [self.afManager GET:urlString parameters:parameters headers:@{} progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progress) {
            progress(uploadProgress);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSError *serialError = nil;
        id serialObject = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&serialError];
        if (!serialError) {
            if (success) {
                success(serialObject);
            }
            [self logHttpRequestContext:log resopnse:serialObject];
        }else {
            if (success) {
                success(responseObject);
            }
            [self logHttpRequestContext:log resopnse:responseObject];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
        [self logHttpRequestContext:log resopnse:error];
        
    }];
}
- (NSURLSessionDataTask *)postFormUrlEncodedWithURLString:(NSString *)urlString parameters:(NSDictionary *)parameters progress:(void(^)(NSProgress *progress))progress success:(void(^)(id responseObject))success failure:(void(^)(NSError *error))failure {
    __block HttpLog *log = [self bornHttpLog:@"POST-Application/x-www-form-urlencoded" urlString:urlString param:parameters];
    return [self.afManager POST:urlString parameters:parameters headers:@{} progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progress) {
            progress(uploadProgress);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSError *serialError = nil;
        id serialObject = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&serialError];
        if (!serialError) {
            if (success) {
                success(serialObject);
            }
            [self logHttpRequestContext:log resopnse:serialObject];
        }else {
            if (success) {
                success(responseObject);
            }
            [self logHttpRequestContext:log resopnse:responseObject];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
        [self logHttpRequestContext:log resopnse:error];
    }];

}
- (NSURLSessionDataTask *)postJsonWithURLString:(NSString *)urlString parameters:(NSDictionary *)parameters progress:(void(^)(NSProgress *progress))progress success:(void(^)(id responseObject))success failure:(void(^)(NSError *error))failure {
    __block HttpLog *log = [self bornHttpLog:@"POST-Application/json" urlString:urlString param:parameters];
    return [self.jsonManager POST:urlString parameters:parameters headers:@{} progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progress) {
            progress(uploadProgress);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSError *serialError = nil;
        id serialObject = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&serialError];
        if (!serialError) {
            if (success) {
                success(serialObject);
            }
            [self logHttpRequestContext:log resopnse:serialObject];
        }else {
            if (success) {
                success(responseObject);
            }
            [self logHttpRequestContext:log resopnse:responseObject];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
        [self logHttpRequestContext:log resopnse:error];
    }];

}

- (NSURLSessionDataTask *)postFormDataWithURLString:(NSString *)urlString parameters:(NSDictionary *)parameters progress:(void(^)(NSProgress *progress))progress success:(void(^)(id responseObject))success failure:(void(^)(NSError *error))failure {
    __block HttpLog *log = [self bornHttpLog:@"POST-Form/data" urlString:urlString param:parameters];
    return [self.jsonManager POST:urlString parameters:nil headers:@{} constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [parameters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if ([key isEqualToString:@"dataName"] || [key isEqualToString:@"fileName"] || [key isEqualToString:@"mimeType"]) {
                return;
            }else if ([obj isKindOfClass:[NSData class]]){
                NSString *dataName = [NSString stringWithFormat:@"%@", parameters[@"dataName"]];
                dataName = dataName.length > 0 ? dataName : @"file";
                NSString *fileName = [NSString stringWithFormat:@"%@", parameters[@"fileName"]];
                fileName = fileName.length > 0 ? fileName : @"fileName";
                NSString *mimeType = [NSString stringWithFormat:@"%@", parameters[@"mimeType"]];
                if (mimeType.length < 1) {
                    NSLog(@"Upload file-- you have not refer specific mimeType of your upload-file, mimeType will been referred to application/octet-stream");
                }
                mimeType = mimeType.length > 0 ? mimeType : @"application/octet-stream";
                [formData appendPartWithFileData:obj name:dataName fileName:fileName mimeType:mimeType];
            }else if ([key isEqualToString:@"filePath"]) {
                NSString *dataName = [NSString stringWithFormat:@"%@", parameters[@"dataName"]];
                dataName = dataName.length > 0 ? dataName : @"file";
                NSString *fileName = [NSString stringWithFormat:@"%@", parameters[@"fileName"]];
                fileName = fileName.length > 0 ? fileName : @"fileName";
                NSString *mimeType = [NSString stringWithFormat:@"%@", parameters[@"mimeType"]];
                if (mimeType.length < 1) {
                    NSLog(@"Upload file-- you have not refer specific mimeType of your upload-file, mimeType will been referred to application/octet-stream");
                }
                mimeType = mimeType.length > 0 ? mimeType : @"application/octet-stream";
                NSError *error = nil;
                [formData appendPartWithFileURL:[NSURL fileURLWithPath:parameters[@"filePath"]] name:dataName fileName:fileName mimeType:mimeType error:&error];
                if (error) {
                    failure(error);
                }
            }else if ([obj isKindOfClass:[NSString class]]) {
                [formData appendPartWithFormData:[obj dataUsingEncoding:NSUTF8StringEncoding] name:key];
            }else if ([obj isKindOfClass:[NSArray class]] || [obj isKindOfClass:[NSDictionary class]]) {
                NSError *error = nil;
                NSData *convert = [NSJSONSerialization dataWithJSONObject:obj options:NSJSONWritingPrettyPrinted error:&error];
                if (!error) {
                    [formData appendPartWithFormData:convert name:key];
                }else {
                    NSLog(@"###Not support Form data key type %@", NSStringFromClass([obj class]));
                }
            }else if ([obj respondsToSelector:@selector(encodeWithCoder:)]) {
                [formData appendPartWithFormData:[NSKeyedArchiver archivedDataWithRootObject:obj] name:key];
            }
        }];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progress) {
            progress(uploadProgress);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSError *serialError = nil;
        id serialObject = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&serialError];
        if (!serialError) {
            if (success) {
                success(serialObject);
            }
            [self logHttpRequestContext:log resopnse:serialObject];
        }else {
            if (success) {
                success(responseObject);
            }
            [self logHttpRequestContext:log resopnse:responseObject];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
        [self logHttpRequestContext:log resopnse:error];
    }];
}

- (NSURLSessionDataTask *)putWithURLString:(NSString *)urlString parameters:(NSDictionary *)parameters success:(void(^)(id responseObject))success failure:(void(^)(NSError *error))failure {
    __block HttpLog *log = [self bornHttpLog:@"PUT" urlString:urlString param:parameters];
    return [self.jsonManager PUT:urlString parameters:parameters headers:@{} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSError *serialError = nil;
        id serialObject = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&serialError];
        if (!serialError) {
            if (success) {
                success(serialObject);
            }
            [self logHttpRequestContext:log resopnse:serialObject];
        }else {
            if (success) {
                success(responseObject);
            }
            [self logHttpRequestContext:log resopnse:responseObject];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
        [self logHttpRequestContext:log resopnse:error];
    }];
}

- (NSURLSessionDataTask *)deleteWithURLString:(NSString *)urlString parameters:(NSDictionary *)parameters success:(void(^)(id responseObject))success failure:(void(^)(NSError *error))failure {
    __block HttpLog *log = [self bornHttpLog:@"DELETE" urlString:urlString param:parameters];
    return [self.jsonManager DELETE:urlString parameters:parameters headers:@{} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSError *serialError = nil;
        id serialObject = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&serialError];
        if (!serialError) {
            if (success) {
                success(serialObject);
            }
            [self logHttpRequestContext:log resopnse:serialObject];
        }else {
            if (success) {
                success(responseObject);
            }
            [self logHttpRequestContext:log resopnse:responseObject];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
        [self logHttpRequestContext:log resopnse:error];
    }];
}

- (NSURLSessionDataTask *)uploadWithURLString:(NSString *)urlString data:(NSData *)data progress:(void(^)(NSProgress *progress))progress success:(void(^)(id responseObject))success failure:(void(^)(NSError *error))failure {
    __block HttpLog *log = [self bornHttpLog:@"UPLOAD" urlString:urlString param:data];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    return [self.afManager uploadTaskWithRequest:request fromData:data progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progress) {
            progress(uploadProgress);
        }
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            if (failure) {
                failure(error);
            }
            [self logHttpRequestContext:log resopnse:error];
        }else {
            if (success) {
                success(responseObject);
            }
             [self logHttpRequestContext:log resopnse:responseObject];
        }
    }];
}

- (HttpLog *)bornHttpLog:(NSString *)requestType urlString:(NSString *)urlString param:(id)param {
    __block BOOL beenTrace = [self.traceUrls containsObject:@"*"];
    if (urlString.length > 0 && !beenTrace) {
        NSURL *url = [NSURL URLWithString:urlString];
        [self.traceUrls enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([url.path isEqualToString:obj]) {
                beenTrace = YES;
                *stop = YES;
            }
        }];
    }
    if (beenTrace) {
        HttpLog *log = [[HttpLog alloc] init];
        log.requestType = requestType;
        log.url = urlString;
        log.requestTime = [self.formatter stringFromDate:[NSDate date]];
        log.params = [NSString stringWithFormat:@"%@", param];
        log.httpHeader = [NSString stringWithFormat:@"%@", self.afManager.requestSerializer.HTTPRequestHeaders];
        
        [self.halfwayLogs addObject:log];
        return log;
    }
    return nil;
}
- (void)logHttpRequestContext:(HttpLog *)log resopnse:(id)response {
    if (log) {
        log.responseTime = [self.formatter stringFromDate:[NSDate date]];
        log.response = [NSString stringWithFormat:@"%@", response];
        
        NSString *httpToolLog = [@"\n[HttpTool:RequestTrace]\n>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n" stringByAppendingFormat:@"%@", log];
        NSLog(@"%@\n<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<", httpToolLog);
        
        [self.halfwayLogs removeObject:log];
    }
}


- (NSDateFormatter *)formatter {
    if (!_formatter) {
        _formatter = [[NSDateFormatter alloc] init];
        [_formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    }
    return _formatter;
}

+ (void)setDisableProxySetting:(BOOL)disableProxySetting {
    _disableProxySetting = disableProxySetting;
}

+ (BOOL)disableProxySetting {
    return _disableProxySetting;
}
@end
