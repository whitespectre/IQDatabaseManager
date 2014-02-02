//
//  MyDatabaseManager.h
//  DatabaseManager
//
//  Created by Canopus 4 on 31/01/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import "IQDatabaseManager.h"
#import "MyDatabaseConstants.h"

@interface MyDatabaseManager : IQDatabaseManager

- (NSArray *)allRecordsSortByAttribute:(NSString*)attribute;
- (NSArray *)allRecordsSortByAttribute:(NSString*)attribute where:(NSString*)key contains:(id)value;

- (RecordTable*) insertRecordInRecordTable:(NSDictionary*)recordAttributes;
- (RecordTable*) insertUpdateRecordInRecordTable:(NSDictionary*)recordAttributes;
- (RecordTable*) updateRecord:(RecordTable*)record inRecordTable:(NSDictionary*)recordAttributes;
- (BOOL) deleteTableRecord:(RecordTable*)record;


- (BOOL) deleteAllTableRecord;

- (Settings*) settings;
- (Settings*) saveSettings:(NSDictionary*)settings;

@end
