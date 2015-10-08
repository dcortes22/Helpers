//
//  CoreDataManager.m
//  Helpers
//
//  Created by David Cortés Sáenz on 6/10/15.
//  Copyright © 2015 David Cortes. All rights reserved.
//

#import "CoreDataManager.h"

@interface CoreDataManager () {
    NSString *dataBaseName;
}

@end

@implementation CoreDataManager

#pragma mark - Constructor

+ (instancetype)sharedInstance {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

#pragma mark - Core Data Stack

/*
 Set the database name
 @param database NSString
 @return void
 */
- (void)setDataBaseName:(NSString *)database {
    dataBaseName = database;
}

/*
 Init the context on the current thread
 @return void
 */
- (void)initContext {
    [self managedObjectContext];
}

/*
 Return the context for the current Thread
 @return NSManagedObjectContext
 */
- (NSManagedObjectContext *)contextForThread {
    return [self managedObjectContext];
}

/*
 Saves the Current Context
 @return void
 */
- (void)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *currentThreadContext = [self managedObjectContext];
    if (currentThreadContext) {
        if ([currentThreadContext hasChanges] && ![currentThreadContext save:&error]) {
            NSLog(@"Failed to save Core Data context. Unresolved error %@, %@", error, [error userInfo]);
            NSLog(@"Failed to save to data store: %@", [error localizedDescription]);
            NSArray* detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
            if(detailedErrors != nil && [detailedErrors count] > 0) {
                for(NSError* detailedError in detailedErrors) {
                    NSLog(@"  DetailedError: %@", [detailedError userInfo]);
                }
            }
            else {
                NSLog(@"%@", [error userInfo]);
            }
            abort();
        }
    }
}

/*
 Create or return the context for the application
 @return NSManagedObjectContext
 */
- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *contextForThread = [[[NSThread currentThread] threadDictionary] objectForKey:@"context"];
    if (contextForThread != nil) {
        return contextForThread;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        if ([NSThread currentThread] == [NSThread mainThread]) {
            if (!contextForThread) {
                contextForThread = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
                [contextForThread setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
                [contextForThread setPersistentStoreCoordinator: coordinator];
                [contextForThread setUndoManager:nil];
                _managedObjectContext = contextForThread;
                [[[NSThread currentThread] threadDictionary] setObject:contextForThread forKey:@"context"];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextDidSave:) name:NSManagedObjectContextDidSaveNotification object:nil];
            }
        } else {
            contextForThread = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            [contextForThread setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
            [contextForThread setPersistentStoreCoordinator: coordinator];
            [contextForThread setUndoManager:nil];
            [[[NSThread currentThread] threadDictionary] setObject:contextForThread forKey:@"context"];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextDidSave:) name:NSManagedObjectContextDidSaveNotification object:nil];
        }
    }
    
    return [[[NSThread currentThread] threadDictionary] objectForKey:@"context"];
}

/*
 Return the current object model
 @return NSManagedObjectModel
 */
- (NSManagedObjectModel *)managedObjectModel {
    
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    return _managedObjectModel;
}

/*
 Return the unique persisten store coordinator used on the application
 @return NSPersistentStoreCoordinator
 */

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSString *storePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite", dataBaseName]];
    
    // set up the backing store
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // If the expected store doesn't exist, copy the default store.
    if (![fileManager fileExistsAtPath:storePath]) {
        NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:dataBaseName ofType:@"sqlite"];
        if (defaultStorePath) {
            [fileManager copyItemAtPath:defaultStorePath toPath:storePath error:NULL];
        }
    }
    
    NSURL *storeUrl = [NSURL fileURLWithPath:storePath];
    
    NSError *error;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error]) {
        //User here your error handling
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

/*
 Returns the path to the application's documents directory.
 @return NSString
 */
- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
}

- (void)contextDidSave:(NSNotification *)notification {
    
    [_managedObjectContext performBlock:^{
        [_managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
    }];
    
}

#pragma mark - Core Data Entities Manager
- (void)saveEntity:(NSString *)entityName withValues:(NSDictionary *)values {
    id entity = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:[self managedObjectContext]];
    
    entity = [self parseObject:entity Values:values];
    
    NSLog(@"%@", entity);
}

-(id)parseObject:(id)object Values:(NSDictionary *)values {
    NSDictionary *attributes = [[object entity] attributesByName];
    for (NSString *attribute in attributes) {
        id value = [values objectForKey:attribute];
        if (value == nil) {
            continue;
        }
        NSAttributeType attributeType = [[attributes objectForKey:attribute] attributeType];
        if ((attributeType == NSStringAttributeType) && ([value isKindOfClass:[NSNumber class]])) {
            value = [value stringValue];
        } else if (((attributeType == NSInteger16AttributeType) || (attributeType == NSInteger32AttributeType) || (attributeType == NSInteger64AttributeType) || (attributeType == NSBooleanAttributeType)) && ([value isKindOfClass:[NSString class]])) {
            value = [NSNumber numberWithInteger:[value integerValue]];
        } else if ((attributeType == NSFloatAttributeType) &&  ([value isKindOfClass:[NSString class]])) {
            value = [NSNumber numberWithDouble:[value doubleValue]];
        } /*else if ((attributeType == NSDateAttributeType) && ([value isKindOfClass:[NSString class]]) && (dateFormatter != nil)) {
            value = [dateFormatter dateFromString:value];
        }*/
        [object setValue:value forKey:attribute];
    }
    
    return object;
}

- (NSArray *)getEntities:(NSString *)entityName {
    NSFetchRequest * req = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:[self managedObjectContext]];
    [req setEntity:entity];
    [req setReturnsDistinctResults:YES];
    [req setResultType:NSManagedObjectResultType];
    
     NSArray *result = [[self managedObjectContext] executeFetchRequest:req error:nil];
    return result;
}



@end
