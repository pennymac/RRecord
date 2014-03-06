//
//  RRecordSyncerProtocol.h
//  PennyMac
//
//  Created by Christopher Parratto on 11/29/13.
//  Copyright (c) 2013 PennyMac. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RRecordSyncerProtocol <NSObject>
    @property (nonatomic, retain) NSString* remoteId;
    @property (nonatomic, retain) NSNumber* syncedState;
    -(void) save;
@end
