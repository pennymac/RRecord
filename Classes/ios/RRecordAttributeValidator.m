//
//  RRecordAttributeValidator.m
//  whitePicket
//
//  Created by Christopher Parratto on 8/23/13.
//  Copyright (c) 2013 Penny Mac. All rights reserved.
//

#import "RRecordAttributeValidator.h"
#import "RRecordValidationMsgFormatter.h"
#import "RRecordValidationErrorParser.h"
#import "NSManagedObject+RRecord.h"
#import "NSManagedObject+RRecordValidations.h"

@implementation RRecordAttributeValidator

-(id)initWithManagedObject:(NSManagedObject*)obj attributeKey:(NSString *)attributeKey
                                                     andAlias:(NSString *)alias{
    _managedObject = obj;
    _attributeKey = attributeKey;
    _attributeAlias = alias;
    _isValid = NO;
    
    return self;
}

-(BOOL)validateWithValue:(id)value {
    NSError* valErr = nil;
    
    _isValid = [_managedObject validateValue:&value forKey:_attributeKey error:&valErr];
    
    if([RRecordValidationErrorParser isCocoaDomainError:valErr]) {
        _attributeErrors = [RRecordValidationErrorParser arrayFromValidationError:valErr];
    }
    
    return _isValid;
}

-(NSSet *)formattedErrorMsgs {
    if (!self.isValid) {
        NSMutableSet *newMsgs = [[NSMutableSet alloc] init];
        for (NSError *error in self.attributeErrors) {
            [newMsgs addObject:
             [RRecordValidationMsgFormatter
              formattedValidationMessageForError:error
              withLabel:_attributeAlias]];
        }
        
        _formattedErrorMessages = newMsgs;
    }
    
    return _formattedErrorMessages;
}

@end
