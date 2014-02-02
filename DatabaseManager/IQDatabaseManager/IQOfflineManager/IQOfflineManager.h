//
//  IQDownloadManager.h
//  DatabaseManager
//
//  Created by Mohd Iftekhar Qurashi on 02/02/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import "IQDatabaseManager.h"
#import "IQOfflineConstants.h"

@interface IQOfflineManager : IQDatabaseManager

-(void)synchronizeAtLaunch;
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
