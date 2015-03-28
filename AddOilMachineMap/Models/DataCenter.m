//
//  DataCenter.m
//  AddOilMachineMap
//
//  Created by James Kong on 28/3/15.
//  Copyright (c) 2015 James Kong. All rights reserved.
//

#import "DataCenter.h"

@implementation DataCenter
// Get the shared instance and create it if necessary.
+ (id)sharedInstance
{
    DDLogDebug(@"%s", __PRETTY_FUNCTION__);
    static DataCenter *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
    DDLogDebug(@"%s", __PRETTY_FUNCTION__);
    self = [super init];
    if (self) {
        
        
        
    }
    return self;
}

- (void) apiRequest:(NSString*) apiStr_ :(id) param_
{
    if([self isNetworkAvailable]){
        [self apiRequestProd:apiStr_ :param_];
        
    }else{
        [self dataCenterApiString:apiStr_ dataDidStatusFail:@"Network not available" request:nil];
    }
    
}

- (void) apiRequestProd:(NSString*) apiStr_ :(id) param_
{
    DDLogDebug(@"====RC4============================ %@ ==============================", apiStr_);
    DDLogDebug(@"%s parameters:%@",__PRETTY_FUNCTION__, param_);
    DDLogDebug(@"================================ end ==============================");
    
    DDLogDebug(@"%s", __PRETTY_FUNCTION__);
    NSString *url = [NSString stringWithFormat:@"%@%@%@",kAPIScheme,kBaseURL, apiStr_];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    id paramData = nil;
    if(nil != param_){
        
        paramData = param_;
    }else{
        paramData = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"", @"data", nil];
    }
    [manager POST:url parameters:paramData success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //            [operation waitUntilFinished];
        NSDictionary* result = responseObject;

        DDLogDebug(@"=======================S==============================");
        DDLogDebug(@"%@", url);
        DDLogDebug(@"======================================================");

        [self dataDidReadyApiString:apiStr_ result:result request:operation];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DDLogDebug(@"operation: %@", operation);
        DDLogDebug(@"HTTPRequestHeaders %@",operation.request.allHTTPHeaderFields );
        
        
        [self dataCenterApiString:apiStr_ dataDidFail:error request:operation];
        
    }];
    
}
#pragma mark Check Reachbilities
- (BOOL)isNetworkAvailable
{
//    return [AFNetworkReachabilityManager sharedManager].reachable;
    CFNetDiagnosticRef dReference;
    dReference = CFNetDiagnosticCreateWithURL (NULL, (__bridge CFURLRef)[NSURL URLWithString:@"www.google.com"]);
    
    CFNetDiagnosticStatus status;
    status = CFNetDiagnosticCopyNetworkStatusPassively (dReference, NULL);
    
    CFRelease (dReference);
    
    if ( status == kCFNetDiagnosticConnectionUp )
    {
        DDLogDebug (@"Connection is Available");
        return YES;
    }
    else
    {
        DDLogDebug (@"Connection is down");
        return NO;
    }
}

//#pragma mark App setting
#pragma mark Self Delegate Function

- (void) dataDidReadyApiString:(NSString*) apiStr result:(NSDictionary*)result request:(AFHTTPRequestOperation*)request
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if([self.delegate respondsToSelector:@selector(dataCenter:apiString:dataDidReady:request:)])
        {
            [self.delegate dataCenter:self apiString:apiStr dataDidReady:result request:request];
        }
    });
    
}
- (void) dataCenterApiString:(NSString*) apiStr dataDidStatusFail:(NSString*) errorMessage request:(AFHTTPRequestOperation*)request
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if([self.delegate respondsToSelector:@selector(dataCenter:apiString:dataDidStatusFail:request:)])
        {
            [self.delegate dataCenter:self apiString:apiStr dataDidStatusFail:errorMessage request:request];
        }
    });
}

- (void) dataCenterApiString:(NSString*) apiStr dataDidFail:(NSError*)error request:(AFHTTPRequestOperation*)request
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if([self.delegate respondsToSelector:@selector(dataCenter:apiString:dataDidFail:request:)])
        {
            
            [self.delegate dataCenter:self apiString:apiStr dataDidFail:error request:request];
        }
    });
    
}

@end
