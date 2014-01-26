//
//  DatabaseManager.m
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#pragma mark - Core data use only

#define CORE_DATA_MODEL                         @"IQDatabase"
#define CORE_DATA_MODEL_EXTENSION_1             @"mom"
#define CORE_DATA_MODEL_EXTENSION_2             @"momd"
#define CORE_DATA_SQLITE_FILE_NAME              @"IQDatabase.sqlite"


//iOS 5 compatibility method
@implementation NSArray (iOS5_firstObject)

-(id)firstObject
{
    return ([self count] > 0)?[self objectAtIndex:0]:nil;
}

@end



#import "IQDatabaseManager.h"

/*************************************/

//Category Methods are used as private methods. Because these are used only inside the class. Not able to access from outside.
//Class method are used because these methods are not dependent upon class iVars.

//Created by Iftekhar. 18/4/13.
@interface IQDatabaseManager()

//Core Data Use Only.
@property (readonly, strong, atomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, atomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, atomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

//To Suppress warning
@interface IQDatabaseManager (Reset)

//Implemented in (Download) extension.
-(void)resetPostStatus;

@end

//Actual Implementation.
@implementation IQDatabaseManager

@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

#pragma mark - Initialize and Save.

- (id)init
{
    self = [super init];
    if (self)
    {
        _queue = [[NSOperationQueue alloc] init];
        [_queue setMaxConcurrentOperationCount:1];
    }
    return self;
}

+(IQDatabaseManager*)sharedManager
{
    static IQDatabaseManager *sharedDataBase;

    if (sharedDataBase == nil)
    {
        sharedDataBase = [[self alloc] init];
        [sharedDataBase resetPostStatus];
    }
    
    return sharedDataBase;
}

//Save context.
-(BOOL)save;
{
    return [self.managedObjectContext save:nil];
}

-(NSArray*)tableNames
{
    NSDictionary *entities = [self.managedObjectModel entitiesByName];
    return [entities allKeys];
}

-(NSDictionary*)attributesForTable:(NSString*)tableName
{
    NSEntityDescription *description = [[self.managedObjectModel entitiesByName] objectForKey:tableName];

    NSDictionary *properties = [description propertiesByName];
    NSArray *allKeys = [properties allKeys];
    
    NSMutableDictionary *attributeDictionary = [[NSMutableDictionary alloc] init];
    for (NSString *key in allKeys)
    {
        if ([[properties objectForKey:key] attributeType] == NSTransformableAttributeType)
        {
            [attributeDictionary setObject:@"id" forKey:key];
        }
        else
        {
            NSString *attributeClassName = [[properties objectForKey:key] attributeValueClassName];
            
            if (attributeClassName)
            {
                [attributeDictionary setObject:attributeClassName forKey:key];
            }
        }
    }
    
    return attributeDictionary;
}




#pragma mark - Fetch Records
-(NSArray*)allObjectsFromTable:(NSString*)tableName
{
    return [self allObjectsFromTable:tableName where:nil equals:nil];
}

- (NSArray *)allObjectsFromTable:(NSString*)tableName where:(NSString*)key equals:(id)value
{
    NSPredicate *predicate;
    if (key && value)   predicate = [NSPredicate predicateWithFormat:@"self.%@ == %@",key,value];

    return [self allObjectsFromTable:tableName wherePredicate:predicate];
}

- (NSArray *)allObjectsFromTable:(NSString*)tableName wherePredicate:(NSPredicate*)predicate
{
    //Creating fetch request object for fetching records.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:tableName];
    
#if TARGET_IPHONE_SIMULATOR
    [fetchRequest setReturnsObjectsAsFaults:NO];
#endif
    
    if (predicate)  [fetchRequest setPredicate:predicate];
    
    return [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
}


- (NSManagedObject *)firstObjectFromTable:(NSString*)tableName
{
    return [[self allObjectsFromTable:tableName] firstObject];
}

- (NSManagedObject *)lastObjectFromTable:(NSString*)tableName
{
    return [[self allObjectsFromTable:tableName] lastObject];
}


- (NSManagedObject *)firstObjectFromTable:(NSString*)tableName createIfNotExist:(BOOL)create
{
    NSManagedObject *object = [self firstObjectFromTable:tableName];
    
    if (object == nil && create == YES)    object = [self insertRecordInTable:tableName withAttribute:nil];
    
    return object;
}


- (NSManagedObject *)firstObjectFromTable:(NSString*)tableName where:(NSString*)key equals:(id)value
{
    return [[self allObjectsFromTable:tableName where:key equals:value] firstObject];
}

- (NSManagedObject *)firstObjectFromTable:(NSString*)tableName wherePredicate:(NSPredicate*)predicate
{
    return [[self allObjectsFromTable:tableName wherePredicate:predicate] firstObject];
}


#pragma mark - Insert & Update Records
//Insert objects
- (NSManagedObject*)insertRecordInTable:(NSString*)tableName withAttribute:(NSDictionary*)dictionary
{
    //creating NSManagedObject for inserting records
    NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:tableName inManagedObjectContext:self.managedObjectContext];
    
    return [self updateRecord:object withAttribute:dictionary];
}

//Update object
- (NSManagedObject*)updateRecord:(NSManagedObject*)object withAttribute:(NSDictionary*)dictionary
{
    NSArray *allKeys = [dictionary allKeys];
    
    for (NSString *aKey in allKeys)
    {
        id value = [dictionary objectForKey:aKey];
        [object setValue:value forKey:aKey];
    }

    [self save];
    return object;
}

- (NSManagedObject*)insertRecordInTable:(NSString*)tableName withAttribute:(NSDictionary*)dictionary updateOnExistKey:(NSString*)key equals:(id)value
{
    NSManagedObject *object = [self firstObjectFromTable:tableName where:key equals:value];
    
    if (object)
    {
        return [self updateRecord:object withAttribute:dictionary];
    }
    else
    {
        return [self insertRecordInTable:tableName withAttribute:dictionary];
    }
}


#pragma mark - Delete Records
//Delete all records in table.
-(BOOL)flushTable:(NSString*)tableName
{
    NSArray *records = [self allObjectsFromTable:tableName];
    
    for (NSManagedObject *object in records)
    {
        [self.managedObjectContext deleteObject:object];
    }
    
    return [self save];
}

//Delete object
-(BOOL)deleteRecord:(NSManagedObject*)object
{
    [self.managedObjectContext deleteObject:object];
    return [self save];
}

#pragma mark - Core Data Stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:CORE_DATA_MODEL withExtension:CORE_DATA_MODEL_EXTENSION_1];
    
    if (modelURL == nil)
    {
        modelURL = [[NSBundle mainBundle] URLForResource:CORE_DATA_MODEL withExtension:CORE_DATA_MODEL_EXTENSION_2];
    }
    
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSURL *applicationDocumentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];

    NSURL *storeURL = [applicationDocumentsDirectory URLByAppendingPathComponent:CORE_DATA_SQLITE_FILE_NAME];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        NSLog(@"PersistentStore Error: %@, %@", error, [error userInfo]);
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
        abort();
    }    
    
    return __persistentStoreCoordinator;
}

