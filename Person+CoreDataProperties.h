//
//  Person+CoreDataProperties.h
//  Helpers
//
//  Created by David Cortés Sáenz on 7/10/15.
//  Copyright © 2015 David Cortes. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Person.h"

NS_ASSUME_NONNULL_BEGIN

@interface Person (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *last_name;

@end

NS_ASSUME_NONNULL_END
