//
//  LLAPIClient.m
//  WXCitizenCard
//
//  Created by 刘江 on 2018/8/10.
//  Copyright © 2018年 Liujiang. All rights reserved.
//

#import "LLAPIClient.h"
#include <pthread.h>
@interface LLAPIClient ()

@property (nonatomic, strong)NSMutableDictionary *taskTable;

@property (nonatomic, strong)NSMutableDictionary *taskStartTime;

@property (nonatomic, strong)NSMutableDictionary *taskTryCount;

@property (nonatomic, strong)NSMutableDictionary *taskQueueRequestID; //临时存放任务队列的request_id

@property (nonatomic, strong)NSMutableArray *retryTasksQueue;

@end

@implementation LLAPIClient
pthread_mutex_t mutex_lock;
+ (instancetype)shareClient {
    static LLAPIClient *client = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        client = [[LLAPIClient alloc] init];
        client.taskTable = [NSMutableDictionary dictionaryWithCapacity:0];
        client.taskStartTime = [NSMutableDictionary dictionaryWithCapacity:0];
        client.taskTryCount = [NSMutableDictionary dictionaryWithCapacity:0];
        client.taskQueueRequestID = [NSMutableDictionary dictionaryWithCapacity:0];
        [client __initMutex];
    });
    return client;
}
- (void)__initMutex
{
    pthread_mutexattr_t attr;
    pthread_mutexattr_init(&attr);
    pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_NORMAL);
    pthread_mutex_init(&mutex_lock, &attr);
    pthread_mutexattr_destroy(&attr);
}

- (NSString *)callRequestWithRequestModel:(LLBaseRequestModel *)requestModel {
    __block NSURLSessionDataTask *task = [[NSURLSessionDataTask alloc] init];
     task = [LLRequestDispatch generateTaskWithRequestDataModel:requestModel progress:^(NSProgress *progress) {
        if (requestModel.progress) {
            requestModel.progress(progress);
        }
    } complete:^(NSDictionary *resp) {
        if (requestModel.complete) {
            dispatch_async(dispatch_get_main_queue(), ^{
                requestModel.complete(resp);
            });
        }
        
        __strong LLBaseRequestModel *reqModel = requestModel;
        NSString *requestID = [NSString stringWithFormat:@"%x", (unsigned int)task];
        [self resendRequestModel:requestModel responseObj:resp requestId:requestID];
        
        pthread_mutex_lock(&mutex_lock);
        [self.taskTable removeObjectForKey:requestID];
        pthread_mutex_unlock(&mutex_lock);
    }];
    
    pthread_mutex_lock(&mutex_lock);
    NSString *requestID = [NSString stringWithFormat:@"%x", (unsigned int)task];
    [self.taskTable setObject:task forKey:requestID];
    if (!self.taskStartTime[requestID]) {
        [self.taskStartTime setObject:@([[NSDate date] timeIntervalSince1970]) forKey:requestID];
    }
    [self.taskTryCount setObject:@([self.taskTryCount[requestID] integerValue]+1) forKey:requestID];
    pthread_mutex_unlock(&mutex_lock);
    
    return requestID;
}

#pragma mark --- 任务依赖
- (void)callRequestWithRequestModelQueue:(NSArray<LLBaseRequestModel *> *)requestModelQueue requestIDs:(void(^)(NSArray<NSString *> *ids))requestIDs {
    if ([requestModelQueue isKindOfClass:[NSMutableArray class]] && !self.taskQueueRequestID[[NSString stringWithFormat:@"%x", (unsigned int)requestModelQueue]]) {
        NSLog(@"### execute with a mutable modelQueue is not permitted");
        return;
    }
    
    __block NSMutableArray <LLBaseRequestModel *> *requestQueue = [requestModelQueue isKindOfClass:[NSMutableArray class]] ? requestModelQueue : [requestModelQueue mutableCopy];
    NSArray<LLBaseRequestModel *> *execQueue = [self readyRequestModels:requestQueue];
    
    if (requestQueue != requestModelQueue) {///首次进入
        [self.taskQueueRequestID setObject:[NSMutableArray arrayWithCapacity:0] forKey:[NSString stringWithFormat:@"%x", (unsigned int)requestQueue]];
        
    }
    
    [execQueue enumerateObjectsUsingBlock:^(LLBaseRequestModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

        typeof(self) __weak weakSelf = self;
        __block NSURLSessionDataTask *task = [[NSURLSessionDataTask alloc] init];
        task = [LLRequestDispatch generateTaskWithRequestDataModel:obj progress:^(NSProgress *progress) {
            if (obj.progress) {
                obj.progress(progress);
            }
        } complete:^(NSDictionary *resp) {
            if (obj.complete) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    obj.complete(resp);
                });
            }
            
            NSString *requestID = [NSString stringWithFormat:@"%x", (unsigned int)task];
            [weakSelf resendRequestModel:obj responseObj:resp requestId:requestID];
            
            pthread_mutex_lock(&mutex_lock);
            [weakSelf.taskTable removeObjectForKey:requestID];
            [requestQueue removeObject:obj];
            pthread_mutex_unlock(&mutex_lock);
            
            [self removeDenpency:requestQueue from:obj];
            [self callRequestWithRequestModelQueue:requestQueue requestIDs:requestIDs];
        }];
        pthread_mutex_lock(&mutex_lock);
        NSString *requestID = [NSString stringWithFormat:@"%x", (unsigned int)task];
        [self.taskTable setObject:task forKey:requestID];
        [self.taskQueueRequestID[@(requestQueue.hash)] addObject:requestID];
        if (!self.taskStartTime[requestID]) {
            [self.taskStartTime setObject:@([[NSDate date] timeIntervalSince1970]) forKey:requestID];
        }
        pthread_mutex_unlock(&mutex_lock);
    }];
    pthread_mutex_lock(&mutex_lock);
    if (execQueue.count == 0) {
        if (requestIDs) {
            requestIDs(self.taskQueueRequestID[@(requestQueue.hash)]);
        }
        [self.taskQueueRequestID removeObjectForKey:@(requestQueue.hash)];
    }
    pthread_mutex_unlock(&mutex_lock);
}


