//
//  IQTableOfflineImageStore.h
//  DatabaseManager

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface IQTableOfflineImageStore : NSManagedObject

@property (nonatomic, retain) UIImage * image;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSNumber * status;

@end
