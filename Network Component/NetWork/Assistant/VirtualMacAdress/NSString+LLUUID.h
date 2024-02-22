//
//  NSString+UUID.h
//  iOS
//
//  Created by 刘江 on 2017/12/19.
//  Copyright © 2017年 jiang liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (LLUUID)

+ (NSString *)virtualDeviceUUID;
+ (NSString *)virtualDeviceMacAddress;
+ (NSString *)virtualBlueToothUUID;
+ (NSString *)virtualBlueToothMac;
@end
