//
//  LLAppContext.m
//  WXCitizenCard
//
//  Created by 刘江 on 2018/8/10.
//  Copyright © 2018年 Liujiang. All rights reserved.
//

#import <sys/utsname.h>
#import "LLAppContext.h"
#import "NSString+LLUUID.h"
#import <UIKit/UIKit.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

@implementation LLAppContext

- (NSString *)channelID {
    return @"App Store";
}

- (NSString *)app_client_id {
    return @"mobile";
}

- (NSString *)appName {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
}

- (NSString *)device_name {
    return [[UIDevice currentDevice] name];
}

- (NSString *)os_name {
    return [[UIDevice currentDevice] systemName];
}

- (NSString *)os_version {
    return [[UIDevice currentDevice] systemVersion];
}

- (NSString *)build_version {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

- (NSString *)bundle_id {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
}

- (NSString *)app_version {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

- (NSString *)device_model {
    static NSString *cachedModel = nil;
    
    if (cachedModel.length > 0) {
        return cachedModel;
    }
    
    struct utsname systemInfo;
    
    uname(&systemInfo);
    
    NSString *platform = [NSString stringWithCString: systemInfo.machine encoding:NSASCIIStringEncoding];
    if (!platform) return @"iPhone";
    
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 2G";
    
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G";
    
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS";
    
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,2"])    return @"Verizon iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([platform isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([platform isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([platform isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([platform isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([platform isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([platform isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
    if ([platform isEqualToString:@"iPhone9,1"])    return @"iPhone 7"; //国行、日版、港行
    if ([platform isEqualToString:@"iPhone9,2"])    return @"iPhone 7 Plus"; //国行、港行
    if ([platform isEqualToString:@"iPhone9,3"])    return @"iPhone 7"; //美版、台版
    if ([platform isEqualToString:@"iPhone9,4"])    return @"iPhone 7 Plus"; //美版、台版
    if ([platform isEqualToString:@"iPhone10,1"])    return @"iPhone 8"; //国行(A1863)、日行(A1906)
    if ([platform isEqualToString:@"iPhone10,2"])    return @"iPhone 8 Plus"; //国行(A1864)、日行(A1898)
    if ([platform isEqualToString:@"iPhone10,3"])    return @"iPhone X"; //国行(A1865)、日行(A1902)
    if ([platform isEqualToString:@"iPhone10,4"])    return @"iPhone 8"; //美版(Global/A1905)
    if ([platform isEqualToString:@"iPhone10,5"])    return @"iPhone 8 Plus"; //美版(Global/A1897)
    if ([platform isEqualToString:@"iPhone10,6"])    return @"iPhone X";//美版(Global/A1901)
    if ([platform isEqualToString:@"iPhone11,8"])    return @"iPhone XR";
    if ([platform isEqualToString:@"iPhone11,2"])    return @"iPhone XS";
    if ([platform isEqualToString:@"iPhone11,6"])    return @"iPhone XS Max";
    if ([platform isEqualToString:@"iPhone11,4"])    return @"iPhone XS Max";
    if ([platform isEqualToString:@"iPhone12,1"])    return @"iPhone 11";
    if ([platform isEqualToString:@"iPhone12,3"])    return @"iPhone 11 Pro";
    if ([platform isEqualToString:@"iPhone12,5"])    return @"iPhone 11 Pro Max";
    if ([platform isEqualToString:@"iPhone12,8"])    return @"iPhone SE"; //(2nd generation)
    if ([platform isEqualToString:@"iPhone13,1"])    return @"iPhone 12 mini";
    if ([platform isEqualToString:@"iPhone13,2"])    return @"iPhone 12";
    if ([platform isEqualToString:@"iPhone13,3"])    return @"iPhone 12 Pro";
    if ([platform isEqualToString:@"iPhone13,4"])    return @"iPhone 12 Pro Max";
    if ([platform isEqualToString:@"iPhone14,2"])    return @"iPhone 13 Pro";
    if ([platform isEqualToString:@"iPhone14,3"])    return @"iPhone 13 Pro Max";
    if ([platform isEqualToString:@"iPhone14,4"])    return @"iPhone 13 mini";
    if ([platform isEqualToString:@"iPhone14,5"])    return @"iPhone 13";
    if ([platform isEqualToString:@"iPhone14,6"])    return @"iPhone SE"; //(2nd generation)
    if ([platform isEqualToString:@"iPhone14,7"])    return @"iPhone 14";
    if ([platform isEqualToString:@"iPhone14,8"])    return @"iPhone 14 Plus";
    if ([platform isEqualToString:@"iPhone15,2"])    return @"iPhone 14 Pro";
    if ([platform isEqualToString:@"iPhone15,3"])    return @"iPhone 14 Pro Max";
    if ([platform isEqualToString:@"iPhone15,4"])    return @"iPhone 15";
    if ([platform isEqualToString:@"iPhone15,5"])    return @"iPhone 15 Plus";
    if ([platform isEqualToString:@"iPhone16,1"])    return @"iPhone 15 Pro";
    if ([platform isEqualToString:@"iPhone16,2"])    return @"iPhone 15 Pro Max";
    
    //iPad
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([platform isEqualToString:@"iPad1,2"])      return @"iPad 3G";
    
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([platform isEqualToString:@"iPad2,6"])      return @"iPad Mini";
    if ([platform isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    
    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([platform isEqualToString:@"iPad3,5"])      return @"iPad 4";
    if ([platform isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    
    if ([platform isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([platform isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
    if ([platform isEqualToString:@"iPad4,3"])      return @"iPad Air";
    
    if ([platform isEqualToString:@"iPad4,4"])      return @"iPad Mini 2 (WiFi)";
    if ([platform isEqualToString:@"iPad4,5"])      return @"iPad Mini 2 (Cellular)";
    if ([platform isEqualToString:@"iPad4,6"])      return @"iPad Mini 2";
    
    if ([platform isEqualToString:@"iPad4,7"])      return @"iPad Mini 3";
    if ([platform isEqualToString:@"iPad4,8"])      return @"iPad Mini 3";
    if ([platform isEqualToString:@"iPad4,9"])      return @"iPad Mini 3";
    
    if ([platform isEqualToString:@"iPad5,1"])      return @"iPad Mini 4 (WiFi)";
    if ([platform isEqualToString:@"iPad5,2"])      return @"iPad Mini 4 (LTE)";
    if ([platform isEqualToString:@"iPad5,3"])      return @"iPad Air 2";
    if ([platform isEqualToString:@"iPad5,4"])      return @"iPad Air 2";
    
    if ([platform isEqualToString:@"iPad6,3"])      return @"iPad Pro 9.7";
    if ([platform isEqualToString:@"iPad6,4"])      return @"iPad Pro 9.7";
    if ([platform isEqualToString:@"iPad6,7"])      return @"iPad Pro 12.9";
    if ([platform isEqualToString:@"iPad6,8"])      return @"iPad Pro 12.9";
    
    if ([platform isEqualToString:@"iPad6,11"])     return @"iPad 5th";
    if ([platform isEqualToString:@"iPad6,12"])     return @"iPad 5th";
    
    if ([platform isEqualToString:@"iPad7,1"])      return @"iPad Pro 12.9 2nd";
    if ([platform isEqualToString:@"iPad7,2"])      return @"iPad Pro 12.9 2nd";
    if ([platform isEqualToString:@"iPad7,3"])      return @"iPad Pro 10.5";
    if ([platform isEqualToString:@"iPad7,4"])      return @"iPad Pro 10.5";
    
    if ([platform isEqualToString:@"iPad7,5"])      return @"iPad 6th";
    if ([platform isEqualToString:@"iPad7,6"])      return @"iPad 6th";
    
    if ([platform isEqualToString:@"iPad8,1"])      return @"iPad Pro 11";
    if ([platform isEqualToString:@"iPad8,2"])      return @"iPad Pro 11";
    if ([platform isEqualToString:@"iPad8,3"])      return @"iPad Pro 11";
    if ([platform isEqualToString:@"iPad8,4"])      return @"iPad Pro 11";
    
    if ([platform isEqualToString:@"iPad8,5"])      return @"iPad Pro 12.9 3rd";
    if ([platform isEqualToString:@"iPad8,6"])      return @"iPad Pro 12.9 3rd";
    if ([platform isEqualToString:@"iPad8,7"])      return @"iPad Pro 12.9 3rd";
    if ([platform isEqualToString:@"iPad8,8"])      return @"iPad Pro 12.9 3rd";
    
    if ([platform isEqualToString:@"iPad11,1"])      return @"iPad mini 5th";
    if ([platform isEqualToString:@"iPad11,2"])      return @"iPad mini 5th";
    if ([platform isEqualToString:@"iPad11,3"])      return @"iPad Air 3rd";
    if ([platform isEqualToString:@"iPad11,4"])      return @"iPad Air 3rd";
    
    if ([platform isEqualToString:@"iPad11,6"])      return @"iPad 8th";
    if ([platform isEqualToString:@"iPad11,7"])      return @"iPad 8th";
    
    if ([platform isEqualToString:@"iPad12,1"])      return @"iPad 9th";
    if ([platform isEqualToString:@"iPad12,2"])      return @"iPad 9th";
    
    if ([platform isEqualToString:@"iPad14,1"])      return @"iPad mini 6th";
    if ([platform isEqualToString:@"iPad14,2"])      return @"iPad mini 6th";

    //iPod
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"])      return @"iPod Touch (5 Gen)";
    if ([platform isEqualToString:@"iPod7,1"])      return @"iPod Touch (6 Gen)";
    if ([platform isEqualToString:@"iPod9,1"])      return @"iPod Touch (7 Gen)";
    
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    
    
    cachedModel = platform;
    
    return platform;
}

- (NSString *)qtime
{
    NSString *time = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
    return time;
}

- (NSString *)device_id {
    return [[NSString virtualDeviceUUID] stringByReplacingOccurrencesOfString:@"-" withString:@""];
}

/// 获取手机SIM卡网络运营商名称
- (NSString *)carrierName {
    __block NSString *carrier = nil;
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    if (@available(iOS 12.0, *)) {
        [info.serviceSubscriberCellularProviders enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, CTCarrier * _Nonnull obj, BOOL * _Nonnull stop) {
            if (!carrier.length) {
                carrier = obj.carrierName;
                *stop = YES;
            }
        }];
    }else {
        CTCarrier *carrierInfo = info.subscriberCellularProvider;
        carrier = carrierInfo.carrierName;
    }
    return carrier;
}
/// 获取当前手机SIM卡网络运营商名称
- (NSString *)chinaCarrierName {
    __block NSString *mcc = @"", *mnc = @"";
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    if (@available(iOS 12.0, *)) {
        [info.serviceSubscriberCellularProviders enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, CTCarrier * _Nonnull obj, BOOL * _Nonnull stop) {
            if (obj.mobileNetworkCode != nil) {
                mcc = obj.mobileCountryCode ?: @"";
                mnc = obj.mobileNetworkCode ?: @"";
                *stop = YES;
            }
        }];
    } else {
        CTCarrier *carrier = info.subscriberCellularProvider;
        mcc = carrier.mobileCountryCode ?: @"";
        mnc = carrier.mobileNetworkCode ?: @"";
    }
    if (![mcc isEqualToString:@"460"])  { return nil; }
    NSString *tempCarrier = nil;
    if ([@[@"00", @"02", @"04", @"07", @"08", @""]  containsObject:mnc]) {
        tempCarrier = @"中国移动";
    } else if ([@[@"01", @"06", @"09"] containsObject:mnc]) {
        tempCarrier = @"中国联通";
    } else if ([@[@"03", @"05", @"11"] containsObject:mnc]) {
        tempCarrier = @"中国电信";
    } else if ([@[@"15"] containsObject:mnc]) {
        tempCarrier = @"中国广电";
    } else if ([@[@"20"] containsObject:mnc]) {
        tempCarrier = @"中国铁通";
    }
    return tempCarrier;
}

- (CGSize)screenSize {
    CGFloat height = CGRectGetHeight([UIScreen mainScreen].nativeBounds) / [UIScreen mainScreen].scale;
    CGFloat width = CGRectGetWidth([UIScreen mainScreen].nativeBounds) / [UIScreen mainScreen].scale;
    
    return (CGSize){MIN(height, width), MAX(height, width)};
}
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static LLAppContext *appContext = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        appContext = [super allocWithZone:zone];
    });
    return appContext;
}

@end
