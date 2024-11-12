//
//  NSString+NetResponseVerify.m
//  WXCitizenCard
//
//  Created by 刘江 on 2018/8/13.
//  Copyright © 2018年 Liujiang. All rights reserved.
//

#import "NSString+NetResponseVerify.h"

@implementation NSString (NetResponseVerify)

+ (BOOL)isEmptyString:(NSString *)string
{
    if (!string) {
        return YES;
    }
    if (![string isKindOfClass:[NSString class]]) {
        return YES;
    }
    return string.length == 0;
}

@end
