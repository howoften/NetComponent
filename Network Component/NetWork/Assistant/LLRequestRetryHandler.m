//
//  LLRequestRetryHandler.m
//  WXCitizenCard
//
//  Created by 刘江 on 2018/8/10.
//  Copyright © 2018年 Liujiang. All rights reserved.
//

#import "LLRequestRetryHandler.h"

@implementation LLRequestRetryHandler

- (instancetype)init
{
    self = [super init];
    if (self) {
        //default value
        self.maxRetryCount = @0;
        self.retryInterval = @(0.0);
    }
    return self;
}

- (void)setMaxRetryCount:(NSNumber *)maxRetryCount {
    if (maxRetryCount.integerValue > -1) {
        _maxRetryCount = @(maxRetryCount.integerValue);
    }
}

- (void)setMaxRetryDuration:(NSNumber *)maxRetryDuration {
    if (maxRetryDuration.doubleValue >= 0.f) {
        _maxRetryDuration = maxRetryDuration;
    }
}

- (void)setRetryInterval:(NSNumber *)retryInterval {
    if (retryInterval.doubleValue >= 0.f) {
        _retryInterval = retryInterval;
    }
}



@end
