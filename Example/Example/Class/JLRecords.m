//
//  JLRecords.m
//  JLRecords
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

#import "JLRecords.h"


@interface JLRecords(){

    JLDB *db;
    id entity;
    NSString *currentTableName;
    NSFetchRequest *request;
    NSManagedObjectContext *currentContext;
    NSManagedObjectID *managedObjectId;
    BOOL useFindByManagedObjectId;
   
}


@end

@implementation JLRecords
@synthesize delegate = _delegate;
@synthesize dbNumber = _dbNumber;

-(id)init{
    self = [super init];
    if(self){
        
        [JLDB resetDBNumber];
        managedObjectId = nil;
        useFindByManagedObjectId = NO;
        
    }
    return self;
}

/*
 
 * JLRecords instance method that handles fetching of table/Entity name 
 * Everytime getTable is called it will return a new instance of manageObjectContext
 
*/
-(JLRecords *)getTable:(NSString *)tableName{
    
    currentContext = [[JLDB instance]newManageContext];
    currentTableName = tableName;
    return self;
}

/*
 
 * JLRecords instance method that handles fetching of Table/Entity name
 * Everytime getTableSameContext is called it will return the current/existing manageObjectContext
 
*/

-(JLRecords *)getTableSameContext:(NSString *)tableName{
    if(currentContext == nil){
        currentContext = [[JLDB instance]newManageContext];
    }
    currentTableName = tableName;
    return self;
}

/*
 
 * A private method that handles the initialization of FetchRequest
 
*/

-(void)fetchRequestInit{
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:currentTableName inManagedObjectContext:currentContext];
    request = [[NSFetchRequest alloc] init] ;
    [request setReturnsObjectsAsFaults:YES];
    [request setEntity:entityDesc];
}

/*
 
 * JLRecords instance method that sets the predicate of the query
 * Acts just like a where statement
 
*/
-(JLRecords *)where:(NSPredicate *)condition{
    
    if(currentTableName == nil){
        NSLog(@"Check tablename");
        return nil;
    }
    if(currentContext == nil){
        NSLog(@"Check JLDBConfig");
        return nil;
    }

    
    if(request == nil){
        [self fetchRequestInit];
    }
    
    if (condition) {
        [request setPredicate:condition];
    }
    return self;
 
}

/*
 
 * JLRecords instance method that adds limit to fetch result
 
*/

-(JLRecords *)limit:(NSInteger)limit{
    
    if(currentTableName == nil){
        NSLog(@"Check tablename");
        return nil;
    }
    if(currentContext == nil){
        NSLog(@"Check JLDBConfig");
        return nil;
    }
    if(request == nil){
        [self fetchRequestInit];
    }
    
    
    
    if (limit) {
        [request setFetchLimit:limit];
    }
    return self;
    
}

/*
 
 * JLRecords instance method that adds an offset to the fetch result
 
*/

-(JLRecords *)offset:(NSInteger)offset{
    
    if(currentTableName == nil){
        NSLog(@"Check tablename");
        return nil;
    }
    if(currentContext == nil){
        NSLog(@"Check JLDBConfig");
        return nil;
    }
    if(request == nil){
        [self fetchRequestInit];
    }
    
    
    if (offset) {
        [request setFetchOffset:offset];
    }
    return self;
    
}

/*
 
 * JLRecords instance method that is the same as where method only difference is we use the object's ID in querying the data
 
*/
-(JLRecords *)whereManagedObjectId:(NSManagedObjectID *)objectId{
    
    if(objectId == nil){
        NSLog(@"Check query");
        return nil;
    }
    managedObjectId = objectId;
    useFindByManagedObjectId = YES;
    return self;
}


/*
 
 * JLRecords instance method that triggers the method to perform the fetch query
 * Returns an NSMutableArray
 
*/

-(NSMutableArray *)find{
    
    NSError *errors = nil;
    
    if(currentTableName == nil){
        NSLog(@"Check tablename");
        return nil;
    }
    if(currentContext == nil){
        NSLog(@"Check JLDBConfig");
        return nil;
    }
    
    if(!useFindByManagedObjectId){
        if(request == nil){
            [self where:nil];
        }
        
        
        NSMutableArray *result=[NSMutableArray arrayWithArray:[currentContext executeFetchRequest:request error:&errors]];
        NSMutableArray *resultIds = [NSMutableArray new];
        for(NSManagedObject *objects in result){
            [resultIds addObject:[objects objectID]];
        }
        NSMutableArray *fResults = [NSMutableArray new];
        for(NSManagedObjectID *objectId in resultIds){
            NSManagedObject *obj = [currentContext objectWithID:objectId];
            [fResults addObject:obj];
        }
        return fResults;
    }
    else{
        if(managedObjectId == nil){
            NSLog(@"Check query");
            return nil;
        }
        NSMutableArray *fResult = [NSMutableArray new];
        [fResult addObject:[currentContext objectWithID:managedObjectId]];
        return fResult;
        

    }
   
}


/* 
 
 * JLRecords instance method that creates an entity base from the table name provided
 
*/

-(id)create{
   
    if(currentTableName == nil){
        NSLog(@"Check tablename");
        return nil;
    }
    if(currentContext == nil){
        NSLog(@"Check JLDBConfig");
        return nil;
    }
    entity = [NSEntityDescription insertNewObjectForEntityForName:currentTableName inManagedObjectContext:currentContext];
    
    if(entity != nil)
        return entity;
    return nil;
}

/*
 
 * JLRecords instance method that handles the deletion of an object
 
*/

-(void)deleteObject:(id)object{
    [JLDB deleteObject:object fromContext:currentContext];
}

/*
 
 * Calls JLDB to save the current context
 
 */
-(void)save{
    [JLDB instance].delegate = self;
    [JLDB saveContext:currentContext];
}

/*
 
 * Remove the notification for merging of context
 * Remove db
 
 */
-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    db = nil;
}


/*
 
 * The Delegate update will be performed on the main thread so it is advisable that the save functionality should be done outside the loop as not to block the main thread in every successful merge
 
*/
#pragma mark - DELEGATE ACTION
- (void)triggerSuccessfulUpdate{
    
    if(![NSThread isMainThread])
        [self performSelectorOnMainThread:@selector(triggerSuccessfulUpdate) withObject:nil waitUntilDone:NO];
  
    [_delegate JLDatabaseUpdateComplete];
}

/*
 
 * After the context have merge JLDBMergeSucess will be called
 
*/
#pragma mark - CALLBACK
-(void)JLDBMergeSuccess{
   
    [self triggerSuccessfulUpdate];

}


/*
 
 * JLRecords can handle multiple database name just by assigning the dbNumber
 * The dbNumber is based on JLDBConfig.plist DBName heirarchy
 
*/

#pragma  mark - SETTER
-(void)setDbNumber:(NSInteger)dbNumber{
    [JLDB instance].dbNumber = dbNumber;
}
-(NSInteger)dbNumber{
    return [JLDB instance].dbNumber;
}

@end
