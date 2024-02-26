//
//  LLRequestDispatch.m
//  WXCitizenCard
//
//  Created by 刘江 on 2018/8/13.
//  Copyright © 2018年 Liujiang. All rights reserved.
//

#import "LLRequestDispatch.h"
#import "LLServerFactory.h"
#import "LLSignatureGenerator.h"
#import "NSString+NetResponseVerify.h"
#import "LLResponseFormatter.h"
 
@implementation LLRequestDispatch

+ (NSURLSessionDataTask *)generateTaskWithRequestDataModel:(LLBaseRequestModel * _Nonnull)requestModel progress:(void(^)(NSProgress *))progress complete:(void(^)(NSDictionary *resp))complete {
    LLBaseServer <LLBaseServiceProtocol> *server = [LLServerFactory serverWithType:requestModel.serverType];
    if (server) {
        NSDictionary *commonHeader = [server commonRequestHeaderParametersFor:requestModel];
        NSDictionary *commonReqParam = [server commonRequestParametersFor:requestModel];
        
        NSMutableDictionary *realParam = [NSMutableDictionary dictionaryWithDictionary:commonReqParam ?: @{}];
        [realParam addEntriesFromDictionary:requestModel.parameters];
        if (requestModel.filePath.length > 0) {
            [realParam setObject:requestModel.filePath forKey:@"filePath"];
        }
        if (requestModel.dataName.length > 0) {
            [realParam setObject:requestModel.dataName forKey:@"dataName"];
        }
        if (requestModel.fileName.length > 0) {
            [realParam setObject:requestModel.fileName forKey:@"fileName"];
        }
        if (requestModel.mimeType.length > 0) {
            [realParam setObject:requestModel.mimeType forKey:@"mimeType"];
        }
        
        
        NSMutableDictionary *realHeader = [NSMutableDictionary dictionaryWithDictionary:commonHeader ?: @{}];
        [realHeader addEntriesFromDictionary:requestModel.headerParameters];
        
        NSString *urlStr = [server.hostAddress stringByAppendingString:requestModel.requestPath ?: @""];
        return [self sendHTTPRequest:server urlStr:urlStr requestType:requestModel.requestType params:realParam uploadData:requestModel.uploadData header:realHeader progress:progress complete:complete];
        
    }
    return nil;
}


+ (NSURLSessionDataTask *)sendHTTPRequest:(LLBaseServer <LLBaseServiceProtocol> *)server urlStr:(NSString *)urlStr requestType:(LLAPIRequestType)requestType params:(NSDictionary *)params uploadData:(NSData *)uploadData header:(NSDictionary *)header progress:(void(^)(NSProgress *))progress complete:(void(^)(NSDictionary *resp))complete {
    [server.httpTool refreshHTTPRequestHeader:header];
    if (requestType == LLAPIRequestTypeGet) {
        return [server.httpTool getWithURLString:urlStr parameters:params progress:^(NSProgress *t_progress) {
            if (progress) {
                progress(t_progress);
            }
        } success:^(id responseObject) {
            if (complete) {
                complete([LLResponseFormatter formatServerResponse:responseObject]);
            }
        } failure:^(NSError *error) {
            if (complete) {
                complete([LLResponseFormatter formatServerResponse:error]);
            }
        }];
    }else if (requestType == LLAPIRequestTypePost) {
        return [server.httpTool postWithURLString:urlStr parameters:params progress:^(NSProgress *t_progress) {
            if (progress) {
                progress(t_progress);
            }
        } success:^(id responseObject) {
            if (complete) {
                complete([LLResponseFormatter formatServerResponse:responseObject]);
            }
        } failure:^(NSError *error) {
            if (complete) {
                complete([LLResponseFormatter formatServerResponse:error]);
            }
        }];
    }else if (requestType == LLAPIRequestTypePostForm) {
        return [server.httpTool postFormDataWithURLString:urlStr parameters:params progress:^(NSProgress *t_progress) {
            if (progress) {
                progress(t_progress);
            }
        } success:^(id responseObject) {
            if (complete) {
                complete([LLResponseFormatter formatServerResponse:responseObject]);
            }
        } failure:^(NSError *error) {
            if (complete) {
                complete([LLResponseFormatter formatServerResponse:error]);
            }
        }];
    }else if (requestType == LLAPIRequestTypePut) {
        return [server.httpTool putWithURLString:urlStr parameters:params success:^(id responseObject) {
            if (complete) {
                complete([LLResponseFormatter formatServerResponse:responseObject]);
            }
        } failure:^(NSError *error) {
            if (complete) {
                complete([LLResponseFormatter formatServerResponse:error]);
            }
        }];
    }else if (requestType == LLAPIRequestTypeDelete) {
        return [server.httpTool deleteWithURLString:urlStr parameters:params success:^(id responseObject) {
            if (complete) {
                complete([LLResponseFormatter formatServerResponse:responseObject]);
            }
        } failure:^(NSError *error) {
            if (complete) {
                complete([LLResponseFormatter formatServerResponse:error]);
            }
        }];
    }else if (requestType == LLAPIRequestTypeUpload && uploadData.length > 0) {
        return [server.httpTool uploadWithURLString:urlStr data:uploadData progress:^(NSProgress *t_progress) {
            if (progress) {
                progress(t_progress);
            }
        } success:^(id responseObject) {
            if (complete) {
                complete([LLResponseFormatter formatServerResponse:responseObject]);
            }
        } failure:^(NSError *error) {
            if (complete) {
                complete([LLResponseFormatter formatServerResponse:error]);
            }
        }];
    }
    return nil;
}

@end
