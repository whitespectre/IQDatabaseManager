//
//  IQDatabaseManagerSubclass.h
//  DatabaseManager
//
//  Created by Mohd Iftekhar Qurashi on 05/02/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import "IQDatabaseManager.h"


#define IQ_MODEL_EXTENSION_momd @"momd"
#define IQ_MODEL_EXTENSION_mom @"mom"


// the extensions in this header are to be used only by subclasses of IQDatabaseManager. Code that uses IQDatabaseManager must never call these

//Created by Iftekhar. 17/4/13.
@interface IQDatabaseManager (ForSubclassEyesOnly)

@property(nonatomic, strong) NSManagedObjectContext *mainContext;
@property(nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

//Abstract methods. Must override this method in subclasses and return your databaseModel name.
+(NSURL*)modelURL;
+(NSURL*)storeURL;
+(NSDictionary*)persistentStoreOptions;
-(void)willStartInitialization;

#pragma mark - Fetch Table Names & Attribute names for table
-(NSArray*)tableNames;
-(NSDictionary*)attributesForTable:(NSString*)tableName;

#pragma mark - Fetch Records
/*Predicate and sort discriptor*/
- (NSArray <__kindof NSManagedObject *> *)allObjectsFromTable:(NSString*)tableName
                                                    inContext:(NSManagedObjectContext*)context;

- (NSArray <__kindof NSManagedObject *> *)allObjectsFromTable:(NSString*)tableName
                                               wherePredicate:(NSPredicate*)predicate
                                         includingSubentities:(BOOL)includeSubentities
                                                    inContext:(NSManagedObjectContext*)context;

- (NSArray <__kindof NSManagedObject *> *)allObjectsFromTable:(NSString*)tableName
                                               wherePredicate:(NSPredicate*)predicate
                                                    inContext:(NSManagedObjectContext*)context;

- (NSArray <__kindof NSManagedObject *> *)allObjectsFromTable:(NSString*)tableName
                                               sortDescriptor:(NSSortDescriptor*)descriptor
                                                    inContext:(NSManagedObjectContext*)context;

- (NSArray <__kindof NSManagedObject *> *)allObjectsFromTable:(NSString*)tableName
                                               wherePredicate:(NSPredicate*)predicate
                                               sortDescriptor:(NSSortDescriptor*)descriptor
                                                    inContext:(NSManagedObjectContext*)context;

- (NSArray <NSDictionary<NSString*,id>*> *)distictObjectsForAttribute:(NSString*)attribute
                                                         forTableName:(NSString*)tableName
                                                            predicate:(NSPredicate*)predicate
                                                            inContext:(NSManagedObjectContext*)context;

- (NSArray <NSDictionary<NSString*,id>*> *)distictObjectsForAttribute:(NSString*)attribute
                                                         forTableName:(NSString*)tableName
                                                            predicate:(NSPredicate*)predicate
                                                   includeSubentities:(BOOL)includeSubentities
                                                            inContext:(NSManagedObjectContext*)context;

- (NSArray <NSDictionary<NSString*,id>*> *)allDictionariesFromTable:(NSString*)tableName
                                                     wherePredicate:(NSPredicate*)predicate
                                                     sortDescriptor:(NSSortDescriptor*)descriptor
                                                          inContext:(NSManagedObjectContext*)context;


/*Key Value predicate and sortDescriptor*/
- (NSArray <__kindof NSManagedObject *> *)allObjectsFromTable:(NSString*)tableName
                                                        where:(NSString*)key
                                                       equals:(id)value
                                                    inContext:(NSManagedObjectContext*)context;

- (NSArray <__kindof NSManagedObject *> *)allObjectsFromTable:(NSString*)tableName
                                                        where:(NSString*)key
                                                       equals:(id)value
                                               sortDescriptor:(NSSortDescriptor*)descriptor
                                                    inContext:(NSManagedObjectContext*)context;

- (NSArray <__kindof NSManagedObject *> *)allObjectsFromTable:(NSString*)tableName
                                                        where:(NSString*)key
                                                     contains:(id)value
                                                    inContext:(NSManagedObjectContext*)context;

- (NSArray <__kindof NSManagedObject *> *)allObjectsFromTable:(NSString*)tableName
                                                        where:(NSString*)key
                                                     contains:(id)value
                                               sortDescriptor:(NSSortDescriptor*)descriptor
                                                    inContext:(NSManagedObjectContext*)context;


#pragma mark - First/Last object


/*First object*/
- (__kindof NSManagedObject *)firstObjectFromTable:(NSString*)tableName
                                         inContext:(NSManagedObjectContext*)context;

- (__kindof NSManagedObject *)firstObjectFromTable:(NSString*)tableName
                                             where:(NSString*)key
                                            equals:(id)value
                                         inContext:(NSManagedObjectContext*)context;

- (__kindof NSManagedObject *)firstObjectFromTable:(NSString*)tableName
                                    wherePredicate:(NSPredicate*)predicate
                                         inContext:(NSManagedObjectContext*)context;

- (__kindof NSManagedObject *)firstObjectFromTable:(NSString*)tableName
                                    wherePredicate:(NSPredicate*)predicate
                                includeSubentities:(BOOL)includeSubentities
                                         inContext:(NSManagedObjectContext*)context;


//Insert object
- (__kindof NSManagedObject*)insertRecordInTable:(NSString*)tableName
                                   withAttribute:(NSDictionary<NSString*,id>*)dictionary
                                       inContext:(NSManagedObjectContext*)context;

//Insert object without context
- (__kindof NSManagedObject*)insertRecordWithoutContextInTable:(NSString*)tableName
                                                 withAttribute:(NSDictionary*)dictionary;

//Update object
- (__kindof NSManagedObject*)updateRecord:(__kindof NSManagedObject*)object
                            withAttribute:(NSDictionary<NSString*,id>*)dictionary;

//(Insert || Update) object
- (__kindof NSManagedObject*)insertRecordInTable:(NSString*)tableName
                                   withAttribute:(NSDictionary<NSString*,id>*)dictionary
                                updateOnExistKey:(NSString*)key equals:(id)value
                                       inContext:(NSManagedObjectContext*)context;

//Delete object
- (void)deleteRecord:(__kindof NSManagedObject*)object;

//Delete all the records in table
-(void)flushTable:(NSString*)tableName
        inContext:(NSManagedObjectContext*)context;

-(void)performBlockAndSaveNewPrivateContext:(void(^)(NSManagedObjectContext* privateContext))newPrivateContextHandler
                             saveCompletion:(void(^)(void))completionHandler;

@end
