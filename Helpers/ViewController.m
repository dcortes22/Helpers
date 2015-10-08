//
//  ViewController.m
//  Helpers
//
//  Created by David Cortés Sáenz on 6/10/15.
//  Copyright © 2015 David Cortes. All rights reserved.
//

#import "ViewController.h"
#import "CoreDataManager.h"
#import "Person.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSMutableDictionary *values = [NSMutableDictionary dictionary];
    [values setValue:@"David" forKey:@"name"];
    [values setValue:@"Cortes" forKey:@"last_name"];
    
    Person *person = [[[CoreDataManager sharedInstance] getEntities:@"Person"] objectAtIndex:0];
    NSLog(@"Name: %@, Last Name: %@", person.name, person.last_name);
    
//    [[CoreDataManager sharedInstance] saveEntity:@"Person" withValues:values];
//    [[CoreDataManager sharedInstance] saveContext];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
