//
//  LLRequestRetryHandler.h
//  WXCitizenCard
//
//  Created by 刘江 on 2018/8/10.
//  Copyright © 2018年 Liujiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LLRequestRetryHandler : NSObject

@property (nonatomic, strong)NSNumber *maxRetryCount; //default INT64_MAX

@property (nonatomic, strong)NSNumber *maxRetryDuration;//default nil

@property (nonatomic, strong)NSNumber *retryInterval;//default 0

@property (nonatomic, copy)BOOL(^retryCondition)(id resp);

@end