- (NSArray<LLBaseRequestModel *> *)readyRequestModels:(NSArray<LLBaseRequestModel *> *)requestModelQueue {
    __block NSMutableArray *readyQueue = [NSMutableArray arrayWithCapacity:0];
    pthread_mutex_lock(&mutex_lock);
    [requestModelQueue enumerateObjectsUsingBlock:^(LLBaseRequestModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.dependency.count == 0) {
            [readyQueue addObject:obj];
        }
    }];
    pthread_mutex_unlock(&mutex_lock);
    return readyQueue;
}

- (void)removeDenpency:(NSArray<LLBaseRequestModel *> *)requestModelQueue from:(LLBaseRequestModel *)dependencyModel {
    pthread_mutex_lock(&mutex_lock);
    [requestModelQueue enumerateObjectsUsingBlock:^(LLBaseRequestModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableArray *dependencyList = [obj.dependency mutableCopy];
        [dependencyList removeObject:dependencyModel];
        obj.dependency = dependencyList.copy;
    }];
    pthread_mutex_unlock(&mutex_lock);
}

#pragma mark --- 复制请求
- (void)resendRequestModel:(LLBaseRequestModel *)requestModel responseObj:(id)responseObj requestId:(NSString *)_id {
    if (!requestModel.retryHandler.retryCondition || !requestModel.retryHandler.retryCondition(responseObj)) {
        return;
    }
    __block NSInteger tryCount = requestModel.retryHandler.maxRetryCount.integerValue;
    __block NSTimeInterval duration = requestModel.retryHandler.maxRetryDuration.doubleValue;
    __block NSTimeInterval retryInterval = requestModel.retryHandler.retryInterval.doubleValue;
    pthread_mutex_lock(&mutex_lock);
    double timeCost = [[NSDate date] timeIntervalSince1970] - [self.taskStartTime[_id] doubleValue];
    NSInteger tryCountCost = [self.taskTryCount[_id] integerValue];
    pthread_mutex_unlock(&mutex_lock);
    if (requestModel.retryHandler.maxRetryDuration) {
        if (tryCount > 0 && duration > 0 && timeCost < duration && tryCountCost < tryCount) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(retryInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self callRequestWithRequestModel:requestModel];
            });
        }
    }else {
        if (tryCount > 0 && tryCountCost < tryCount) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(retryInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self callRequestWithRequestModel:requestModel];
            });
        }
        
    }
    
}


- (void)cancelRequestWithRequestID:(NSString *)requestID {
    pthread_mutex_lock(&mutex_lock);
    NSURLSessionDataTask *task = [self.taskTable objectForKey:requestID];
    [task cancel];
    [self.taskTable removeObjectForKey:requestID];
    [self.taskStartTime removeObjectForKey:requestID];
    [self.taskTryCount removeObjectForKey:requestID];
    pthread_mutex_unlock(&mutex_lock);
}

- (void)cancelRequestWithRequestIDList:(NSArray<NSString *> *)requestIDList {
    pthread_mutex_lock(&mutex_lock);
    typeof(self) __weak weakSelf = self;
    [requestIDList enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSURLSessionDataTask *task = [weakSelf.taskTable objectForKey:obj];
        [task cancel];
        
    }];
    [self.taskTable removeObjectsForKeys:requestIDList];
    [self.taskTryCount removeObjectsForKeys:requestIDList];
    [self.taskStartTime removeObjectsForKeys:requestIDList];
    pthread_mutex_unlock(&mutex_lock);
}

@end
