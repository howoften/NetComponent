//
//  LLResponseFormatter.h
//  WXCitizenCard
//
//  Created by 刘江 on 2018/8/13.
//  Copyright © 2018年 Liujiang. All rights reserved.
//

#import <Foundation/Foundation.h>

//该类 用于模版化返回json 和 null剔除

@interface LLResponseFormatter : NSObject

+ (NSDictionary *)formatServerResponse:(id)response;

@end
