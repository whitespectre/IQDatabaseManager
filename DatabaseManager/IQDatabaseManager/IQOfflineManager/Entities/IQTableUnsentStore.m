//
//  IQTableUnsentStore.m
//  DatabaseManager

#import "IQTableUnsentStore.h"
#import "IQOfflineManager.h"

@interface IQOfflineManager ()

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
        [[IQOfflineManager sharedManager] postObject:self withCompletion:nil];
    }
}

@end