@end


#import "IQTableUnsentStore.h"

@implementation IQDatabaseManager (Download)

+(void)sendData:(id)data error:(NSError*)error onCompletion:(CompletionBlock)completion
{
    if (completion)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(data,error);
        });
    }
}

+(void)sendData:(id)data onOfflineCompletion:(OfflineCompletionBlock)completion
{
    if (completion)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(data);
        });
    }
}

-(void)sendRequest:(NSURLRequest*)request forTable:(NSString*)tableName completion:(CompletionBlock)completion
{
   //Creating a connection and request for data.
    [NSURLConnection sendAsynchronousRequest:request queue:_queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error)
        {
            [IQDatabaseManager sendData:nil error:error onCompletion:completion];
            return;
        }

        NSString *url = request.URL.absoluteString;
        
        //If data was found && there was no error, and statusCode is 200(OK).
        if (data && error == nil && [(NSHTTPURLResponse*)response statusCode] == 200)
        {
            if ([tableName isEqualToString:TABLE_OFFLINE_STORE])
            {
                //Creating a record dictionary
                NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:url,kURL,data,kData, nil];
                
                //Update or Insert
                [self insertRecordInTable:tableName withAttribute:dict updateOnExistKey:kURL equals:url];

                [IQDatabaseManager sendData:data error:error onCompletion:completion];
            }
            else if([tableName isEqualToString:TABLE_OFFLINE_IMAGE_STORE])
            {
                UIImage *image = [UIImage imageWithData:data];
                
                //Creating a record dictionary
                NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:url,kURL,image,kImage, nil];
                
                [self insertRecordInTable:tableName withAttribute:dict updateOnExistKey:kURL equals:url];

                [IQDatabaseManager sendData:image error:nil onCompletion:completion];
            }
        }
        else
        {
            [IQDatabaseManager sendData:data error:error onCompletion:completion];
        }
    }];

}

#pragma mark - Offilne Store
-(void)dataFromURL:(NSString*)url offlineCompletion:(OfflineCompletionBlock)offlineBlock onlineCompletion:(CompletionBlock)onlineBlock
{
    //Getting first object
    __block NSManagedObject *object = [self firstObjectFromTable:TABLE_OFFLINE_STORE where:kURL equals:url];
    
    [IQDatabaseManager sendData:[object valueForKey:kData] onOfflineCompletion:offlineBlock];

    //Creating a url request.
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];

    [self sendRequest:request forTable:TABLE_OFFLINE_STORE completion:onlineBlock];
}

-(void)dataFromURL:(NSString*)url Completion:(CompletionBlock)completionBlock
{
    //Getting first object
    __block NSManagedObject *object = [self firstObjectFromTable:TABLE_OFFLINE_STORE where:kURL equals:url];
    
    if (object)
    {
        [IQDatabaseManager sendData:[object valueForKey:kData] error:nil onCompletion:completionBlock];
    }
    else
    {
        [self dataFromURL:url offlineCompletion:nil onlineCompletion:completionBlock];
    }
}

