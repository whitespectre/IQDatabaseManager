/*
 IQOfflineManager
 
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


#define kIQURL        @"url"
#define kIQData       @"data"
#define kIQImage      @"image"
#define kIQStatus     @"status"
#define kIQUrlRequest @"urlRequest"


#import "IQOfflineManager.h"

#import "IQTableOfflineImageStore.h"
#import "IQTableOfflineStore.h"
#import "IQTableUnsentStore.h"

@implementation IQOfflineManager
{
    //DatabaseManager Extension
    NSOperationQueue *_queue;
}

+(NSString*)modelName
{
    return @"IQOfflineDatabase";
}

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
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:url,kIQURL,[NSNumber numberWithInteger:IQObjectUpdateStatusUpdating],kIQStatus, nil];
    NSManagedObject *object = [self insertRecordInTable:tableName withAttribute:dict updateOnExistKey:kIQURL equals:url];
    
    //Creating a connection and request for data.
    [NSURLConnection sendAsynchronousRequest:request queue:_queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error)
        {
            [self updateRecord:object withAttribute:[NSDictionary dictionaryWithObject:kIQStatus forKey:[NSNumber numberWithInteger:IQObjectUpdateStatusNotUpdated]]];
            
            [IQOfflineManager sendData:nil error:error onCompletion:completion];
            return;
        }
        
        //If data was found && there was no error, and statusCode is 200(OK).
        if (data && error == nil && [(NSHTTPURLResponse*)response statusCode] == 200)
        {
            if ([tableName isEqualToString:NSStringFromClass([IQTableOfflineStore class])])
            {
                //Update
                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:data,kIQData,[NSNumber numberWithInteger:IQObjectUpdateStatusUpdated],kIQStatus, nil];
                [self updateRecord:object withAttribute:dict];
                
                [IQOfflineManager sendData:data error:error onCompletion:completion];
            }
            else if([tableName isEqualToString:NSStringFromClass([IQTableOfflineImageStore class])])
            {
                UIImage *image = [UIImage imageWithData:data];
                
                if (image)
                {
                    //Update
                    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:image,kIQImage,[NSNumber numberWithInteger:IQObjectUpdateStatusUpdated],kIQStatus, nil];
                    [self updateRecord:object withAttribute:dict];
                }
                else
                {
                    //Update
                    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:IQObjectUpdateStatusNotUpdated],kIQStatus, nil];
                    [self updateRecord:object withAttribute:dict];
                }
                
                [IQOfflineManager sendData:image error:nil onCompletion:completion];
            }
        }
        else
        {
            //Update
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:IQObjectUpdateStatusNotUpdated],kIQStatus, nil];
            [self updateRecord:object withAttribute:dict];
            
            [IQOfflineManager sendData:data error:error onCompletion:completion];
        }
    }];
}


#pragma mark - Offilne Store
-(void)dataFromURL:(NSString*)url offlineCompletion:(OfflineCompletionBlock)offlineBlock onlineCompletion:(CompletionBlock)onlineBlock
{
    //Getting first object
    IQTableOfflineStore *object = (IQTableOfflineStore*)[self firstObjectFromTable:NSStringFromClass([IQTableOfflineStore class]) where:kIQURL equals:url];
    
    [IQOfflineManager sendData:[object data] onOfflineCompletion:offlineBlock];
    
    //Creating a url request.
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    [self sendRequest:request forTable:NSStringFromClass([IQTableOfflineStore class]) completion:onlineBlock];
}

-(void)dataFromURL:(NSString*)url Completion:(CompletionBlock)completionBlock
{
    //Getting first object
    IQTableOfflineStore *object = (IQTableOfflineStore*)[self firstObjectFromTable:NSStringFromClass([IQTableOfflineStore class]) where:kIQURL equals:url];
    
    if (object && [object data])
    {
        [IQOfflineManager sendData:[object data] error:nil onCompletion:completionBlock];
    }
    else
    {
        [self dataFromURL:url offlineCompletion:nil onlineCompletion:completionBlock];
    }
}

#pragma mark - Offilne Image
-(void)imageFromURL:(NSString*)url Completion:(ImageCompletionBlock)completionBlock
{
    IQTableOfflineImageStore *object = (IQTableOfflineImageStore*)[self firstObjectFromTable:NSStringFromClass([IQTableOfflineImageStore class]) where:kIQURL equals:url];
    
    if (object && [object image])
    {
        [IQOfflineManager sendData:[object image] error:nil onCompletion:completionBlock];
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
            
            [IQOfflineManager sendData:data error:error onCompletion:completionBlock];
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
        
        [IQOfflineManager sendData:nil error:error onCompletion:completionBlock];
    }
}

-(void)postRequest:(NSURLRequest*)request completion:(CompletionBlock)completionBlock
{
    //Creating a record dictionary
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:request,kIQUrlRequest,[NSNumber numberWithInteger:IQObjectUpdateStatusNotUpdated],kIQStatus, nil];
    
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

//Synchronizing at launching.
-(void)synchronizeAtLaunch
{
    [self resetStatus];
    
    [self synchronize];
}


@end
