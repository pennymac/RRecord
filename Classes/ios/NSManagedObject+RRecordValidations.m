//
//  NSManagedObject+RRecordValidations.m
//  whitePicket
//
//  Created by Christopher Parratto on 8/21/13.
//  Copyright (c) 2013 Penny Mac. All rights reserved.
//

#import "NSManagedObject+RRecord.h"
#import "NSManagedObject+RRecordValidations.h"
#import "RRecordValidationErrorParser.h"

@implementation NSManagedObject (RRecordValidations)

- (NSDictionary *)saveValidateAndReturnErrors {
    NSError *saveError = nil;
    
    if ([self.managedObjectContext hasChanges]) {
        [self.managedObjectContext save:&saveError];
    }
        
    return [RRecordValidationErrorParser parseValidationError:saveError forManagedObject:self];
}

@end
