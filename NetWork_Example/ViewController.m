//
//  ViewController.m
//  NetWork_Example
//
//  Created by 刘江 on 2019/10/15.
//  Copyright © 2019 Liujiang. All rights reserved.
//

#import "ViewController.h"
#import "LLAPIClient.h"
@interface ViewController ()
@property (nonatomic, strong)LLBaseRequestModel *normalRequestModel;

@property (nonatomic, strong)LLBaseRequestModel *retryRequestModel;

@property (nonatomic, strong)LLBaseRequestModel *dependcyRequestModel;

@property (nonatomic, strong)LLBaseRequestModel *greenCloudRequestModel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //可以再 HttpRequestTrace.plist文件中配置log的request  '*'代表log所有request
    //更多设置 待更新
    /*
    //send normal request
    [[LLAPIClient shareClient] callRequestWithRequestModel:self.normalRequestModel];
    self.normalRequestModel.complete = ^(NSDictionary *response) {

    };
    
    //send retry request
    [[LLAPIClient shareClient] callRequestWithRequestModel:self.retryRequestModel];
    self.retryRequestModel.complete = ^(NSDictionary *response) {
        NSLog(@"retry!!");
    };
    
    //send dependcy request
    [[LLAPIClient shareClient] callRequestWithRequestModelQueue:@[self.normalRequestModel, self.dependcyRequestModel] requestIDs:nil];
    self.dependcyRequestModel.complete = ^(NSDictionary *response) {
        NSLog(@"后续执行");
    };
    self.normalRequestModel.complete = ^(NSDictionary *response) {
        NSLog(@"先执行");
    };
     */
    [[LLAPIClient shareClient] callRequestWithRequestModel:self.greenCloudRequestModel];
    self.greenCloudRequestModel.complete = ^(NSDictionary *response) {
        
    };
    
}

- (LLBaseRequestModel *)normalRequestModel {
    if (!_normalRequestModel) {
        _normalRequestModel = [[LLBaseRequestModel alloc] init];
        _normalRequestModel.requestType = LLAPIRequestTypeGet;
        _normalRequestModel.serverType = LLServerApple;
        _normalRequestModel.requestPath = @"/cn/lookup";
        _normalRequestModel.parameters = @{
            @"id":@"1380561588"
        };
    }
    return _normalRequestModel;
}

- (LLBaseRequestModel *)retryRequestModel {
    if (!_retryRequestModel) {
        _retryRequestModel = [[LLBaseRequestModel alloc] init];
        _retryRequestModel.requestType = LLAPIRequestTypeGet;
        _retryRequestModel.serverType = LLServerApple;
        _retryRequestModel.requestPath = @"/cn/lookup";
        _retryRequestModel.parameters = @{
                                           @"id":@"836500024"
                                           };
        LLRequestRetryHandler *retry = [[LLRequestRetryHandler alloc] init];
        retry.retryInterval = @3;
        retry.retryCondition = ^BOOL{
            return YES;
        };
        retry.maxRetryCount = @5;
        _retryRequestModel.retryHandler = retry;
    }
    return _retryRequestModel;
}

- (LLBaseRequestModel *)dependcyRequestModel {
    if (!_dependcyRequestModel) {
        _dependcyRequestModel = [[LLBaseRequestModel alloc] init];
        _dependcyRequestModel.requestType = LLAPIRequestTypeGet;
        _dependcyRequestModel.serverType = LLServerApple;
        _dependcyRequestModel.requestPath = @"/cn/lookup";
        _dependcyRequestModel.parameters = @{
            @"id":@"1380561588"
        };
        _dependcyRequestModel.dependency = @[self.normalRequestModel];
    }
    return _dependcyRequestModel;
}
- (LLBaseRequestModel *)greenCloudRequestModel {
    if (!_greenCloudRequestModel) {
        _greenCloudRequestModel = [[LLBaseRequestModel alloc] init];
        _greenCloudRequestModel.requestType = LLAPIRequestTypePost;
        _greenCloudRequestModel.serverType = LLServerGreenCloud;
        _greenCloudRequestModel.requestPath = @"/guardian/open/crm/v2/queryAllIdCodeType";
        _greenCloudRequestModel.parameters = @{

        };
    }
    return _greenCloudRequestModel;
}
@end
