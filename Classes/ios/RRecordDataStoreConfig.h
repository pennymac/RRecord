//
//  RRDataStoreConfig.h
//  PennyMac
//
//  Created by Local C. Parratto on 3/6/14.
//  Copyright (c) 2014 PennyMac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RRecordDataStoreConfig : NSObject
    -(id)initWithDatabaseFileName:(NSString *)dFileName andModelFileName:(NSString *)mFileName;

    @property NSString *databaseFileName;
    @property NSString *modelFileName;;
@end
