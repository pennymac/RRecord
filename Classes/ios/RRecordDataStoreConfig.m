//
//  RRDataStoreConfig.m
//  PennyMac
//
//  Created by Local C. Parratto on 3/6/14.
//  Copyright (c) 2014 PennyMac. All rights reserved.
//

#import "RRecordDataStoreConfig.h"

@implementation RRecordDataStoreConfig

-(id)initWithDatabaseFileName:(NSString *)dFileName andModelFileName:(NSString *)mFileName{
    self = [self init];

    if (self) {
        self.databaseFileName = dFileName;
        self.modelFileName = mFileName;
    }

    return self;
}

@end
