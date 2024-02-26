//
//  HttpTool.h
//  WXCitizenCard
//
//  Created by 刘江 on 2018/8/10.
//  Copyright © 2018年 Liujiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HttpTool : NSObject

- (void)refreshHTTPRequestHeader:(NSDictionary<NSString *, NSString *> *)header;

/**
 *  发送get请求
 *
 *  @param urlString    请求的网址字符串
 *  @param parameters   请求的参数
 *  @param success      请求成功的回调
 *  @param failure      请求失败的回调
 */
- (NSURLSessionDataTask *)getWithURLString:(NSString *)urlString parameters:(NSDictionary *)parameters progress:(void(^)(NSProgress *progress))progress success:(void(^)(id responseObject))success failure:(void(^)(NSError *error))failure;
/**
 *  post请求
 *  @param urlString    请求的网址字符串
 *  @param parameters   请求的参数
 *  @param success      请求成功的回调
 *  @param failure      请求失败的回调
 */
- (NSURLSessionDataTask *)postWithURLString:(NSString *)urlString parameters:(NSDictionary *)parameters progress:(void(^)(NSProgress *progress))progress success:(void(^)(id responseObject))success failure:(void(^)(NSError *error))failure;
/**
 *  post请求 param以表单形式提交
 *  @param urlString    请求的网址字符串
 *  @param parameters   请求的参数
 *  @param success      请求成功的回调
 *  @param failure      请求失败的回调
 */
- (NSURLSessionDataTask *)postFormDataWithURLString:(NSString *)urlString parameters:(NSDictionary *)parameters progress:(void(^)(NSProgress *progress))progress success:(void(^)(id responseObject))success failure:(void(^)(NSError *error))failure;

- (NSURLSessionDataTask *)putWithURLString:(NSString *)urlString parameters:(NSDictionary *)parameters success:(void(^)(id responseObject))success failure:(void(^)(NSError *error))failure;
/**
 
 */
- (NSURLSessionDataTask *)deleteWithURLString:(NSString *)urlString parameters:(NSDictionary *)parameters success:(void(^)(id responseObject))success failure:(void(^)(NSError *error))failure;

- (NSURLSessionDataTask *)uploadWithURLString:(NSString *)urlString data:(NSData *)data progress:(void(^)(NSProgress *progress))progress success:(void(^)(id responseObject))success failure:(void(^)(NSError *error))failure;


@end