#pragma mark - Offilne Image
-(void)imageFromURL:(NSString*)url Completion:(ImageCompletionBlock)completionBlock
{
    __block NSManagedObject *object = [self firstObjectFromTable:TABLE_OFFLINE_IMAGE_STORE where:kURL equals:url];
    
    if (object)
    {
        [IQDatabaseManager sendData:[object valueForKey:kImage] error:nil onCompletion:completionBlock];
    }
    else
    {
        //Creating a url request.
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
        
        [self sendRequest:request forTable:TABLE_OFFLINE_IMAGE_STORE completion:completionBlock];
    }
}

#pragma mark - Unsent Store

//Private method.
-(void)postObject:(IQTableUnsentStore*)object withCompletion:(CompletionBlock)completionBlock
{
    if ([object isKindOfClass:[IQTableUnsentStore class]] && [[object status] integerValue] == IQObjectUpdateStatusNotUpdated)
    {
        [object setStatus:[NSNumber numberWithInteger:IQObjectUpdateStatusUpdating]];
        [self save];
        
        //Creating a connection and request for data.
        [NSURLConnection sendAsynchronousRequest:[object urlRequest] queue:_queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            
            //there was no error, and statusCode is 200(OK).
            if (error == nil && [(NSHTTPURLResponse*)response statusCode] == 200)
            {
                [object setStatus:[NSNumber numberWithInteger:IQObjectUpdateStatusUpdated]];
                [self save];
                [self deleteRecord:object];
            }
            else
            {
                [object setStatus:[NSNumber numberWithInteger:IQObjectUpdateStatusNotUpdated]];
                [self save];
            }

            [IQDatabaseManager sendData:data error:error onCompletion:completionBlock];
        }];
    }
    else
    {
        NSError *error;
        if ([object isKindOfClass:[IQTableUnsentStore class]] && [[object status] integerValue] == IQObjectUpdateStatusUpdated)
        {
            [object setStatus:[NSNumber numberWithInteger:IQObjectUpdateStatusUpdated]];
            [self deleteRecord:object];
            error = [NSError errorWithDomain:@"database" code:101 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Already updated",NSLocalizedDescriptionKey, nil]];
        }
        else
        {
            error = [NSError errorWithDomain:@"database" code:102 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Updation in progress",NSLocalizedDescriptionKey, nil]];
        }
        
        [IQDatabaseManager sendData:nil error:error onCompletion:completionBlock];
    }
}

-(void)postRequest:(NSURLRequest*)request completion:(CompletionBlock)completionBlock
{
    //Creating a record dictionary
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:request,kUrlRequest,[NSNumber numberWithInteger:IQObjectUpdateStatusNotUpdated],kStatus, nil];
    
    IQTableUnsentStore *object = (IQTableUnsentStore*)[self insertRecordInTable:TABLE_UNSENT_STORE withAttribute:dict];
    
    [self postObject:object withCompletion:completionBlock];
}

-(void)postData:(NSData*)data toURL:(NSString*)url completion:(CompletionBlock)completionBlock
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [request setHTTPBody:data];
    [request setHTTPMethod:@"POST"];

    [self postRequest:request completion:completionBlock];
}

#pragma mark - Synchronization Management

//Synchronizing offline store table
-(void)synchronizeOfflineStoreTable
{
    //Getting all objects
    NSArray *allObjects = [self allObjectsFromTable:TABLE_OFFLINE_STORE];
    
    for (NSManagedObject *object in allObjects)
    {
        //Updating each object
        [self dataFromURL:[object valueForKey:kURL] offlineCompletion:nil onlineCompletion:nil];
    }
}

-(void)synchronizeImageStoreTable
{
    //Blank
}

-(void)synchronizeUnsentStore
{
    //Getting all objects
    NSArray *allObjects = [self allObjectsFromTable:TABLE_UNSENT_STORE];
    
    for (IQTableUnsentStore *object in allObjects)
    {
        [self postObject:object withCompletion:nil];
    }
}

//Synchronizing
-(void)synchronize
{
    [self synchronizeOfflineStoreTable];
    [self synchronizeImageStoreTable];
    [self synchronizeUnsentStore];
}

#pragma mark - Flush management
-(void)flushOfflineImages
{
    [self flushTable:TABLE_OFFLINE_IMAGE_STORE];
}

-(void)flushOfflineData
{
    [self flushTable:TABLE_OFFLINE_STORE];
}

-(void)flushUnsentData
{
    [self flushTable:TABLE_UNSENT_STORE];
}

-(void)flushAll
{
    [self flushOfflineData];
    [self flushOfflineImages];
    [self flushUnsentData];
}

-(void)resetPostStatus
{
    //Getting all objects
    NSArray *allObjects = [self allObjectsFromTable:TABLE_UNSENT_STORE];
    
    for (IQTableUnsentStore *object in allObjects)
    {
        [object setStatus:[NSNumber numberWithInteger:IQObjectUpdateStatusNotUpdated]];
    }
    [self save];
}

@end
