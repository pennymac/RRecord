//
//  RRecordAttributeValidator.h
//  whitePicket
//
//  Created by Christopher Parratto on 8/23/13.
//  Copyright (c) 2013 Penny Mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface RRecordAttributeValidator : NSObject {
    NSSet *_formattedErrorMessages;
}

@property (readonly) NSManagedObject *managedObject;
@property (readonly) NSString* attributeKey;
@property (readonly) NSString* attributeAlias;
@property (readonly) BOOL isValid;
@property (readonly) NSArray* attributeErrors;

-(id)initWithManagedObject:(NSManagedObject*)obj
              attributeKey:(NSString *)attributeKey
                  andAlias:(NSString *)alias;

-(BOOL)validateWithValue:(id)value;

-(NSSet *)formattedErrorMsgs;

@end