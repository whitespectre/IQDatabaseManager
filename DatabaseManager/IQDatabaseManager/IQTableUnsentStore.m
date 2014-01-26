//
//  UnsentStoreTable.m
//  Synchronize Manager
//
//  Created by Canopus 4 on 18/01/14.
//  Copyright (c) 2014 Iftekhar. All rights reserved.
//

#import "IQTableUnsentStore.h"
#import "IQDatabaseManager.h"

@interface IQDatabaseManager ()

//Private method of IQDatabaseManager (Download) extension.
-(void)postObject:(IQTableUnsentStore*)object withCompletion:(CompletionBlock)completionBlock;

@end



@implementation IQTableUnsentStore

@dynamic urlRequest;
@dynamic status;

- (void)didSave
{
    [super didSave];
    
    if ([[self status] integerValue] == IQObjectUpdateStatusNotUpdated)
    {
        [[IQDatabaseManager sharedManager] postObject:self withCompletion:nil];
    }
}

@end
