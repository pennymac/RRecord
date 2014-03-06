//
//  RRecordValidationMsgFormatter.h
//  whitePicket
//
//  Created by Christopher Parratto on 8/26/13.
//  Copyright (c) 2013 Penny Mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface RRecordValidationMsgFormatter : NSObject

+ (NSString *)formattedValidationMessageForError:(NSError *)error
                                       withLabel:(NSString* )label;

@end
