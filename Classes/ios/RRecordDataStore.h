//
//  RRecordDataStore.h
//  whitePicket
//
//  Created by Christopher Parratto on 8/2/13.
//  Copyright (c) 2013 Penny Mac. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>

@class RRecordDataStoreConfig;

@interface RRecordDataStore : NSObject

+ (RRecordDataStore *)instance;

@property RRecordDataStoreConfig *config;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;

-(BOOL)saveContext:(NSError**)error;

@end
