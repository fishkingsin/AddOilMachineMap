//
//  FMDBDataAccess.m
//  AddOilMachineMap
//
//  Created by James Kong on 28/3/15.
//  Copyright (c) 2015 James Kong. All rights reserved.
//

#import "FMDBDataAccess.h"

@implementation FMDBDataAccess
@synthesize database;

// Get the shared instance and create it if necessary.
+ (id)sharedInstance
{
    //    DDLogDebug(@"%s", __PRETTY_FUNCTION__);
    static FMDBDataAccess *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


- (FMDBDataAccess *)init {
    self = [super init];
    
    database = [FMDatabase databaseWithPath:[self getDatabasePath]];
    [database open];
    NSString *query = [NSString stringWithFormat:@"create  table if not exists %@ (%@ TEXT primary key, %@ TEXT, %@ TEXT, %@ TEXT, %@ TEXT, %@ TEXT)" ,kMessageTable, kID,
                       kLatituede,
                       kLongitude,
                       kLocation,
                       kMessage,
                       kName];
    DDLogDebug(@"query %@",query);
    if(![database executeUpdate:query])
    {
        DDLogError(@"Create Table for playlists Failed");
    }
    
    [database close];
    return self;
}
-(NSArray*)message
{
    NSMutableArray *messages = [NSMutableArray array];
    if([database open])
    {
        
        FMResultSet *results = [database executeQuery:[NSString stringWithFormat: @"SELECT * FROM %@",kMessageTable]];
        
        while([results next])
        {
            @try
            {
            /*
             static NSString * const kID  = @"id";
             static NSString * const kLatituede  = @"lat";
             static NSString * const kLongitude  = @"lng";
             static NSString * const kLocation  = @"location";
             static NSString * const kMessage  = @"message";
             static NSString * const kName  = @"name";
             */
//            DDLogDebug(@"RESULT %@ %@",kID,[results stringForColumn:kID]);
//            DDLogDebug(@"RESULT %@ %f",kLatituede,[results doubleForColumn:kLatituede]);
//            DDLogDebug(@"RESULT %@ %f",kLongitude, [results doubleForColumn:kLongitude]);
//            DDLogDebug(@"RESULT %@ %@",kLocation, [results stringForColumn:kLocation]);
//            DDLogDebug(@"RESULT %@ %@",kMessage, [results stringForColumn:kMessage]);
//            DDLogDebug(@"RESULT %@ %@",kName, [results stringForColumn:kName]);
                        [messages addObject: @{kID: [results stringForColumn:kID],
                                               kLatituede: [NSNumber numberWithDouble:[results doubleForColumn:kLatituede]],
                                               kLongitude: [NSNumber numberWithDouble:[results doubleForColumn:kLongitude]],
                                               kLocation: [results stringForColumn:kLocation],
                                               kMessage:[results stringForColumn:kMessage],
                                               kName:[results stringForColumn:kName]}];
            }@catch(NSException* exception)
            {
                DDLogError(@"%s %@",__PRETTY_FUNCTION__,exception);
            }
        }
    }
    return messages;
    
}
-(void) setMessage:(NSArray *)message_
{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue setMaxConcurrentOperationCount: 1];
    
    [self deleteTable:kMessageTable];
    for(NSDictionary *dic in message_)
    {
        [queue addOperationWithBlock:^{
            if(![self insertMessage:dic])
            {
//                DDLogDebug(@"%@",dic);
                DDLogError(@"Insert messages failed");
            }
        }];
    }
    [queue waitUntilAllOperationsAreFinished];
}
-(BOOL)insertMessage:(NSDictionary*)dic
{
    @try
    {
        FMDatabase *db = [FMDatabase databaseWithPath:[self getDatabasePath]];
        
        [db open];
        FMResultSet *results = [db executeQuery:[NSString stringWithFormat: @"SELECT * FROM %@ where %@='%@'",kMessageTable,kID,[dic valueForKey:kID]]];
        BOOL success = NO;
        if([results next])
        {
            return success;
        }
        NSString * ID = [dic valueForKey:kID] ;
        NSString * latituede = [dic valueForKey:kLatituede] ;
        NSString * longitude = [dic valueForKey:kLongitude] ;
        NSString * location = [dic valueForKey:kLocation];
        NSString * message = [dic valueForKey:kMessage];
        NSString * name = [dic valueForKey:kName];
        
//        DDLogDebug(@"%@ %f %f %@ %@ %@ ",ID,
//                   latituede,
//                   longitude ,
//                   location,
//                   message,
//                   name);
        success =  [db executeUpdate: [NSString stringWithFormat:@"INSERT INTO %@ (%@,%@,%@,%@,%@,%@) VALUES (?,?,?,?,?,?);" ,
                               kMessageTable,
                               kID,
                               kLatituede,
                               kLongitude,
                               kLocation,
                               kMessage,
                               kName],
                    ID,
                    latituede,
                    longitude ,
                    location,
                    message,
                    name,nil];
        
        [db close];
        
        return success;
        
        
    }
    @catch(NSException *e)
    {
        DDLogError(@"%@",e);
    }
    return NO;
    
}

-(BOOL)deleteTable:(NSString*)key
{
    database = [FMDatabase databaseWithPath:[self getDatabasePath]];
    [database open];
    BOOL success =  [database executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@",key]];
    [database close];
    return success;
}
-(NSString *) getDatabasePath
{
    NSString *databaseName = @"cache.db";
    
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES); //1
    NSString *documentDir = [documentPaths objectAtIndex:0];
    NSString *databasePath = [documentDir stringByAppendingPathComponent:databaseName];
    
    
    return databasePath;
}

@end
