//
//  IQDatabaseManagerSubclass.h
//  DatabaseManager
//
//  Created by Mohd Iftekhar Qurashi on 05/02/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import "IQDatabaseManager.h"

// the extensions in this header are to be used only by subclasses of IQDatabaseManager
// code that uses IQDatabaseManager must never call these

//Created by Iftekhar. 17/4/13.
@interface IQDatabaseManager (ForSubclassEyesOnly)

//Abstract method. Must override this method in subclasses and return your databaseModel name.
+(NSString*)modelName;

#pragma mark - Fetch Records
/*Predicate and sort discriptor*/
- (NSArray *)allObjectsFromTable:(NSString*)tableName;
- (NSArray *)allObjectsFromTable:(NSString*)tableName wherePredicate:(NSPredicate*)predicate;
- (NSArray *)allObjectsFromTable:(NSString*)tableName sortDescriptor:(NSSortDescriptor*)descriptor;
- (NSArray *)allObjectsFromTable:(NSString*)tableName wherePredicate:(NSPredicate*)predicate sortDescriptor:(NSSortDescriptor*)descriptor;

/*Key Value predicate and sortDescriptor*/
- (NSArray *)allObjectsFromTable:(NSString*)tableName where:(NSString*)key equals:(id)value;
- (NSArray *)allObjectsFromTable:(NSString*)tableName where:(NSString*)key equals:(id)value sortDescriptor:(NSSortDescriptor*)descriptor;

- (NSArray *)allObjectsFromTable:(NSString*)tableName where:(NSString*)key contains:(id)value;
- (NSArray *)allObjectsFromTable:(NSString*)tableName where:(NSString*)key contains:(id)value sortDescriptor:(NSSortDescriptor*)descriptor;


#pragma mark - First/Last object
/*First object*/
- (NSManagedObject *)firstObjectFromTable:(NSString*)tableName;
- (NSManagedObject *)firstObjectFromTable:(NSString*)tableName createIfNotExist:(BOOL)create;
- (NSManagedObject *)firstObjectFromTable:(NSString*)tableName where:(NSString*)key equals:(id)value;
- (NSManagedObject *)firstObjectFromTable:(NSString*)tableName wherePredicate:(NSPredicate*)predicate;

/*Last object*/
- (NSManagedObject *)lastObjectFromTable:(NSString*)tableName;
- (NSManagedObject *)lastObjectFromTable:(NSString*)tableName createIfNotExist:(BOOL)create;
- (NSManagedObject *)lastObjectFromTable:(NSString*)tableName where:(NSString*)key equals:(id)value;
- (NSManagedObject *)lastObjectFromTable:(NSString*)tableName wherePredicate:(NSPredicate*)predicate;



//Insert object
- (NSManagedObject*)insertRecordInTable:(NSString*)tableName withAttribute:(NSDictionary*)dictionary;
//Update object
- (NSManagedObject*)updateRecord:(NSManagedObject*)object withAttribute:(NSDictionary*)dictionary;
//(Insert || Update) object
- (NSManagedObject*)insertRecordInTable:(NSString*)tableName withAttribute:(NSDictionary*)dictionary updateOnExistKey:(NSString*)key equals:(id)value;

//Delete object
- (BOOL)deleteRecord:(NSManagedObject*)object;
//Delete all the records in table
-(BOOL)flushTable:(NSString*)tableName;

@end
