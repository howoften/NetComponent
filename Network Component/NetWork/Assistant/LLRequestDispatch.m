//
//  LLRequestDispatch.m
//  WXCitizenCard
//
//  Created by 刘江 on 2018/8/13.
//  Copyright © 2018年 Liujiang. All rights reserved.
//

#import "LLRequestDispatch.h"
#import "LLServerFactory.h"
#import "LLCommonParamsGenerator.h"
#import "LLSignatureGenerator.h"
#import "NSString+NetResponseVerify.h"
#import "HttpTool.h"
#import "LLResponseFormatter.h"

@implementation LLRequestDispatch

+ (NSURLSessionDataTask *)generateWithRequestDataModel:(LLBaseRequestModel * _Nonnull)requestModel progress:(void(^)(NSProgress *))progress complete:(void(^)(NSDictionary *resp))complete {
    LLBaseServer *server = [LLServerFactory serverWithType:requestModel.serverType];
    if (server) {
        NSDictionary *commonHeader = [LLCommonParamsGenerator commonRequestHeaderParams];
        NSDictionary *commonReqParam = [LLCommonParamsGenerator commonRequestParameters];
        
        NSMutableDictionary *realParam = [NSMutableDictionary dictionaryWithDictionary:commonReqParam];
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
        NSString *signgam = [self signParamIfNeeded:requestModel server:server];
        if (signgam.length > 0) {
            [realParam setObject:requestModel.fileName forKey:@"sign"];
        }
        
        NSString *urlStr = [server.hostAddress stringByAppendingString:requestModel.requestPath ? requestModel.requestPath : @""];
        return [self sendHTTPRequest:urlStr requestType:requestModel.requestType params:realParam uploadData:requestModel.uploadData header:commonHeader progress:progress complete:complete];
        
    }
    return nil;
}


+ (NSURLSessionDataTask *)sendHTTPRequest:(NSString *)urlStr requestType:(LLAPIRequestType)requestType params:(NSDictionary *)params uploadData:(NSData *)uploadData header:(NSDictionary *)header progress:(void(^)(NSProgress *))progress complete:(void(^)(NSDictionary *resp))complete {
    [HttpTool refreshHTTPRequestHeader:header];
    if (requestType == LLAPIRequestTypeGet) {
        return [HttpTool getWithURLString:urlStr parameters:params progress:^(NSProgress *t_progress) {
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
        return [HttpTool postWithURLString:urlStr parameters:params progress:^(NSProgress *t_progress) {
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
        return [HttpTool postFormDataWithURLString:urlStr parameters:params progress:^(NSProgress *t_progress) {
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
        return [HttpTool putWithURLString:urlStr parameters:params success:^(id responseObject) {
            if (complete) {
                complete([LLResponseFormatter formatServerResponse:responseObject]);
            }
        } failure:^(NSError *error) {
            if (complete) {
                complete([LLResponseFormatter formatServerResponse:error]);
            }
        }];
    }else if (requestType == LLAPIRequestTypeDelete) {
        return [HttpTool deleteWithURLString:urlStr parameters:params success:^(id responseObject) {
            if (complete) {
                complete([LLResponseFormatter formatServerResponse:responseObject]);
            }
        } failure:^(NSError *error) {
            if (complete) {
                complete([LLResponseFormatter formatServerResponse:error]);
            }
        }];
    }else if (requestType == LLAPIRequestTypeUpload && uploadData.length > 0) {
        return [HttpTool uploadWithURLString:urlStr data:uploadData progress:^(NSProgress *t_progress) {
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

+ (NSString *)signParamIfNeeded:(LLBaseRequestModel *)requestModel server:(LLBaseServer *)server {
    __block BOOL skip = NO;
    __block NSMutableDictionary *signDic = [NSMutableDictionary dictionaryWithCapacity:0];
    [requestModel.signParamKeys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj isKindOfClass:[NSString class]]) {
            *stop = YES;
            skip = YES;
        }else {
            if (![requestModel.parameters.allKeys containsObject:obj]) {
                *stop = YES;
                skip = YES;
            }else {
                [signDic setObject:[NSString stringWithFormat:@"%@", requestModel.parameters[obj]] forKey:obj];
            }
        }
    }];
    
    if (!skip && signDic.allKeys.count == requestModel.signParamKeys.count) {
        return [LLSignatureGenerator signParameter:signDic signToken:server.signTokenInfo[requestModel.signToken]];
    }
    return nil;
}

@end
