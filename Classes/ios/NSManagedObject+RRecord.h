//
//  NSManagedObject+RRecord.h
//  whitePicket
//
//  Created by Christopher Parratto on 8/6/13.
//  Copyright (c) 2013 Penny Mac. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (RRecord)

#pragma mark - Naming

+ (NSString *)entityName;

#pragma mark - CRUD type methods for default

+ (id)create;

+ (NSArray *)all;
+ (void)deleteAll;
+ (NSUInteger)count;
+ (id)first;

+ (NSArray *)where:(id)condition;

- (BOOL)save;
- (void)delete;

#pragma mark - CRUD type methods for explicit context

+ (NSFetchRequest *)createFetchRequestInContext:(NSManagedObjectContext *)context;
+ (id)createInContext:(NSManagedObjectContext *)context;
+ (NSArray *)fetchWithPredicate:(NSPredicate *)predicate
                      inContext:(NSManagedObjectContext *)context;

+ (NSArray *)allInContext:(NSManagedObjectContext *)context;
+ (void)deleteAllInContext:(NSManagedObjectContext *)context;

@end
