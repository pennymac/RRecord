//
//  NSManagedObject+RRecord.m
//  whitePicket
//
//  Created by Christopher Parratto on 8/6/13.
//  Copyright (c) 2013 Penny Mac. All rights reserved.
//

#import "NSManagedObject+RRecord.h"
#import "RRecordDataStore.h"

@implementation NSManagedObject (RRecord)

+ (NSString *)entityName {
    return NSStringFromClass(self);
}

+ (id)create {
    RRecordDataStore *dataStore = [RRecordDataStore instance];
    return [self createInContext:dataStore.managedObjectContext];
}

- (BOOL)save {
    RRecordDataStore *dataStore = [RRecordDataStore instance];
    NSError *error = nil;
    
    BOOL didSave = [dataStore saveContext:&error];
    return didSave;
}

- (void)delete {
    [self.managedObjectContext deleteObject:self];
    [self save];
}

+ (id)first {
    RRecordDataStore *dataStore = [RRecordDataStore instance];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:[self entityName] inManagedObjectContext:dataStore.managedObjectContext]];
    [request setPredicate:nil];
    [request setFetchLimit:1];
    
    NSError *error;
    NSArray *results = [dataStore.managedObjectContext executeFetchRequest:request error:&error];
    
    if ([results count]){
        return [results objectAtIndex:0];
    }
    
    return nil;
}

+ (NSUInteger)count {
    RRecordDataStore *dataStore = [RRecordDataStore instance];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:[self entityName] inManagedObjectContext:dataStore.managedObjectContext]];
    
    [request setIncludesSubentities:NO];    
    NSError *err;
    NSUInteger count = [dataStore.managedObjectContext countForFetchRequest:request error:&err];
    if(count == NSNotFound) {
        return 0;
    }
    return count;
}

+ (NSFetchRequest *)createFetchRequestInContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:[self entityName]
                                              inManagedObjectContext:context];
    [request setEntity:entity];
    return request;
}

+ (NSArray *)fetchWithPredicate:(NSPredicate *)predicate
                      inContext:(NSManagedObjectContext *)context {
    
    NSFetchRequest *request = [self createFetchRequestInContext:context];
    [request setPredicate:predicate];
    
    NSArray *fetchedObjects = [context executeFetchRequest:request error:nil];
    return fetchedObjects.count > 0 ? fetchedObjects : nil;
}

+ (NSString *)queryStringFromDictionary:(NSDictionary *)conditions {
    NSMutableString *queryString = [NSMutableString new];
    
    for (id attribute in conditions.allKeys) {
        id value = [conditions objectForKey:attribute];
        
        if ([value isKindOfClass:[NSString class]])
            [queryString appendFormat:@"%@ == '%@'", attribute, value];
        else
            [queryString appendFormat:@"%@ == %@", attribute, value];
        
        if (attribute == [conditions.allKeys lastObject])
            break;
        [queryString appendString:@" AND "];
    }
    
    return queryString;
}

+ (NSPredicate *)predicateFromStringOrDict:(id)condition {
    
    if ([condition isKindOfClass:[NSString class]])
        return [NSPredicate predicateWithFormat:condition];
    
    else if ([condition isKindOfClass:[NSDictionary class]])
        return [NSPredicate predicateWithFormat:[self queryStringFromDictionary:condition]];
    
    return nil;
}

+ (id)createInContext:(NSManagedObjectContext *)context {
    return [NSEntityDescription insertNewObjectForEntityForName:[self entityName]
                                         inManagedObjectContext:context];
}

+ (NSArray *)allInContext:(NSManagedObjectContext *)context {
    return [self fetchWithPredicate:nil inContext:context];
}

+ (NSArray *)all {
    RRecordDataStore *dataStore = [RRecordDataStore instance];
    return [self allInContext:dataStore.managedObjectContext];
}

+ (NSArray *)where:(id)condition {
    RRecordDataStore *dataStore = [RRecordDataStore instance];
    NSPredicate *predicate = ([condition isKindOfClass:[NSPredicate class]]) ? condition
    : [self predicateFromStringOrDict:condition];
    
    return [self fetchWithPredicate:predicate inContext:dataStore.managedObjectContext];
}

+ (void)deleteAll {
    [self deleteAllInContext:[[RRecordDataStore instance] managedObjectContext]];
}

+ (void)deleteAllInContext:(NSManagedObjectContext *)context {
    for (NSManagedObject *obj in [self all]) {        
        [obj delete];
    }
}

@end
