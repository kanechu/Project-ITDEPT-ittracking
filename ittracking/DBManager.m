//
//  DBManager.m
//  worldtrans
//
//  Created by itdept on 2/26/14.
//  Copyright (c) 2014 itdept. All rights reserved.
//

#import "DBManager.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "FMDatabasePool.h"
#import "FMDatabaseQueue.h"

static DBManager *sharedInstance = nil;
static FMDatabase *database = nil;
static int DB_VERSION = 1;

#define FMDBQuickCheck(SomeBool) { if (!(SomeBool)) { NSLog(@"Failure on line %d", __LINE__); abort(); } }


@implementation DBManager

+(DBManager*)getSharedInstance{
    if (!sharedInstance) {
        sharedInstance = [[super allocWithZone:NULL]init];
        [sharedInstance fn_create_db];
    } else {
        if (![database openWithFlags:SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | SQLITE_OPEN_FILEPROTECTION_COMPLETE]) {
            database = nil;
        }
    }
    return sharedInstance;
}


-(FMDatabase*) fn_get_db{
    return database;
}

-(BOOL)fn_create_db{
    NSArray *llist_paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *ls_documentDirectory = [llist_paths objectAtIndex:0];
    NSString *ls_dbPath = [ls_documentDirectory stringByAppendingPathComponent:@"itdept.db"];
    
    BOOL lb_Success = YES;
    database= [FMDatabase databaseWithPath:ls_dbPath] ;
    if (![database open]) {
        lb_Success = NO;
        NSLog(@"Failed to open/create database");
    } else {
        return  [self fn_create_table];
    }
    return lb_Success;
}


