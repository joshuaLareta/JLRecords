//
//  JLRecords.h
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


#import <Foundation/Foundation.h>
#import "JLDB.h"

// Delegate method to handle update in successful database merge
@protocol JLRecordsDelegate <NSObject>

@optional
-(void)JLDatabaseUpdateComplete;

@end


#pragma mark - Basic Usage
/* 
 
 @Basic usage will be

 @Query with a condition:

 ** NSMutableArray *result = [[[instance getTable:@"name_of_table"]where:[NSPredicate predicateWithFormat:@"column = 'value'"]]find];

 @Query without condtion / Query all data for the given table

 ** NSMutableArray *result = [[instance getTable:@"name_of_table"]find];

*/

@interface JLRecords : NSObject<JLDBDelegate>


/*
 
 Sets the delegate of the DB
 * instance.delegate = theDelegate
 * This is an optional property which sets the callback delegate property
 * Calls the JLDatabaseUpdateComplete method after the saving process is done
 
 */
@property(nonatomic, assign)id<JLRecordsDelegate>delegate;


/*
 
 Sets the Table to be used.
 * instance.dbNumber = 1;
 * In the JLDBConfig plist you can set multiple database name the heirarchy will be based from the top going down.
 * This is an optional property
 * Default value will be 0 which means it will fetch the top most dbName entry
 
 */
@property (nonatomic, assign)NSInteger dbNumber;

/*
 
 Sets the table name to be used
 * [instance getTable:@"yourTableName"]
 * Will return a JLRecords instance
 
*/

-(JLRecords *)getTable:(NSString *)TableName;

/*
 
 Sets the table name to be used but reusing the previous managedObjectContext if existing
 * Useful for models with relationship
 * [instance getTableSameContext:@"yourTableName"];
 * Will return a JLRecords instance
*/

-(JLRecords *)getTableSameContext:(NSString *)tableName;


/*
 
 Sets a condition for the existing table query using an NSPredicate
 * This is an optional method, if skipped it will fetch all the data under the given table
 * [instance where:[NSPredicate predicateWithFormat:@"column = 'value'"]]
 * Will return a JLRecords instance
 
*/

-(JLRecords *)where:(NSPredicate *)condition;


/*
 
 Sets a condition for the existing table query using objectID
 * This is an optional method, if skipped it will fetch all the data under the given table
 * [instance whereManagedObjectId:[object objectID]]
 * Will return a JLRecords instance
 
*/

-(JLRecords *)whereManagedObjectId:(NSManagedObjectID *)objectId;


/*
 
 Executes the request
 * [instance find]
 * Will return a NSMutableArray data
 
*/

-(NSMutableArray *)find;

/*
 
 Creates a new entry of a given table
 * [instance create];
 * Will return an NSEntityDescription object based from the given tablename
 
*/

-(id)create;

/*
 
 Saves the current context
 * [instance save];
 
*/
-(void)save; // save the context


/*
 
 Deletes and object from the current context
 * [instance deleteObject:theObject]
 
 */

-(void)deleteObject:(id)object;


/*
 
 Adds a limit to a query
 * [instance limit:0]
 
 */
-(JLRecords *)limit:(NSInteger)limit;


/*
 
 Adds an offset to a query
 * [instance offset:0];
 
 */
-(JLRecords *)offset:(NSInteger)offset;


@end


