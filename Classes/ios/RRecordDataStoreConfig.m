//
//  RRDataStoreConfig.m
//  PennyMac
//
//  Created by Local C. Parratto on 3/6/14.
//  Copyright (c) 2014 PennyMac. All rights reserved.
//

#import "RRecordDataStoreConfig.h"

@implementation RRecordDataStoreConfig

-(id)initWithDatabaseFileName:(NSString *)dFileName modelFileName:(NSString *)mFileName andBundle:(NSBundle *)bundle{
    self = [self init];

    if (self) {
        self.databaseFileName = dFileName;
        self.modelFileName = mFileName;
	self.bundle = bundle;
    }

    return self;
}

@end
