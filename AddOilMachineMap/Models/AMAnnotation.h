//
//  AMAnnotation.h
//  AddOilMachineMap
//
//  Created by James Kong on 28/3/15.
//  Copyright (c) 2015 James Kong. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface AMAnnotation : NSObject<MKAnnotation>
- (id)initWithID:(NSString*)ID name:(NSString *)name message:(NSString*)message location:(NSString*)location coordination:(CLLocationCoordinate2D)coordinate;
@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSString *location;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) AMAnnotation *clusterAnnotation;
@property (nonatomic, strong) NSArray *containedAnnotations;
@end
