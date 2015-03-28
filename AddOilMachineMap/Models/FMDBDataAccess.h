//
//  FMDBDataAccess.h
//  AddOilMachineMap
//
//  Created by James Kong on 28/3/15.
//  Copyright (c) 2015 James Kong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "FMResultSet.h"
static NSString * const kMessageTable  = @"MessagesTable";
static NSString * const kID  = @"id";
static NSString * const kLatituede  = @"lat";
static NSString * const kLongitude  = @"lng";
static NSString * const kLocation  = @"location";
static NSString * const kMessage  = @"message";
static NSString * const kName  = @"name";
@interface FMDBDataAccess : NSObject{
    FMDatabase *database;
}

+ (id)sharedInstance;

@property (nonatomic, strong) FMDatabase *database;
@property (nonatomic,strong) NSArray* message;
-(BOOL)deleteTable:(NSString*)key;
@end
