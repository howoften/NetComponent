//
//  LLSignatureGenerator.m
//  WXCitizenCard
//
//  Created by 刘江 on 2018/8/10.
//  Copyright © 2018年 Liujiang. All rights reserved.
//

#import "LLSignatureGenerator.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonCryptor.h>

@implementation LLSignatureGenerator

+ (NSString *)signParameter:(NSDictionary *)param signToken:(NSString *)signToken {
    if (!param || param.allKeys.count < 1 || signToken.length < 1) {
        return nil;
    }
    NSArray *keys = param.allKeys;
    
    NSStringCompareOptions comparisonOptions = NSCaseInsensitiveSearch|NSNumericSearch|
    
    NSWidthInsensitiveSearch|NSForcedOrderingSearch;
    
    NSComparator sort = ^(NSString *obj1,NSString *obj2){
        
        NSRange range = NSMakeRange(0,obj1.length);
        
        return [obj1 compare:obj2 options:comparisonOptions range:range];
        
    };
    NSMutableString *signString = [NSMutableString stringWithCapacity:0];
    NSArray *sortedKeys = [keys sortedArrayUsingComparator:sort];
    for (int i = 0; i < sortedKeys.count; i++) {
        [signString appendFormat:@"%@=%@", sortedKeys[i], param[sortedKeys[i]]];
        if (i != sortedKeys.count-1) {
            [signString appendString:@"&"];
        }
    }
    [signString appendString:signToken];
    return [self md5:signString];
    
}

+ (NSString *)md5:(NSString *)input {
    const char *cStr = [[input dataUsingEncoding:NSUTF8StringEncoding] bytes];
    
    unsigned char digest[16];
    CC_MD5(cStr, (uint32_t)[[input dataUsingEncoding:NSUTF8StringEncoding] length], digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}

+ (NSString *)hmacSha256AndBase64:(NSString *)plainText encryptKey:(NSString *)key {
    
    const char *cKey = [key cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [plainText cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *theData = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    
    
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {  value |= (0xFF & input[j]);  }  }  NSInteger theIndex = (i / 3) * 4;  output[theIndex + 0] = table[(value >> 18) & 0x3F];
        output[theIndex + 1] = table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6) & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0) & 0x3F] : '=';
    }
    
    NSString *signResult = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return signResult;
}



+ (NSString *)desEncryptAndBase64:(NSString *)plainText encryptKey:(NSString *)key {
    if ([plainText isKindOfClass:NSString.class] && plainText.length) {
        NSData *data = [plainText dataUsingEncoding:NSUTF8StringEncoding];
        //IOS 自带DES加密 Begin
        NSData *desData = nil;
        char keyPtr[kCCKeySizeAES256 +1];
        bzero(keyPtr, sizeof(keyPtr));
        [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
        NSUInteger dataLength = [data length];
        size_t bufferSize = dataLength + kCCBlockSizeAES128;
        void *buffer = malloc(bufferSize);
        size_t numBytesEncrypted = 0;
        CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmDES,
                                              kCCOptionPKCS7Padding | kCCOptionECBMode,
                                              keyPtr, kCCBlockSizeDES,
                                              NULL,
                                              [data bytes], dataLength,
                                              buffer, bufferSize,
                                              &numBytesEncrypted);
        if (cryptStatus == kCCSuccess) {
            desData = [NSData dataWithBytesNoCopy:buffer length:(int)numBytesEncrypted];
        }
        free(buffer);
        if (!desData.length) {
            return @"";
        }
        char *characters = malloc((([desData length] + 2) / 3) * 4);
        if (characters == NULL) return nil;
        NSUInteger length = 0, i = 0;
        const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        while (i < [desData length]) {
            char buffer[3] = {0,0,0};
            short bufferLength = 0;
            while (bufferLength < 3 && i < [desData length])
                buffer[bufferLength++] = ((char *)[desData bytes])[i++];
            
            //  Encode the bytes in the buffer to four characters, including padding "=" characters if necessary.
            characters[length++] = encodingTable[(buffer[0] & 0xFC) >> 2];
            characters[length++] = encodingTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
            if (bufferLength > 1)
                characters[length++] = encodingTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
            else characters[length++] = '=';
            if (bufferLength > 2)
                characters[length++] = encodingTable[buffer[2] & 0x3F];
            else characters[length++] = '=';
        }
        
        return [[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSASCIIStringEncoding freeWhenDone:YES];
    }
    return @"";
}
+ (NSString *)desDecryptAndBase64:(NSString *)encryptText encryptKey:(NSString *)key {
    if ([encryptText isKindOfClass:NSString.class] && encryptText.length) {
        const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        static char *decodingTable = NULL;
        if (decodingTable == NULL) {
            decodingTable = malloc(256);
            if (decodingTable == NULL) return nil;
            memset(decodingTable, CHAR_MAX, 256);
            NSUInteger i;
            for (i = 0; i < 64; i++)
                decodingTable[(short)encodingTable[i]] = i;
        }
        
        const char *characters = [encryptText cStringUsingEncoding:NSASCIIStringEncoding];
        if (characters == NULL)     //  Not an ASCII string!
            return nil;
        char *bytes = malloc((([encryptText length] + 3) / 4) * 3);
        if (bytes == NULL)
            return nil;
        NSUInteger length = 0, i = 0;
        while (YES)
        {
            char buffer[4];
            short bufferLength;
            for (bufferLength = 0; bufferLength < 4; i++)
            {
                if (characters[i] == '\0')
                    break;
                if (isspace(characters[i]) || characters[i] == '=')
                    continue;
                buffer[bufferLength] = decodingTable[(short)characters[i]];
                if (buffer[bufferLength++] == CHAR_MAX)      //  Illegal character!
                {
                    free(bytes);
                    return nil;
                }
            }
            
            if (bufferLength == 0)
                break;
            if (bufferLength == 1)      //  At least two characters are needed to produce one byte!
            {
                free(bytes);
                return nil;
            }
            
            //  Decode the characters in the buffer to bytes.
            bytes[length++] = (buffer[0] << 2) | (buffer[1] >> 4);
            if (bufferLength > 2)
                bytes[length++] = (buffer[1] << 4) | (buffer[2] >> 2);
            if (bufferLength > 3)
                bytes[length++] = (buffer[2] << 6) | buffer[3];
        }
        
        bytes = realloc(bytes, length);
        NSData *data = [NSData dataWithBytesNoCopy:bytes length:length];
        
        //IOS 自带DES解密 Begin
        char keyPtr[kCCKeySizeAES256+1];
        bzero(keyPtr, sizeof(keyPtr));
        
        [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
        
        NSUInteger dataLength = [data length];
        
        size_t bufferSize = dataLength + kCCBlockSizeAES128;
        void *buffer = malloc(bufferSize);
        
        size_t numBytesDecrypted = 0;
        CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmDES,
                                              kCCOptionPKCS7Padding | kCCOptionECBMode,
                                              keyPtr, kCCBlockSizeDES,
                                              nil,
                                              [data bytes], dataLength,
                                              buffer, bufferSize,
                                              &numBytesDecrypted);
        
        if (cryptStatus == kCCSuccess) {
            data = [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
            free(buffer);
            return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }else {
            free(buffer);
            return nil;
        }
    }
    return @"";
}

@end
