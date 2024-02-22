//
//  LLAPIClient.m
//  WXCitizenCard
//
//  Created by 刘江 on 2018/8/10.
//  Copyright © 2018年 Liujiang. All rights reserved.
//

#import "LLAPIClient.h"

@interface LLAPIClient ()

@property (nonatomic, strong)NSMutableDictionary *taskTable;

@property (nonatomic, strong)NSMutableDictionary *taskStartTime;

@property (nonatomic, strong)NSMutableDictionary *taskTryCount;

@property (nonatomic, strong)NSMutableDictionary *taskQueueRequestID; //临时存放任务队列的request_id

//@property (nonatomic, strong)NSMutableArray *retryTasksQueue;

@end

@implementation LLAPIClient

+ (instancetype)shareClient {
    static LLAPIClient *client = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        client = [[LLAPIClient alloc] init];
        
    });
    return client;
}


- (NSNumber *)callRequestWithRequestModel:(LLBaseRequestModel *)requestModel {
    
//    if (requestModel.retryHandler && ![self.retryTasksQueue containsObject:requestModel]) {
//        [self.retryTasksQueue addObject:requestModel];
//    }
    typeof(self) __weak weakSelf = self;
    __block NSURLSessionDataTask *task = [[NSURLSessionDataTask alloc] init];
     task = [LLRequestDispatch generateWithRequestDataModel:requestModel progress:^(NSProgress *progress) {
        if (requestModel.progress) {
            requestModel.progress(progress);
        }
    } complete:^(NSDictionary *resp) {
        if (requestModel.complete) {
            requestModel.complete(resp);
        }
        
        if ([resp[@"code"] integerValue] != Response_Success_Code) {
            [weakSelf resendRequestModel:requestModel errorCode:[resp[@"code"] integerValue] requestId:[NSNumber numberWithUnsignedInteger:task.hash]];
        }
        
        NSNumber *requestID = [NSNumber numberWithUnsignedInteger:task.hash];
        [weakSelf.taskTable removeObjectForKey:requestID];
    }];
    NSNumber *requestID = [NSNumber numberWithUnsignedInteger:task.hash];
    [self.taskTable setObject:task forKey:requestID];
    if (!self.taskStartTime[requestID]) {
        [self.taskStartTime setObject:@([[NSDate date] timeIntervalSince1970]) forKey:requestID];
    }
    [self.taskTryCount setObject:@([self.taskTryCount[requestID] integerValue]+1) forKey:requestID];
    
    return requestID;
}

#pragma mark --- 任务依赖
- (void)callRequestWithRequestModelQueue:(NSArray<LLBaseRequestModel *> *)requestModelQueue requestIDs:(void(^)(NSArray<NSNumber *> *ids))requestIDs {
    
//    [requestModelQueue enumerateObjectsUsingBlock:^(LLBaseRequestModel * _Nonnull requestModel, NSUInteger idx, BOOL * _Nonnull stop) {
//        if (requestModel.retryHandler && ![self.retryTasksQueue containsObject:requestModel]) {
//            [self.retryTasksQueue addObject:requestModel];
//        }
//    }];
    
    if ([requestModelQueue isKindOfClass:[NSMutableArray class]] && !self.taskQueueRequestID[@(requestModelQueue.hash)]) {
        NSLog(@"### execute with a mutable modelQueue is not permitted");
        return;
    }
    
    __block NSMutableArray <LLBaseRequestModel *> *requestQueue = [requestModelQueue isKindOfClass:[NSMutableArray class]] ? requestModelQueue : [requestModelQueue mutableCopy];
    NSArray<LLBaseRequestModel *> *execQueue = [self readyRequestModels:requestQueue];
    
    if (requestQueue != requestModelQueue) {///首次进入
        [self.taskQueueRequestID setObject:[NSMutableArray arrayWithCapacity:0] forKey:@(requestQueue.hash)];
        
    }
    
    [execQueue enumerateObjectsUsingBlock:^(LLBaseRequestModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

        typeof(self) __weak weakSelf = self;
        __block NSURLSessionDataTask *task = [[NSURLSessionDataTask alloc] init];
        task = [LLRequestDispatch generateWithRequestDataModel:obj progress:^(NSProgress *progress) {
            if (obj.progress) {
                obj.progress(progress);
            }
        } complete:^(NSDictionary *resp) {
            if (obj.complete) {
                obj.complete(resp);
            }
            
            if ([resp[@"code"] integerValue] != Response_Success_Code) {
                [weakSelf resendRequestModel:obj errorCode:[resp[@"code"] integerValue] requestId:[NSNumber numberWithUnsignedInteger:task.hash]];
            }
            
            NSNumber *requestID = [NSNumber numberWithUnsignedInteger:task.hash];
            [weakSelf.taskTable removeObjectForKey:requestID];
            
            [requestQueue removeObject:obj];
            [self removeDenpency:requestQueue from:obj];
            [self callRequestWithRequestModelQueue:requestQueue requestIDs:requestIDs];
        }];
        NSNumber *requestID = [NSNumber numberWithUnsignedInteger:task.hash];
        [self.taskTable setObject:task forKey:requestID];
        [self.taskQueueRequestID[@(requestQueue.hash)] addObject:requestID];
        if (!self.taskStartTime[requestID]) {
            [self.taskStartTime setObject:@([[NSDate date] timeIntervalSince1970]) forKey:requestID];
        }
        
    }];
    
    if (execQueue.count == 0) {
        if (requestIDs) {
            requestIDs(self.taskQueueRequestID[@(requestQueue.hash)]);
        }
        [self.taskQueueRequestID removeObjectForKey:@(requestQueue.hash)];
    }
}


