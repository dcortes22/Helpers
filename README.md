# CoreDataManager Sample Project
Sample project for use the Thread Safe Core Data Class on Objective C

## How to Use
Init the contex for the main thread on the application didFinishLaunchingWithOptions
``` objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[CoreDataManager sharedInstance] setDataBaseName:@"Helpers"];
    [[CoreDataManager sharedInstance] initContext];
    return YES;
}
```
Now the next time you need to create or get an entity you can get the NSManagedObjectContext for the current thread with
``` objective-c
[[CoreDataManager sharedInstance] contextForThread];
```
Or you can use the in class implementations for this, for example to create a entity
``` objective-c
[[CoreDataManager sharedInstance] saveEntity:@"Person" withValues:aDictionary];
[[CoreDataManager sharedInstance] saveContext];
```
If  you pass a disctionary for your entity, the keys must have the same name as the entity fields.

To fetch Entities:
``` objective-c
Person *person = [[[CoreDataManager sharedInstance] getEntities:@"Person"] objectAtIndex:0];
```
