//
//  CoreDataManager.h
//  Helpers
//
//  Created by David Cortés Sáenz on 6/10/15.
//  Copyright © 2015 David Cortes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataManager : NSObject

@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (instancetype)sharedInstance;

- (instancetype)init __attribute__((unavailable("Use [CoreDataManager sharedInstance] instead")));
- (instancetype)new __attribute__((unavailable("Use [CoreDataManager sharedInstance] instead")));

- (void)setDataBaseName:(NSString *)database;
- (void)initContext;
- (NSManagedObjectContext *)contextForThread;
- (void)saveContext;

- (void)saveEntity:(NSString *)entityName withValues:(NSDictionary *)values;
- (NSArray *)getEntities:(NSString *)entityName;

@end
