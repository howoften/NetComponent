//
//  LLRequestDispatch.h
//  WXCitizenCard
//
//  Created by 刘江 on 2018/8/13.
//  Copyright © 2018年 Liujiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLBaseRequestModel.h"

@interface LLRequestDispatch : NSObject

+ (NSURLSessionDataTask *)generateWithRequestDataModel:(LLBaseRequestModel * _Nonnull)requestModel progress:(void(^)(NSProgress *))progress complete:(void(^)(NSDictionary *resp))complete;

@end
