//
//  JLDB.m
//  JLDatabaseLink
//
//  Created by Joshua on 5/9/13.
//  Copyright (c) 2013 Joshua. All rights reserved.
//


/*
 The MIT License (MIT)
 
 Copyright (c) 2013 Joshua Lareta
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 
 */

#import "JLDB.h"


@implementation JLDB
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize delegate = _delegate;
@synthesize dbNumber = _dbNumber;


+ (JLDB *)instance{
    static JLDB *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[JLDB alloc] init];
              [_instance registerMergingContext];

      
    });
    
    
    return _instance;
}

+(void)resetDBNumber{
    [JLDB instance].dbNumber = 0;
}

-(id)init{

    self = [super init];
    if(self){
     
       
    }
    return self;
}

#pragma mark - Notification For Merging
-(void)registerMergingContext{
   
//    NSLog(@">>> %@",[JLDB instance].dbNumber);
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(saveContextMerge:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:nil];

}

-(void)setDbNumber:(NSInteger)dbNumber{
    BOOL isNotEqual = YES;
     if(dbNumber != [JLDB dbNumber])
         isNotEqual = NO;
    NSUserDefaults *preference = [NSUserDefaults standardUserDefaults];
    [preference setInteger:dbNumber forKey:@"dbNumber"];
    [preference synchronize];
    
    if(!isNotEqual)
        self.persistentStoreCoordinator = nil;
    NSPersistentStoreCoordinator *persistentLoad = self.persistentStoreCoordinator; // must load persistent store first
    persistentLoad = persistentLoad;// remove warning

}
-(NSInteger)dbNumber{
    NSUserDefaults *f = [NSUserDefaults standardUserDefaults];
    NSInteger number = [f integerForKey:@"dbNumber"];
    return number;
}
+(NSInteger)dbNumber{
    JLDB *test = [JLDB new];
  return   [test dbNumber];
}

+(NSString *)databaseName{
 
    NSString *path = [[NSBundle mainBundle] pathForResource:JLPlistName ofType:@"plist"];
   
      __block NSString *dbName = nil;
    
    
    NSMutableArray *databases = [[NSMutableArray arrayWithContentsOfFile:path]mutableCopy];
    [databases enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        if([JLDB dbNumber] == idx){
            NSMutableDictionary *dbDetails = [NSMutableDictionary dictionaryWithDictionary:obj];
            
            
            [dbDetails enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if([[key lowercaseString] isEqualToString:@"dbname"]){
                    dbName = (NSString *)obj;
                }
            }];
        }
    }];
    
//    NSMutableDictionary *dbDetails = [[NSMutableDictionary dictionaryWithContentsOfFile:path] mutableCopy];
//    
//   
//    [dbDetails enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
//        if([[key lowercaseString] isEqualToString:@"dbname"]){
//            dbName = (NSString *)obj;
//        }
//    }];
    
    return dbName;
    
}


-(void)saveContextMerge:(NSNotification *)notifcation{
    if(![NSThread isMainThread])
        [self performSelectorOnMainThread:@selector(saveContextMerge:) withObject:notifcation waitUntilDone:YES];
    NSLog(@">>> merging");
    [[JLDB instance].managedObjectContext mergeChangesFromContextDidSaveNotification:notifcation];
    
    [_delegate JLDBMergeSuccess];
}
+ (void)saveContext:(NSManagedObjectContext *)context
{
    if(![NSThread isMainThread])
        [self performSelectorOnMainThread:@selector(saveContext:) withObject:context waitUntilDone:YES];
    
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = context;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


+(void)deleteObject:(id)object fromContext:(NSManagedObjectContext *)context{
    [context deleteObject:object];
    
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    _managedObjectContext = [self newManageContext];
    return _managedObjectContext;
}



#pragma mark - Generate New ManageContext
-(NSManagedObjectContext *)newManageContext{
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
        [context setPersistentStoreCoordinator:coordinator];
        return context;
    }
    
    return nil;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSString *dbName = [JLDB databaseName];// fetch db name from plist
    BOOL isEmpty = NO;
    if([dbName respondsToSelector:@selector(length)]){
        if([dbName length]<=0){
            isEmpty = YES;
        }
    }
    if(dbName == nil)
        isEmpty = YES;
    
    if(isEmpty)
        return nil;
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:dbName withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSString *dbName = [JLDB databaseName];// fetch db name from plist
    BOOL isEmpty = NO;
    if([dbName respondsToSelector:@selector(length)]){
        if([dbName length]<=0){
            isEmpty = YES;
        }
    }
    if(dbName == nil)
        isEmpty = YES;
    
    if(isEmpty)
        return nil;
    
    dbName = [NSString stringWithFormat:@"%@.sqlite",dbName];
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:dbName];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}



#pragma mark - Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

-(void)destruct{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
