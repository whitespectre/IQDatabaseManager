/*
 IQDatabaseManager

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

//Actual Implementation.
@implementation IQDatabaseManager

@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

#pragma mark - Initialize and Save.


+(NSString*)modelName
{
    NSString *selector = NSStringFromSelector(_cmd);
    [NSException raise:NSInternalInconsistencyException format:@"%@ is abstract method You must override %@ method in %@ class and must not call [super %@].",selector,selector,NSStringFromClass([self class]),selector];
    return nil;
}

- (id)init
{
    self = [super init];
    if (self)
    {
    }
    return self;
}

+(IQ_INSTANCETYPE)sharedManager
{
    static IQDatabaseManager *sharedDataBase;

    if (sharedDataBase == nil)
    {
        sharedDataBase = [[self alloc] init];
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


- (NSArray *)allObjectsFromTable:(NSString*)tableName where:(NSString*)key contains:(id)value sortDescriptor:(NSSortDescriptor*)descriptor
{
    NSPredicate *predicate;
    if (key && value) 
    {
        NSString *predicateString = [NSString stringWithFormat:@"self.%@ contains[c] \"%@\"",key,value];
        predicate = [NSPredicate predicateWithFormat:predicateString];
    }
    
    return [self allObjectsFromTable:tableName wherePredicate:predicate sortDescriptor:descriptor];
}

- (NSArray *)allObjectsFromTable:(NSString*)tableName where:(NSString*)key contains:(id)value
{
    return [self allObjectsFromTable:tableName where:key contains:value sortDescriptor:nil];
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
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:[[self class] modelName] withExtension:@"momd"];
    
    if (modelURL == nil)
    {
        modelURL = [[NSBundle mainBundle] URLForResource:[[self class] modelName] withExtension:@"mom"];
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

    NSURL *storeURL = [applicationDocumentsDirectory URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite",[[self class] modelName]]];
    
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
