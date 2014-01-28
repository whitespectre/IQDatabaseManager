/*
 The MIT License (MIT)
 
 Copyright (c) 2014 Mohd Iftekhar Qurashi
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of
 this software and associated documentation files (the "Software"), to deal in
 the Software without restriction, including without limitation the rights to
 use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 the Software, and to permit persons to whom the Software is furnished to do so,
 subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

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

#pragma mark - Fetch Records
/*Predicate and sort discriptor*/
- (NSArray *)allObjectsFromTable:(NSString*)tableName;
- (NSArray *)allObjectsFromTable:(NSString*)tableName wherePredicate:(NSPredicate*)predicate;
- (NSArray *)allObjectsFromTable:(NSString*)tableName sortDescriptor:(NSSortDescriptor*)descriptor;
- (NSArray *)allObjectsFromTable:(NSString*)tableName wherePredicate:(NSPredicate*)predicate sortDescriptor:(NSSortDescriptor*)descriptor;

/*Key Value predicate and sortDescriptor*/
- (NSArray *)allObjectsFromTable:(NSString*)tableName where:(NSString*)key equals:(id)value;
- (NSArray *)allObjectsFromTable:(NSString*)tableName where:(NSString*)key equals:(id)value sortDescriptor:(NSSortDescriptor*)descriptor;


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