-(BOOL)fn_create_table{
    BOOL lb_Success = YES;
    if (![database open]) {
        lb_Success = NO;
        NSLog(@"Failed to open/create database");
    } else {
        NSString *ls_sql_stmt =
        @"CREATE TABLE IF NOT EXISTS alert ( unique_id INTEGER PRIMARY KEY,user_code TEXT NOT NULL DEFAULT '', ct_type TEXT NOT NULL DEFAULT '', so_uid TEXT NOT NULL DEFAULT '', so_no TEXT NOT NULL DEFAULT '', hbl_uid TEXT NOT NULL DEFAULT '', hbl_no TEXT NOT NULL DEFAULT '', status_desc TEXT NOT NULL DEFAULT '', act_status_date TEXT NOT NULL DEFAULT '', act_status_time TEXT NOT NULL DEFAULT '', msg_recv_date TEXT NOT NULL DEFAULT '', is_read INT DEFAULT 0);";
        NSString *ls_sql_login = @"CREATE TABLE IF NOT EXISTS loginInfo( unique_id INTEGER PRIMARY KEY,user_code TEXT NOT NULL DEFAULT '',password TEXT NOT NULL DEFAULT '',login_time TEXT NOT NULL DEFAULT '',user_logo TEXT)";
        NSString *ls_sql_device=@"CREATE TABLE IF NOT EXISTS device( unique_id INTEGER PRIMARY KEY,device_id TEXT NOT NULL DEFAULT '')";
        NSString *ls_sql_portName=@"CREATE TABLE IF NOT EXISTS portName( unique_id INTEGER PRIMARY KEY,display TEXT NOT NULL DEFAULT '',data TEXT NOT NULL DEFAULT '',desc TEXT NOT NULL DEFAULT '',image TEXT NOT NULL DEFAULT '')";
         NSString *ls_sql_searchCriteria=@"CREATE TABLE IF NOT EXISTS searchCriteria( unique_id INTEGER PRIMARY KEY,srch_type TEXT NOT NULL DEFAULT '',seq TEXT NOT NULL DEFAULT '',col_code TEXT NOT NULL DEFAULT '',col_label TEXT NOT NULL DEFAULT '',col_type TEXT NOT NULL DEFAULT '',col_option TEXT NOT NULL DEFAULT '',col_def TEXT NOT NULL DEFAULT '',group_name TEXT NOT NULL DEFAULT '',is_mandatory TEXT NOT NULL DEFAULT '',icon_name TEXT NOT NULL DEFAULT '',save_time TEXT NOT NULL DEFAULT '')";
        NSString *ls_sql_icon=@"CREATE TABLE IF NOT EXISTS icon( unique_id INTEGER PRIMARY KEY,ic_name TEXT NOT NULL DEFAULT '',ic_content TEXT NOT NULL DEFAULT '',upd_date TEXT NOT NULL DEFAULT '')";
        NSString *ls_sql_excntr_status=@"CREATE TABLE IF NOT EXISTS excntr_status( unique_id INTEGER PRIMARY KEY,cntr_uid TEXT NOT NULL DEFAULT '',cntr_no TEXT NOT NULL DEFAULT '',size_type_word TEXT NOT NULL DEFAULT '',remark TEXT NOT NULL DEFAULT '',location TEXT NOT NULL DEFAULT '',act_status_date TEXT NOT NULL DEFAULT '',eventtransportmode TEXT NOT NULL DEFAULT '')";
        
        NSString *ls_sql_sypara=@"CREATE TABLE IF NOT EXISTS sypara( id INTEGER PRIMARY KEY,unique_id TEXT NOT NULL DEFAULT '',para_code TEXT NOT NULL DEFAULT '',company_code TEXT NOT NULL DEFAULT '',data1 TEXT NOT NULL DEFAULT '',data2 TEXT NOT NULL DEFAULT '',data3 TEXT NOT NULL DEFAULT '',data4 TEXT NOT NULL DEFAULT '',data5 TEXT NOT NULL DEFAULT '',para_desc TEXT NOT NULL DEFAULT '',rec_crt_user TEXT NOT NULL DEFAULT '',rec_upd_user TEXT NOT NULL DEFAULT '',rec_crt_date TEXT NOT NULL DEFAULT '',rec_upd_date TEXT NOT NULL DEFAULT '',db_id TEXT NOT NULL DEFAULT '',is_ct TEXT NOT NULL DEFAULT '',crt_user TEXT NOT NULL DEFAULT '',req_user TEXT NOT NULL DEFAULT '',rmk TEXT NOT NULL DEFAULT '')";
        
        [database executeUpdate:ls_sql_stmt];
        [database executeUpdate:ls_sql_login];
        [database executeUpdate:ls_sql_device];
        [database executeUpdate:ls_sql_portName];
        [database executeUpdate:ls_sql_searchCriteria];
        [database executeUpdate:ls_sql_icon];
        [database executeUpdate:ls_sql_excntr_status];
        [database executeUpdate:ls_sql_sypara];
        [database close];
        return  lb_Success;
    }
    return lb_Success;
}

- (int) fn_get_version {
    FMResultSet *resultSet = [database executeQuery:@"PRAGMA user_version"];
    int li_version = 0;
    if ([resultSet next]) {
        li_version = [resultSet intForColumnIndex:0];
    }
    return li_version;
}

- (void)fn_set_version:(int)ai_version {
    // FMDB cannot execute this query because FMDB tries to use prepared statements
    sqlite3_exec(database.sqliteHandle, [[NSString stringWithFormat:@"PRAGMA user_version = %d", ai_version] UTF8String], NULL, NULL, NULL);
}

- (BOOL)fn_chk_need_migration {
    return [self fn_get_version] < DB_VERSION;
}

- (void) fn_db_migrate {
    int version = [self fn_get_version];
    if (version >= DB_VERSION)
        return;
    
    NSLog(@"Migrating database schema from version %d to version %d", version, DB_VERSION);
    
    // ...the actual migration code...
    /*if (version < 1) {
        [[self database] executeUpdate:@"CREATE TABLE foo (...)"];
    }*/
    
    [self fn_set_version:DB_VERSION];
    NSLog(@"Database schema version after migration is %d", [self fn_get_version]);
}

@end
