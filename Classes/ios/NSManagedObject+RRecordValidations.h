//
//  NSManagedObject+RRecordValidations.h
//  whitePicket
//
//  Created by Christopher Parratto on 8/21/13.
//  Copyright (c) 2013 Penny Mac. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject(RRecordValidations)

- (NSDictionary*)saveValidateAndReturnErrors;

@end
