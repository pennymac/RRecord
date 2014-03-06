//
//  RRecordSyncer.h
//  PennyMac
//
//  Created by Christopher Parratto on 11/27/13.
//  Copyright (c) 2013 PennyMac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "RRecordSyncerProtocol.h"

typedef enum RRecordSyncerState : NSUInteger {
    kRRecordSyncerNONE = 0,
    kRRecordSyncerSYNCED = 1,
    kRRecordSyncerFAILURE = 2,
    kRRecordSyncerCREATE = 3,
    kRRecordSyncerPENDING = 4,
    kRRecordSyncerUPDATE = 5,
    kRRecordSyncerDESTROY = 6
} RRecordSyncerState;

@interface RRecordSyncer : NSObject

-(id)initWithResourceURI:(NSString *)resourceURI
                andObject:(NSObject<RRecordSyncerProtocol> *)object;

-(void)resume;
-(void)create;
-(void)update;
-(void)destroy;

-(BOOL)canUpdate;

@property (readonly) NSString *resourceURI;
@property NSDictionary *attributeMapping;
@property NSString *recordName;
@property NSString *remoteId;

@end
