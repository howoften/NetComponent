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

+ (NSURLSessionDataTask *_Nullable)generateTaskWithRequestDataModel:(LLBaseRequestModel * _Nonnull)requestModel progress:(void(^_Nullable)(NSProgress *_Nullable))progress complete:(void(^_Nullable)(NSDictionary * _Nullable resp))complete;

@end