- (NSArray<LLBaseRequestModel *> *)readyRequestModels:(NSArray<LLBaseRequestModel *> *)requestModelQueue {
    __block NSMutableArray *readyQueue = [NSMutableArray arrayWithCapacity:0];
    [requestModelQueue enumerateObjectsUsingBlock:^(LLBaseRequestModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.dependency.count == 0) {
            [readyQueue addObject:obj];
        }
    }];
    
    return readyQueue;
}

- (void)removeDenpency:(NSArray<LLBaseRequestModel *> *)requestModelQueue from:(LLBaseRequestModel *)dependency {
    [requestModelQueue enumerateObjectsUsingBlock:^(LLBaseRequestModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj.dependency enumerateObjectsUsingBlock:^(LLBaseRequestModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj == dependency) {
                [obj.dependency removeObject:obj];
            }
        }];
    }];
}

#pragma mark --- 复制请求
- (void)resendRequestModel:(LLBaseRequestModel *)requestModel errorCode:(NSInteger)code requestId:(NSNumber *)_id {
    if (requestModel.retryHandler) {
        __block NSInteger tryCount = requestModel.retryHandler.maxRetryCount.integerValue;
        __block NSTimeInterval duration = requestModel.retryHandler.maxRetryDuration.doubleValue;
        __block NSTimeInterval retryInterval = requestModel.retryHandler.retryInterval.doubleValue;
        if (requestModel.retryHandler.maxRetryDuration) {
            if (tryCount > 0 && duration > 0 && [[NSDate date] timeIntervalSince1970] - [self.taskStartTime[_id] doubleValue] < duration && [self.taskTryCount[_id] integerValue] < tryCount) {
                if (requestModel.retryHandler.errorCode.integerValue == code) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(retryInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self callRequestWithRequestModel:requestModel];
                    });
                }else if (requestModel.retryHandler.retryCondition) {
                    if (requestModel.retryHandler.retryCondition()) {
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(retryInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [self callRequestWithRequestModel:requestModel];
                        });
                        
                    }
                }
            }
        }else {
            if (tryCount > 0 && [self.taskTryCount[_id] integerValue] < tryCount) {

                if (requestModel.retryHandler.errorCode.integerValue == code) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(retryInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self callRequestWithRequestModel:requestModel];
                    });
                }else if (requestModel.retryHandler.retryCondition) {
                    if (requestModel.retryHandler.retryCondition()) {
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(retryInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [self callRequestWithRequestModel:requestModel];
                        });
                    }
                }
            }
            
        }
    }
}

- (void)callRetryRequestModel:(LLBaseRequestModel *)requestModel {
    
    
}

- (void)cancelRequestWithRequestID:(NSNumber *)requestID {
    NSURLSessionDataTask *task = [self.taskTable objectForKey:requestID];
    [task cancel];
    [self.taskTable removeObjectForKey:requestID];
    [self.taskStartTime removeObjectForKey:requestID];
    [self.taskTryCount removeObjectForKey:requestID];
}

- (void)cancelRequestWithRequestIDList:(NSArray<NSNumber *> *)requestIDList {
    typeof(self) __weak weakSelf = self;
    [requestIDList enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSURLSessionDataTask *task = [weakSelf.taskTable objectForKey:obj];
        [task cancel];
        
    }];
    [self.taskTable removeObjectsForKeys:requestIDList];
    [self.taskTryCount removeObjectsForKeys:requestIDList];
    [self.taskStartTime removeObjectsForKeys:requestIDList];
}


- (NSMutableDictionary *)taskTable {
    if (!_taskTable) {
        _taskTable = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return _taskTable;
}

- (NSMutableDictionary *)taskStartTime {
    if (!_taskStartTime) {
        _taskStartTime = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return _taskStartTime;
}

- (NSMutableDictionary *)taskTryCount {
    if (!_taskTryCount) {
        _taskTryCount = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return _taskTryCount;
}

- (NSMutableDictionary *)taskQueueRequestID {
    if (!_taskQueueRequestID) {
        _taskQueueRequestID = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return _taskQueueRequestID;
}

//- (NSMutableArray *)retryTasksQueue {
//    if (!_retryTasksQueue) {
//        _retryTasksQueue = [NSMutableArray arrayWithCapacity:0];
//    }
//    return _retryTasksQueue;
//}

@end
