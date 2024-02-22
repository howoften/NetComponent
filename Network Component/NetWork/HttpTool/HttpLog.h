//
//  HttpLog.h
//  WXCitizenCard
//
//  Created by 刘江 on 2018/8/18.
//  Copyright © 2018年 Liujiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HttpLog : NSObject
@property (nonatomic, strong, readonly)NSString *id_;
@property (nonatomic, strong)NSString *requestType;
@property (nonatomic, strong)NSString *requestTime;
@property (nonatomic, strong)NSString *url;
@property (nonatomic, strong)NSString *responseTime;
@property (nonatomic, strong)NSString *params;
@property (nonatomic, strong)NSString *response;
@property (nonatomic, strong)NSString *httpHeader;

@end
