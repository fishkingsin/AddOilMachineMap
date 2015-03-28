//
//  DataCenter.h
//  AddOilMachineMap
//
//  Created by James Kong on 28/3/15.
//  Copyright (c) 2015 James Kong. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol DataCenterDelegate;
@interface DataCenter : NSObject
@property (nonatomic, weak) id<DataCenterDelegate> delegate;
+ (id)sharedInstance;
- (BOOL)isNetworkAvailable;
- (void) apiRequest:(NSString*) apiStr_ :(id) param_;
@end
@protocol DataCenterDelegate <NSObject>

@required
- (void)dataCenter:(DataCenter*)dataCenter apiString:(NSString*) apiStr dataDidReady:(NSDictionary*)result request:(AFHTTPRequestOperation*)request;
- (void)dataCenter:(DataCenter*)dataCenter apiString:(NSString*) apiStr dataDidStatusFail:(NSString*) errorMessage request:(AFHTTPRequestOperation*)request;
- (void)dataCenter:(DataCenter*)dataCenter apiString:(NSString*) apiStr dataDidFail:(NSError*)error request:(AFHTTPRequestOperation*)request;
@end