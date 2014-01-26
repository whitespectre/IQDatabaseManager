//
//  DatabaseManager.h
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "IQDatabaseConstants.h"

/*
Faulting and Uniquing

Faulting is a mechanism Core Data employs to reduce your application’s memory usage. A related feature called uniquing ensures that, in a given managed object context, you never have more than one managed object to represent a given record.

 https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/CoreData/Articles/cdFaultingUniquing.html
*/

//Created by Iftekhar. 17/4/13.
@interface IQDatabaseManager : NSObject
{
    //DatabaseManager Extension
    NSOperationQueue *_queue;
}

//Shared Object.
+ (IQDatabaseManager *)sharedManager;

-(NSArray*)tableNames;
-(NSDictionary*)attributesForTable:(NSString*)tableName;

//Fetch Objects
- (NSArray *)allObjectsFromTable:(NSString*)tableName;
- (NSArray *)allObjectsFromTable:(NSString*)tableName where:(NSString*)key equals:(id)value;
- (NSArray *)allObjectsFromTable:(NSString*)tableName wherePredicate:(NSPredicate*)predicate;
//Fetch first object
- (NSManagedObject *)firstObjectFromTable:(NSString*)tableName;
- (NSManagedObject *)lastObjectFromTable: (NSString*)tableName;
- (NSManagedObject *)firstObjectFromTable:(NSString*)tableName createIfNotExist:(BOOL)create;
- (NSManagedObject *)firstObjectFromTable:(NSString*)tableName where:(NSString*)key equals:(id)value;
- (NSManagedObject *)firstObjectFromTable:(NSString*)tableName wherePredicate:(NSPredicate*)predicate;

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


//Save context
- (BOOL)save;

/*Overrided methods*/
- (id)init  __attribute__((unavailable("init is not available")));
+ (id)new   __attribute__((unavailable("new is not available")));

@end


@class IQTableUnsentStore;
//File Download Extension
@interface IQDatabaseManager (Download)

-(void)synchronize;

//Getting data from server.
-(void)dataFromURL:(NSString*)url offlineCompletion:(OfflineCompletionBlock)offlineBlock onlineCompletion:(CompletionBlock)onlineBlock;
-(void)dataFromURL:(NSString*)url Completion:(CompletionBlock)completionBlock;

//Getting image.
-(void)imageFromURL:(NSString*)url Completion:(ImageCompletionBlock)completionBlock;

//Posting data to server
-(void)postData:(NSData*)data toURL:(NSString*)url completion:(CompletionBlock)completionBlock;
-(void)postRequest:(NSURLRequest*)request completion:(CompletionBlock)completionBlock;

//Flushing data
-(void)flushOfflineImages;
-(void)flushOfflineData;
-(void)flushUnsentData;
-(void)flushAll;

@end
