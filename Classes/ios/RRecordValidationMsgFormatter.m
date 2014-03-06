//
//  RRecordValidationMsgFormatter.m
//  whitePicket
//
//  Created by Christopher Parratto on 8/26/13.
//  Copyright (c) 2013 Penny Mac. All rights reserved.
//

#import "RRecordValidationMsgFormatter.h"

@implementation RRecordValidationMsgFormatter

+ (NSString *)formattedValidationMessageForError:(NSError *)error
                                       withLabel:(NSString* )label {
    NSString *message = nil;
    
    switch ([error code]) {
        case NSValidationNumberTooLargeError:
            message = [self formatMaxValueMessageForError:error andLabel:label];
            break;
        case NSValidationNumberTooSmallError:
            message = [self formatMinValueMessageForError:error andLabel:label];
            break;
        default:
            message = [NSString stringWithFormat: @"The %@ is invaild.", label];
            break;
    }
    return message;
}

+ (NSString *)getFormattedValidationCriteriaFromError:(NSError *)error withUserInfoKey:(NSString *)userInfoKey {
    NSManagedObject *managedObject = [[error userInfo] objectForKey:@"NSValidationErrorObject"];
    NSString *attribute = [[error userInfo] objectForKey:@"NSValidationErrorKey"];
    NSEntityDescription* desc = [managedObject entity];
    NSPropertyDescription* propertyDesc = [[desc propertiesByName] objectForKey:attribute];
    return [[propertyDesc userInfo] objectForKey:userInfoKey];
}

+ (NSString *)formatMinValueMessageForError:(NSError*)error andLabel:(NSString *)label {
    NSString *message = [NSString stringWithFormat: @"The %@ is too small.", label];
    NSString *customMessage = [self getFormattedValidationCriteriaFromError:error withUserInfoKey:@"NSValidationNumberTooSmallError"];

    if (customMessage) {
        message = customMessage;
    }
    return message;
}

+ (NSString *)formatMaxValueMessageForError:(NSError*)error andLabel:(NSString *)label {
    NSString *message = [NSString stringWithFormat: @"The %@ is too large.", label];
    NSString *customMessage = [self getFormattedValidationCriteriaFromError:error withUserInfoKey:@"NSValidationNumberTooLargeError"];

    if (customMessage) {
        message = customMessage;
    }
    return message;
}

@end
