//
//  KeyChainSaver.h
//  WXCitizenCard
//
//  Created by 刘江 on 2018/8/4.
//  Copyright © 2018年 Liujiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LLKeyChainSaver : NSObject

+ (void)saveWithKey:(NSString *)key data:(id)data;

+ (id)loadByKey:(NSString *)key;

@end
