//
//  IQTableOfflineStore.h
//  DatabaseManager

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface IQTableOfflineStore : NSManagedObject

@property (nonatomic, retain) NSData * data;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSNumber * status;

@end
