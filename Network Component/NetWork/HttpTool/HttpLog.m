//
//  HttpLog.m
//  WXCitizenCard
//
//  Created by 刘江 on 2018/8/18.
//  Copyright © 2018年 Liujiang. All rights reserved.
//

#import "HttpLog.h"

@implementation HttpLog
- (instancetype)init
{
    self = [super init];
    if (self) {
        _id_ = [NSString stringWithFormat:@"%p", self];
    }
    return self;
}

- (NSString *)description {
    [super description];
    NSArray *output = @[
                        @"requestType",
                        @"requestTime",
                        @"responseTime",
                        @"url",
                        @"httpHeader",
                        @"params",
                        @"response",
                        ];
    NSMutableString *des = [NSMutableString string];
    for (int i = 0; i < output.count; i++) {
        [des appendFormat:@"%@ = %@\n", output[i], [self valueForKey:output[i]]];

    }
    return des;
}
@end
