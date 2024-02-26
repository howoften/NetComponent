//
//  LLSignatureGenerator.h
//  WXCitizenCard
//
//  Created by 刘江 on 2018/8/10.
//  Copyright © 2018年 Liujiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LLSignatureGenerator : NSObject

+ (NSString *)signParameter:(NSDictionary *)param signToken:(NSString *)signToken;

+ (NSString *)hmacSha256AndBase64:(NSString *)plainText encryptKey:(NSString *)key;
@end
