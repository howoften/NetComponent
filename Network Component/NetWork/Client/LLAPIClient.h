//
//  LLAPIClient.h
//  WXCitizenCard
//
//  Created by 刘江 on 2018/8/10.
//  Copyright © 2018年 Liujiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLRequestDispatch.h"
#import "LLBaseRequestModel.h"

@interface LLAPIClient : NSObject

+ (instancetype)shareClient;

//请求抽象为一个接口
- (NSString *)callRequestWithRequestModel:(LLBaseRequestModel *)requestModel;

- (void)callRequestWithRequestModelQueue:(NSArray<LLBaseRequestModel *> *)requestModelQueue requestIDs:(void(^)(NSArray<NSString *> *ids))requestIDs;


/**
 *  取消网络请求
 */
- (void)cancelRequestWithRequestID:(NSString *)requestID;

- (void)cancelRequestWithRequestIDList:(NSArray<NSString *> *)requestIDList;

@end
