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

#pragma mark - Core data use only

#define CORE_DATA_MODEL                         @"IQDatabase"
#define CORE_DATA_MODEL_EXTENSION_1             @"mom"
#define CORE_DATA_MODEL_EXTENSION_2             @"momd"
#define CORE_DATA_SQLITE_FILE_NAME              @"IQDatabase.sqlite"


#define kURL        @"url"
#define kData       @"data"
#define kImage      @"image"
#define kStatus     @"status"
#define kUrlRequest @"urlRequest"


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
-(void)synchronizeAtLaunch;

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
        
        //Must not write this in init method.
        [sharedDataBase synchronizeAtLaunch];
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

- (NSArray *)allObjectsFromTable:(NSString*)tableName wherePredicate:(NSPredicate*)predicate sortDescriptor:(NSSortDescriptor*)descriptor
{
    //Creating fetch request object for fetching records.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:tableName];
    
#if TARGET_IPHONE_SIMULATOR
    [fetchRequest setReturnsObjectsAsFaults:NO];
#endif
    
    if (predicate)  [fetchRequest setPredicate:predicate];
    if (descriptor) [fetchRequest setSortDescriptors:[NSArray arrayWithObject:descriptor]];

    return [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
}

- (NSArray *)allObjectsFromTable:(NSString*)tableName sortDescriptor:(NSSortDescriptor*)descriptor
{
    return [self allObjectsFromTable:tableName wherePredicate:nil sortDescriptor:descriptor];
}

- (NSArray *)allObjectsFromTable:(NSString*)tableName wherePredicate:(NSPredicate*)predicate
{
    return [self allObjectsFromTable:tableName wherePredicate:predicate sortDescriptor:nil];
}

-(NSArray*)allObjectsFromTable:(NSString*)tableName
{
    return [self allObjectsFromTable:tableName wherePredicate:nil sortDescriptor:nil];
}


/***Key Value predicate***/
- (NSArray *)allObjectsFromTable:(NSString*)tableName where:(NSString*)key equals:(id)value sortDescriptor:(NSSortDescriptor*)descriptor
{
    NSPredicate *predicate;
    if (key && value)   predicate = [NSPredicate predicateWithFormat:@"self.%@ == %@",key,value];

    return [self allObjectsFromTable:tableName wherePredicate:predicate sortDescriptor:descriptor];
}

- (NSArray *)allObjectsFromTable:(NSString*)tableName where:(NSString*)key equals:(id)value
{
    return [self allObjectsFromTable:tableName where:key equals:value sortDescriptor:nil];
}


/*First/Last object*/
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

- (NSManagedObject *)lastObjectFromTable:(NSString*)tableName createIfNotExist:(BOOL)create
{
    NSManagedObject *object = [self lastObjectFromTable:tableName];
    
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

- (NSManagedObject *)lastObjectFromTable:(NSString*)tableName where:(NSString*)key equals:(id)value
{
    return [[self allObjectsFromTable:tableName where:key equals:value] lastObject];
}

- (NSManagedObject *)lastObjectFromTable:(NSString*)tableName wherePredicate:(NSPredicate*)predicate
{
    return [[self allObjectsFromTable:tableName wherePredicate:predicate] lastObject];
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


#pragma mark - IQDatabaseManager (Download)

#import "IQTableOfflineImageStore.h"
#import "IQTableOfflineStore.h"
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
    //Creating a record for requested url. Updating if it exist.
    NSString *url = request.URL.absoluteString;
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:url,kURL,[NSNumber numberWithInteger:IQObjectUpdateStatusUpdating],kStatus, nil];
    NSManagedObject *object = [self insertRecordInTable:tableName withAttribute:dict updateOnExistKey:kURL equals:url];
    
   //Creating a connection and request for data.
    [NSURLConnection sendAsynchronousRequest:request queue:_queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {

        if (error)
        {
            [self updateRecord:object withAttribute:[NSDictionary dictionaryWithObject:kStatus forKey:[NSNumber numberWithInteger:IQObjectUpdateStatusNotUpdated]]];
            
            [IQDatabaseManager sendData:nil error:error onCompletion:completion];
            return;
        }
        
        //If data was found && there was no error, and statusCode is 200(OK).
        if (data && error == nil && [(NSHTTPURLResponse*)response statusCode] == 200)
        {
            if ([tableName isEqualToString:NSStringFromClass([IQTableOfflineStore class])])
            {
                //Update
                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:data,kData,[NSNumber numberWithInteger:IQObjectUpdateStatusUpdated],kStatus, nil];
                [self updateRecord:object withAttribute:dict];

                [IQDatabaseManager sendData:data error:error onCompletion:completion];
            }
            else if([tableName isEqualToString:NSStringFromClass([IQTableOfflineImageStore class])])
            {
                UIImage *image = [UIImage imageWithData:data];
                
                if (image)
                {
                    //Update
                    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:image,kImage,[NSNumber numberWithInteger:IQObjectUpdateStatusUpdated],kStatus, nil];
                    [self updateRecord:object withAttribute:dict];
                }
                else
                {
                    //Update
                    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:IQObjectUpdateStatusNotUpdated],kStatus, nil];
                    [self updateRecord:object withAttribute:dict];
                }

                [IQDatabaseManager sendData:image error:nil onCompletion:completion];
            }
        }
        else
        {
            //Update
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:IQObjectUpdateStatusNotUpdated],kStatus, nil];
            [self updateRecord:object withAttribute:dict];

            [IQDatabaseManager sendData:data error:error onCompletion:completion];
        }
    }];
}


