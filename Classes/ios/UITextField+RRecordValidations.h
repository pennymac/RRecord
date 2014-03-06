//
//  UITextField+RustlingRecordValidations.h
//  whitePicket
//
//  Created by Christopher Parratto on 8/23/13.
//  Copyright (c) 2013 Penny Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RRecordAttributeValidator;

@interface UITextField (RRecordValidations)

- (void)validateWithValidator:(RRecordAttributeValidator *)validator
                   usingValue:( id(^)())getValue
                    whenValid:( void (^)(NSManagedObject *, id) )validCallback
                               whenInvalid:( void (^)(NSSet*, NSArray*) )invalidCallback;

@end
