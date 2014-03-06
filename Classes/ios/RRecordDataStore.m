//
//  RRecordDataStore.m
//  whitePicket
//
//  Created by Christopher Parratto on 8/2/13.
//  Copyright (c) 2013 Penny Mac. All rights reserved.
//

#import "RRecordDataStore.h"
#import "RRecordDataStoreConfig.h"

#ifdef DEBUG
    #define INIT_P_STORE [self initPersistentTestStoreCoordinator];
#else
    #define INIT_P_STORE [self initPersistentStoreCoordinator];
#endif

@implementation RRecordDataStore

+ (RRecordDataStore *)instance {
    static RRecordDataStore *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [RRecordDataStore alloc];
    });
    return _instance;
}

+ (RRecordDataStore *)instanceWithConfig:(RRecordDataStoreConfig *)config {
    RRecordDataStore *instance = [RRecordDataStore instance];
   instance.config = config;
   return [instance init];
}


- (id)init {
    [self initManagedObjectModel];
    INIT_P_STORE;
    [self initManagedObjectContext];
    return [super init];
}

- (id)initForTests {
    [self initManagedObjectModel];
    [self initPersistentTestStoreCoordinator];
    [self initManagedObjectContext];
    return [super init];
}

- (void)initManagedObjectContext {    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
}

- (void)initPersistentStoreCoordinator {
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:_config.databaseFileName];

    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSDictionary *migrateOptions = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithBool:YES],
                                    NSMigratePersistentStoresAutomaticallyOption,
                                    [NSNumber numberWithBool:YES],
                                    NSInferMappingModelAutomaticallyOption, nil];
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil
                                                             URL:storeURL
                                                         options:migrateOptions
                                                           error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

- (void)initPersistentTestStoreCoordinator {
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType
                                                   configuration:nil URL:nil options:nil error:nil]){
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

- (void)initManagedObjectModel {
    NSURL *modelURL = [_config.bundle URLForResource:_config.modelFileName
                                              withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
}

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask] lastObject];
}

- (BOOL)saveContext:(NSError**)error {
    if ([_managedObjectContext hasChanges] && ![_managedObjectContext save:error]) {
        return NO;
    }
    
    return YES;
}

@end
