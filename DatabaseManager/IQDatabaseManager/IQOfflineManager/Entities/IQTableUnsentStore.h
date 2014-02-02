//
//  IQTableUnsentStore.h
//  DatabaseManager

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface IQTableUnsentStore : NSManagedObject

@property (nonatomic, retain) NSURLRequest* urlRequest;
@property (nonatomic, retain) NSNumber* status;

@end
