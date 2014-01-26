//
//  IQDabaseConstants.h
//  Synchronize Manager
//
//  Created by Mohd Iftekhar Qurashi on 27/12/13.
//  Copyright (c) 2013 Iftekhar. All rights reserved.
//

#ifndef Synchronize_Manager_IQDatabaseConstants_h
#define Synchronize_Manager_IQDatabaseConstants_h

#pragma mark - Table Names

#define TABLE_OFFLINE_STORE                     @"IQTableOfflineStore"
#define TABLE_OFFLINE_IMAGE_STORE               @"IQTableOfflineImageStore"
#define TABLE_UNSENT_STORE                      @"IQTableUnsentStore"

#define kURL        @"url"
#define kData       @"data"
#define kImage      @"image"
#define kStatus     @"status"
#define kUrlRequest @"urlRequest"



typedef void (^OfflineCompletionBlock)(id result);
typedef void (^CompletionBlock)(id result, NSError *error);
typedef void (^ImageCompletionBlock)(UIImage *image, NSError *error);

typedef void (^ResponseBlock)(NSURLResponse* response);
typedef void (^ProgressBlock)(CGFloat progress);

enum
{
	IQObjectUpdateStatusNotUpdated	=	0,
	IQObjectUpdateStatusUpdating    =	1,
	IQObjectUpdateStatusUpdated		=	2,
};

#endif
