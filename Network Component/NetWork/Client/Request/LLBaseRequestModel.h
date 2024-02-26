//
//  LLBaseRequestModel.h
//  WXCitizenCard
//
//  Created by 刘江 on 2018/8/10.
//  Copyright © 2018年 Liujiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerConfig.h"
#import "LLRequestRetryHandler.h"

@interface LLBaseRequestModel : NSObject

@property (nonatomic, assign)LLServerType serverType; //服务器标识
@property (nonatomic, strong)NSString *requestPath; //请求路径
@property (nonatomic, assign)LLAPIRequestType requestType;
@property (nonatomic, strong)NSDictionary *headerParameters;
@property (nonatomic, strong)NSDictionary *parameters;
//@property (nonatomic, strong)NSString *signToken;
//@property (nonatomic, strong)NSString *signRepresentKey;
//@property (nonatomic, strong)NSArray<NSString *> *signParamKeys;//待签名字段  ,signParamKeys 为 parameters子集
@property (nonatomic, strong)void(^complete)(NSDictionary *response);
@property (nonatomic, strong)void(^progress)(NSProgress *progress);

@property (nonatomic, strong)NSArray<LLBaseRequestModel *> *dependency;
@property (nonatomic, strong)LLRequestRetryHandler *retryHandler;

// upload
// filePath & uploadData 实现其一
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) NSData *uploadData;
@property (nonatomic, strong) NSString *dataName;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSString *mimeType;

@end
