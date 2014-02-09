JLRecords
=========

A class that encapsulates the core data functions and allows multi-threading processes


Properties
----------
* ```JLRecords.delegate```
     * A delegate used for callbacks after saving/merging of context process is done
     * This is an optional property 
* ```JLRecords.dbNumber```
     * In the JLDBConfig plist you can set multiple database name the heirarchy will be based from the top going down.
     * This is an optional property
     * Default value will be 0 which means it will fetch the top most dbName entry

Methods
________
* ```-(JLRecords *)getTable:(NSString *)TableName;```
     * Sets the table name to be used
     * [instance getTable:@"yourTableName"]
     * Will return a JLRecords instance
     
* ```-(JLRecords *)getTableSameContext:(NSString *)tableName;```
     * Sets the table name to be used but reusing the previous managedObjectContext if existing
     * Useful for models with relationship
     * [instance getTableSameContext:@"yourTableName"];
     * Will return a JLRecords instance

* ```-(JLRecords *)where:(NSPredicate *)condition;```
     * Sets a condition for the existing table query using an NSPredicate
     * This is an optional method, if skipped it will fetch all the data under the given table
     * [instance where:[NSPredicate predicateWithFormat:@"column = 'value'"]]
     * Will return a JLRecords instance
     
* ```-(JLRecords *)whereManagedObjectId:(NSManagedObjectID *)objectId;```
     * Sets a condition for the existing table query using objectID
     * This is an optional method, if skipped it will fetch all the data under the given table
     * [instance whereManagedObjectId:[object objectID]]
     * Will return a JLRecords instance
    
* ```-(NSMutableArray *)find;```
     * Executes the request
     * [instance find]
     * Will return a NSMutableArray data
     
* ```-(id)create;```
     * Creates a new entry of a given table
     * [instance create];
     * Will return an NSEntityDescription object based from the given tablename
     
* ```-(void)save;```
     * Saves the current context
     * [instance save];

* ```-(void)deleteObject:(id)object;```
     * Deletes and object from the current context
     * [instance deleteObject:theObject]
     
* ```-(JLRecords *)limit:(NSInteger)limit;```
     * Adds a limit to a query
     * [instance limit:0]
     
* ```-(JLRecords *)offset:(NSInteger)offset;```
     * Adds an offset to a query
     * [instance offset:0];


Usage
_____

Basic usage will be:

* Query with a condition

   ** NSMutableArray *result = [[[instance getTable:@"name_of_table"]where:[NSPredicate predicateWithFormat:@"column = 'value'"]]find];

* Query without condtion / Query all data for the given table

   ** NSMutableArray *result = [[instance getTable:@"name_of_table"]find];

