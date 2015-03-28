//
//  AMAnnotation.m
//  AddOilMachineMap
//
//  Created by James Kong on 28/3/15.
//  Copyright (c) 2015 James Kong. All rights reserved.
//

#import "AMAnnotation.h"

@implementation AMAnnotation
- (id)initWithID:(NSString *)ID name:(NSString *)name message:(NSString *)message location:(NSString *)location coordination:(CLLocationCoordinate2D)coordinate
{
    self = [super init];
    if (self != nil) {
        self.ID= ID;
        self.username = name;
        self.message = message;
        self.location = location;
        self.coordinate = coordinate;
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (NSString *)stringForPlacemark:(CLPlacemark *)placemark {
    
    NSMutableString *string = [[NSMutableString alloc] init];
    if (placemark.locality) {
        [string appendString:placemark.locality];
    }
    
    if (placemark.administrativeArea) {
        if (string.length > 0)
            [string appendString:@", "];
        [string appendString:placemark.administrativeArea];
    }
    
    if (string.length == 0 && placemark.name)
        [string appendString:placemark.name];
    
    return string;
}

- (void)updateSubtitleIfNeeded {
    
    if (self.subtitle == nil) {
        // for the subtitle, we reverse geocode the lat/long for a proper location string name
        CLLocation *location = [[CLLocation alloc] initWithLatitude:self.coordinate.latitude longitude:self.coordinate.longitude];
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            if (placemarks.count > 0) {
                CLPlacemark *placemark = placemarks[0];
                self.subtitle = [NSString stringWithFormat:@"Near %@", [self stringForPlacemark:placemark]];
            }
        }];
    }
}
@end
