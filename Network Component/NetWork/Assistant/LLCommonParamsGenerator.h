//
//  LLCommonParamsGenerator.h
//  WXCitizenCard
//
//  Created by 刘江 on 2018/8/10.
//  Copyright © 2018年 Liujiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLAppContext.h"

@interface LLCommonParamsGenerator : NSObject

+ (NSDictionary *)commonRequestHeaderParams;

+ (NSDictionary *)commonRequestParameters;

@end
