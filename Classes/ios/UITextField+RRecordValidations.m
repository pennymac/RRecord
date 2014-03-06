//
//  UITextField+UITextField_RRecordValidations.m
//  whitePicket
//
//  Created by Christopher Parratto on 8/23/13.
//  Copyright (c) 2013 Penny Mac. All rights reserved.
//

#import "RRecordAttributeValidator.h"

#import "NSManagedObject+RRecord.h"
#import "NSManagedObject+RRecordValidations.h"
#import "UITextField+RRecordValidations.h"

@implementation UITextField (RRecordValidations)

- (void)validateWithValidator:(RRecordAttributeValidator *)validator
           usingValue:( id(^)())getValue
           whenValid:( void (^)(NSManagedObject *, id) )validCallback
         whenInvalid:( void (^)(NSSet*, NSArray*) )invalidCallback {
    
    id convertedValue = getValue();
    
    if (convertedValue) {
        [validator validateWithValue:convertedValue];
        
        if (validator.isValid) {
            validCallback(validator.managedObject, convertedValue);
        } else {
            invalidCallback([validator formattedErrorMsgs], [validator attributeErrors]);
        }
    }
}

@end
