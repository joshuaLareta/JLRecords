//
//  JLDB.h
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


#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define JLPlistName @"JLDBConfig"


@protocol JLDBDelegate<NSObject>

-(void)JLDBMergeSuccess;

@end


@interface JLDB : NSObject
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic,assign)id<JLDBDelegate>delegate;
@property (nonatomic, assign)NSInteger dbNumber;
@property (nonatomic, strong)NSString *currentDatabasename;

+ (JLDB *)instance; // get the singleton for JLDB that holds the DB object

- (NSManagedObjectContext *)newManageContext; // Creates new instance of managedobjectcontext

+ (void)saveContext:(NSManagedObjectContext *)context; // saves the context

+(void)deleteObject:(id)object fromContext:(NSManagedObjectContext *)context;// deletes the object from the given context

+(void)resetDBNumber;// resets the db number to 0



@end
