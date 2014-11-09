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
+ (id)createInContext:(NSManagedObjectContext *)context;

+ (NSArray *)all;
+ (NSArray *)allInContext:(NSManagedObjectContext *)context;

+ (void)deleteAll;
+ (void)deleteAllInContext:(NSManagedObjectContext *)context;

+ (NSUInteger)count;
+ (NSUInteger)countInContext:(NSManagedObjectContext *)context;

+ (id)first;
+ (id)firstFromContext:(NSManagedObjectContext *)context;

+ (NSArray *)where:(id)condition;
+ (id)whereInContext:(NSManagedObjectContext *)context
       byCondition:(id)condition;

- (BOOL)save;
- (void)delete;

+ (NSFetchRequest *)createFetchRequestInContext:(NSManagedObjectContext *)context;

+ (NSArray *)fetchWithPredicate:(NSPredicate *)predicate
                      inContext:(NSManagedObjectContext *)context;




@end
