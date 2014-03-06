//
//  RRDataStoreConfig.h
//  PennyMac
//
//  Created by Local C. Parratto on 3/6/14.
//  Copyright (c) 2014 PennyMac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RRecordDataStoreConfig : NSObject
    -(id)initWithDatabaseFileName:(NSString *)dFileName modelFileName:(NSString *)mFileName andBundle:(NSBundle *)bundle;

    @property NSBundle *bundle;
    @property NSString *databaseFileName;
    @property NSString *modelFileName;;
@end