#pragma mark - Offilne Store
-(void)dataFromURL:(NSString*)url offlineCompletion:(OfflineCompletionBlock)offlineBlock onlineCompletion:(CompletionBlock)onlineBlock
{
    //Getting first object
    IQTableOfflineStore *object = (IQTableOfflineStore*)[self firstObjectFromTable:NSStringFromClass([IQTableOfflineStore class]) where:kURL equals:url];
    
    [IQDatabaseManager sendData:[object data] onOfflineCompletion:offlineBlock];

    //Creating a url request.
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];

    [self sendRequest:request forTable:NSStringFromClass([IQTableOfflineStore class]) completion:onlineBlock];
}

-(void)dataFromURL:(NSString*)url Completion:(CompletionBlock)completionBlock
{
    //Getting first object
    IQTableOfflineStore *object = (IQTableOfflineStore*)[self firstObjectFromTable:NSStringFromClass([IQTableOfflineStore class]) where:kURL equals:url];
    
    if (object && [object data])
    {
        [IQDatabaseManager sendData:[object data] error:nil onCompletion:completionBlock];
    }
    else
    {
        [self dataFromURL:url offlineCompletion:nil onlineCompletion:completionBlock];
    }
}

#pragma mark - Offilne Image
-(void)imageFromURL:(NSString*)url Completion:(ImageCompletionBlock)completionBlock
{
    IQTableOfflineImageStore *object = (IQTableOfflineImageStore*)[self firstObjectFromTable:NSStringFromClass([IQTableOfflineImageStore class]) where:kURL equals:url];
    
    if (object && [object image])
    {
        [IQDatabaseManager sendData:[object image] error:nil onCompletion:completionBlock];
    }
    else
    {
        //Creating a url request.
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
        
        [self sendRequest:request forTable:NSStringFromClass([IQTableOfflineImageStore class]) completion:completionBlock];
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
    
    IQTableUnsentStore *object = (IQTableUnsentStore*)[self insertRecordInTable:NSStringFromClass([IQTableUnsentStore class]) withAttribute:dict];
    
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
    NSArray *allObjects = [self allObjectsFromTable:NSStringFromClass([IQTableOfflineStore class])];
    
    for (IQTableOfflineStore *object in allObjects)
    {
        if ([[object status] integerValue] == IQObjectUpdateStatusNotUpdated)
        {
            //Updating each object
            [self dataFromURL:[object url] offlineCompletion:nil onlineCompletion:nil];
        }
    }
}

-(void)synchronizeImageStoreTable
{
    //Getting all objects
    NSArray *allObjects = [self allObjectsFromTable:NSStringFromClass([IQTableOfflineImageStore class])];
    
    for (IQTableOfflineImageStore *object in allObjects)
    {
        if ([[object status] integerValue] == IQObjectUpdateStatusNotUpdated)
        {
            [self imageFromURL:[object url] Completion:nil];
        }
    }
}

-(void)synchronizeUnsentStore
{
    //Getting all objects
    NSArray *allObjects = [self allObjectsFromTable:NSStringFromClass([IQTableUnsentStore class])];
    
    for (IQTableUnsentStore *object in allObjects)
    {
        if ([[object status] integerValue] == IQObjectUpdateStatusNotUpdated)
        {
            [self postObject:object withCompletion:nil];
        }
    }
}

-(void)synchronize
{
    [self synchronizeOfflineStoreTable];
    [self synchronizeImageStoreTable];
    [self synchronizeUnsentStore];
}

//Synchronizing at launching.
-(void)synchronizeAtLaunch
{
    [self resetStatus];
    
    [self synchronize];
}

#pragma mark - Flush management
-(void)flushOfflineImages
{
    [self flushTable:NSStringFromClass([IQTableOfflineImageStore class])];
}

-(void)flushOfflineData
{
    [self flushTable:NSStringFromClass([IQTableOfflineStore class])];
}

-(void)flushUnsentData
{
    [self flushTable:NSStringFromClass([IQTableUnsentStore class])];
}

-(void)flushAll
{
    [self flushOfflineData];
    [self flushOfflineImages];
    [self flushUnsentData];
}

-(void)resetStatus
{
    NSArray *unsentRecords = [self allObjectsFromTable:NSStringFromClass([IQTableUnsentStore class])];
    //Unsent record
    for (IQTableUnsentStore *object in unsentRecords)
        if ([object.status integerValue] == IQObjectUpdateStatusUpdating)
            object.status = [NSNumber numberWithInteger:IQObjectUpdateStatusNotUpdated];
    
    NSArray *imageRecords = [self allObjectsFromTable:NSStringFromClass([IQTableUnsentStore class])];
    //Image store
    for (IQTableOfflineImageStore *object in imageRecords)
        if ([object.status integerValue] == IQObjectUpdateStatusUpdating)
            object.status = [NSNumber numberWithInteger:IQObjectUpdateStatusNotUpdated];
    
    NSArray *dataRecords = [self allObjectsFromTable:NSStringFromClass([IQTableUnsentStore class])];
    //Data store
    for (IQTableOfflineStore *object in dataRecords)
        if ([object.status integerValue] == IQObjectUpdateStatusUpdating)
            object.status = [NSNumber numberWithInteger:IQObjectUpdateStatusNotUpdated];

    [self save];
}

@end
