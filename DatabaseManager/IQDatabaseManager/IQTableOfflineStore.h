//
//  IQTableOfflineStore.h
//  DatabaseManager
//
//  Created by Canopus 4 on 30/01/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface IQTableOfflineStore : NSManagedObject

@property (nonatomic, retain) NSData * data;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSNumber * status;

@end
