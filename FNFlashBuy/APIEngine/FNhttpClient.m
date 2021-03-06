//
//  TDHttpManager.m
//  UnionpayCard
//
//  Created by towne on 14-2-20.
//  Copyright (c) 2014年 Frodo. All rights reserved.
//

#import "FNhttpClient.h"
#import "FNjsonParser.h"
#import "FNhttpCommand.h"

//http://localhost:8000/yscardII/json/Show/{"method":"showBtype"}
//static NSString *const BASEURL = @"http://192.168.1.101:8000/yscardII/json/";//@"http://localhost:8000/yscardII/json/";

//static NSString *const BASEURL = @"http://113.57.133.83:1982/"; // 外网地址

@implementation FNhttpClient

+ (FNhttpClient *)sharedClient {
    static FNhttpClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *baseURL = [NSURL URLWithString:BASEURL];
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        [config setHTTPAdditionalHeaders:@{ @"User-Agent" : @"TDHttpClient iOS 1.0"}];
        //设置我们的缓存大小 其中内存缓存大小设置10M  磁盘缓存5M
        NSURLCache *cache = [[NSURLCache alloc] initWithMemoryCapacity:10 * 1024 * 1024
                                                          diskCapacity:50 * 1024 * 1024
                                                              diskPath:nil];
        [config setURLCache:cache];
        _sharedClient = [[FNhttpClient alloc] initWithBaseURL:baseURL
                                         sessionConfiguration:config];
        _sharedClient.responseSerializer = [AFJSONResponseSerializer serializer];
    });
    return _sharedClient;
}

-(void)_handleResult:(id)responseObject
                task:(NSURLSessionDataTask *)task
               error:(NSError *)anError
            callback:(FNblock)aCallback
{
//    [self _logRawResponse:task];
    if (aCallback) {
        dispatch_async(dispatch_get_main_queue(), ^{
            aCallback(task, [FNjsonParser parseData:responseObject], anError);
        });
    }
}

- (void)processCommand:(FNhttpCommand * ) command callback:(FNblock)aCallback
{
    NSURLSessionDataTask * task = nil;
    if(!command)
        return;
    
    if ([command.method isEqualToString:@"GET"]) {
        task =  [self GET:command.path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
            
            if (httpResponse.statusCode == 200) {
                [self _handleResult:responseObject task:task error:nil callback:aCallback];
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [self _handleResult:nil task:task error:error callback:aCallback];
        }];
        //Compatible ios6
        if(task == nil)
        {
            NSString * encodingString = [NSString stringWithFormat:@"%@%@",self.baseURL.absoluteString,command.path];
            NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:command.method URLString:encodingString parameters:nil error:nil];
            AFHTTPRequestOperation *task_ios6operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            [task_ios6operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
                if (httpResponse.statusCode == 200) {
                    NSString *requestTmp = [NSString stringWithString:operation.responseString];
                    NSData *resData = [[NSData alloc] initWithData:[requestTmp dataUsingEncoding:NSUTF8StringEncoding]];
                    NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingMutableLeaves error:nil];
                    [self _handleResult:resultDic task:task error:nil callback:aCallback];
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [self _handleResult:nil task:task error:error callback:aCallback];
            }];
            [task_ios6operation start];
        }
    }
    else
    {
        task = [self POST:command.path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
            if (httpResponse.statusCode == 200) {
                [self _handleResult:responseObject task:task error:nil callback:aCallback];
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [self _handleResult:nil task:task error:error callback:aCallback];
        }];
        //Compatible ios6
        if(task == nil)
        {
            NSString * encodingString = [NSString stringWithFormat:@"%@%@",self.baseURL.absoluteString,command.path];
            NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:command.method URLString:encodingString parameters:nil error:nil];
            AFHTTPRequestOperation *task_ios6operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            [task_ios6operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
                if (httpResponse.statusCode == 200) {
                    NSString *requestTmp = [NSString stringWithString:operation.responseString];
                    NSData *resData = [[NSData alloc] initWithData:[requestTmp dataUsingEncoding:NSUTF8StringEncoding]];
                    NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingMutableLeaves error:nil];
                    [self _handleResult:resultDic task:task error:nil callback:aCallback];
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [self _handleResult:nil task:task error:error callback:aCallback];
            }];
            [task_ios6operation start];
        }
    }
    
    [task resume];
}

-(void)_logRawResponse:(NSURLSessionDataTask *) task {
    
}

@end
