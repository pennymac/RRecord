//
//  RRecordValidationErrorParser.h
//  whitePicket
//
//  Created by Christopher Parratto on 8/26/13.
//  Copyright (c) 2013 Penny Mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface RRecordValidationErrorParser : NSObject

+ (NSDictionary*)parseValidationError:(NSError *)error
                     forManagedObject:(id)managedObject;

+ (BOOL)isCocoaDomainError:(NSError*)error;

+ (NSArray *)arrayFromValidationError:(NSError *)error;

+ (NSDictionary *)attributeValidationErrorDictionaryFromArray:(NSArray *)attributeErrors
                                            forManagedObject:(NSManagedObject*)managedObject;

@end
