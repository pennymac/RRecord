//
//  RRecordValidationErrorParser.m
//  whitePicket
//
//  Created by Christopher Parratto on 8/26/13.
//  Copyright (c) 2013 Penny Mac. All rights reserved.
//

#import "RRecordValidationErrorParser.h"

@implementation RRecordValidationErrorParser

+ (NSDictionary*)parseValidationError:(NSError *)error
                     forManagedObject:(id)managedObject {
    
    if ([self isCocoaDomainError:error]) {
        
        NSArray *errors = [self arrayFromValidationError:error];
        
        NSDictionary *attributeErrorLookups = [self attributeValidationErrorDictionaryFromArray:errors
                                                                               forManagedObject:managedObject];
        
        if (attributeErrorLookups) {
            return attributeErrorLookups;
        }
    }
    
    return nil;
}

+ (BOOL)isCocoaDomainError:(NSError*)error {
    return error && [[error domain] isEqualToString:@"NSCocoaErrorDomain"];
}

+ (NSArray *)arrayFromValidationError:(NSError *)error {
    NSArray *errors = nil;
    
    if ([error code] == NSValidationMultipleErrorsError) {
        errors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
    } else {
        errors = [NSArray arrayWithObject:error];
    }
    
    return errors;
}

+ (NSDictionary *)attributeValidationErrorDictionaryFromArray:(NSArray *)errors
                                             forManagedObject:(NSManagedObject *)managedObject{
    NSMutableDictionary *attributeErrorLookups = nil;
    
    for (NSError *error in errors) {
        NSString *entityName = [[[[error userInfo] objectForKey:@"NSValidationErrorObject"] entity] name];
        
        if([entityName isEqualToString:NSStringFromClass([managedObject class])]){
            if (!attributeErrorLookups) {
                attributeErrorLookups = [[NSMutableDictionary alloc] init];
            }
            [self addError:error toDictionary:attributeErrorLookups];
        }
    }
    
    return attributeErrorLookups;
}

+ (void)addError:(NSError *)error toDictionary:(NSMutableDictionary *)dictionaryAddress {
    NSMutableDictionary *dictionary = dictionaryAddress;
    
    NSString *attributeName = [[error userInfo] objectForKey:@"NSValidationErrorKey"];
    if(![dictionary objectForKey:attributeName]) {
        [dictionary setObject:[[NSMutableArray alloc] init] forKey:attributeName];
    }
    
    NSMutableArray *attributeErrors = [dictionary objectForKey:attributeName];
    [attributeErrors addObject:error];
}

@end
