//
//  MyDatabaseManager.m
//  DatabaseManager

#import "MyDatabaseManager.h"
#import "IQDatabaseManagerSubclass.h"

@implementation MyDatabaseManager

+(NSURL*)modelURL
{
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"MyDatabase" withExtension:IQ_MODEL_EXTENSION_momd];
    
    if (modelURL == nil)    modelURL = [[NSBundle mainBundle] URLForResource:@"MyDatabase" withExtension:IQ_MODEL_EXTENSION_mom];

    return modelURL;
}

#pragma mark - RecordTable
- (NSArray *)allRecordsSortByAttribute:(NSString*)attribute
{
    NSSortDescriptor *sortDescriptor = nil;
    
    if ([attribute length]) sortDescriptor = [[NSSortDescriptor alloc] initWithKey:attribute ascending:YES];

    return [self allObjectsFromTable:NSStringFromClass([RecordTable class]) sortDescriptor:sortDescriptor inContext:self.mainContext];
}

- (NSArray *)allRecordsSortByAttribute:(NSString*)attribute where:(NSString*)key contains:(id)value
{
    NSSortDescriptor *sortDescriptor = nil;
    
    if ([attribute length]) sortDescriptor = [[NSSortDescriptor alloc] initWithKey:attribute ascending:YES];

    return [self allObjectsFromTable:NSStringFromClass([RecordTable class]) where:key contains:value sortDescriptor:sortDescriptor inContext:self.mainContext];
}

-(RecordTable*) insertRecordInRecordTable:(NSDictionary*)recordAttribute
{
    return (RecordTable*)[self insertRecordInTable:NSStringFromClass([RecordTable class]) withAttribute:recordAttribute inContext:self.mainContext];
}

- (RecordTable*) insertUpdateRecordInRecordTable:(NSDictionary*)recordAttribute
{
    return (RecordTable*)[self insertRecordInTable:NSStringFromClass([RecordTable class]) withAttribute:recordAttribute updateOnExistKey:kEmail equals:[recordAttribute objectForKey:kEmail] inContext:self.mainContext];
}

- (RecordTable*) updateRecord:(RecordTable*)record inRecordTable:(NSDictionary*)recordAttribute
{
    return (RecordTable*)[self updateRecord:record withAttribute:recordAttribute];
}

- (void) deleteTableRecord:(RecordTable*)record
{
    [self deleteRecord:record];
}

-(void) deleteAllTableRecord
{
    [self flushTable:NSStringFromClass([RecordTable class]) inContext:self.mainContext];
}

#pragma mark - Settings
- (Settings*) settings
{
    Settings *settings = [self firstObjectFromTable:NSStringFromClass([Settings class]) inContext:self.mainContext];
    
    //No settings
    if (settings == nil)
    {
        //Inserting default settings
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],kPassword, nil];
        
        settings = (Settings*)[self insertRecordInTable:NSStringFromClass([Settings class]) withAttribute:dict inContext:self.mainContext];
    }

    return settings;
}

- (Settings*) saveSettings:(NSDictionary*)settings
{
    Settings *mySettings = [self firstObjectFromTable:NSStringFromClass([Settings class]) inContext:self.mainContext];
    
    if (mySettings)
    {
        [self updateRecord:mySettings withAttribute:settings];
    }
    else
    {
        mySettings = [self insertRecordInTable:NSStringFromClass([Settings class]) withAttribute:settings inContext:self.mainContext];
    }

    return mySettings;
}

@end
