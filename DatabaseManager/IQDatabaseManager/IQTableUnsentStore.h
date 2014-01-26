//
//  UnsentStoreTable.h
//  Synchronize Manager
//
//  Created by Canopus 4 on 18/01/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface IQTableUnsentStore : NSManagedObject

@property (nonatomic, retain) NSURLRequest* urlRequest;
@property (nonatomic, retain) NSNumber* status;

@end
