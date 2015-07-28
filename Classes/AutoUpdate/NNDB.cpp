#include "NNDB.h"

//USING_NS_CC;
#include "cocos2d.h"
using namespace cocos2d;
#define			DB_NAME			"sjdb"
NNDB *NNDB::m_instance = NULL;
NNDB::NNDB( void )
	:m_storagePath( "" )
	,m_hasInit( false )
#if (CC_TARGET_PLATFORM != CC_PLATFORM_ANDROID)	
	//,m_dbPtr( NULL )
	//,m_stmt_select( NULL )
	//,m_stmt_remove( NULL )
	//,m_stmt_update( NULL )
#endif
{
	m_storagePath = CCFileUtils::sharedFileUtils()->getWritablePath();
	_initDB();
}

NNDB::~NNDB( void )
{
	_freeDB();
}
NNDB* NNDB::getInstance()
{
	if(m_instance == NULL)
		m_instance = new NNDB();
	return m_instance;
}
bool NNDB::_initDB( void )
{
	if ( false == m_hasInit )
	{
		std::string storagePath = m_storagePath;
#if (CC_TARGET_PLATFORM != CC_PLATFORM_ANDROID)
		//storagePath.append( DB_NAME );

		//int ret = sqlite3_open( storagePath.c_str(), &m_dbPtr );
		//if( ret != SQLITE_OK ) {
		//	CCLOG( "[InitDB failed] Error initializing %s DB, Error Code = %d.", storagePath.c_str(), ret );
		//	return false;
		//}

		//_initTables();

		//const char *sql_select = "SELECT value FROM storageTable WHERE key=?;";
		//ret |= sqlite3_prepare_v2( m_dbPtr, sql_select, -1, &m_stmt_select, NULL );

		//const char *sql_update = "REPLACE INTO storageTable (key, value) VALUES (?,?);";
		//ret |= sqlite3_prepare_v2( m_dbPtr, sql_update, -1, &m_stmt_update, NULL );

		//const char *sql_remove = "DELETE FROM storageTable WHERE key=?;";
		//ret |= sqlite3_prepare_v2( m_dbPtr, sql_remove, -1, &m_stmt_remove, NULL );

		//if( ret != SQLITE_OK ) {
		//	CCLOG( "[InitDB failed] Error initializing %s DB, Error Code = %d.", storagePath.c_str(), ret );
		//	return false;
		//}
#endif
		m_storagePath = storagePath;
		m_hasInit = true;
	}
	return true;
}

void NNDB::_freeDB( void )
{
	if ( m_hasInit )
	{
#if (CC_TARGET_PLATFORM != CC_PLATFORM_ANDROID)
		//sqlite3_finalize(m_stmt_select);
		//sqlite3_finalize(m_stmt_remove);
		//sqlite3_finalize(m_stmt_update);		
		//sqlite3_close(m_dbPtr);
#endif
		m_hasInit = false;
		m_storagePath = CCFileUtils::sharedFileUtils()->getWritablePath();
	}
}

bool NNDB::_initTables( void )
{
#if (CC_TARGET_PLATFORM != CC_PLATFORM_ANDROID)
	//const char* sql_createtable = "CREATE TABLE IF NOT EXISTS storageTable(key TEXT PRIMARY KEY,value TEXT);";
	//sqlite3_stmt* stmt;
	//int ok = sqlite3_prepare_v2( m_dbPtr, sql_createtable, -1, &stmt, NULL );
	//ok |= sqlite3_step( stmt );
	//ok |= sqlite3_finalize( stmt );

	//if( ok != SQLITE_OK && ok != SQLITE_DONE)
	//{
	//	CCLOG( "[InitTables failed] Error Init Table, Error Code = %d.",ok );
	//	return false;
	//}
#endif
	return true;
}

bool NNDB::SetData( const char* key, const char* value )
{
	if ( false == m_hasInit)
	{
		CCLOG( "[InsertData failed] Error Insert Data(key: %s,value: %s), The DB hasn't be initialed.", key, value );
		return false;
	}
//#if (CC_TARGET_PLATFORM != CC_PLATFORM_ANDROID)
	//int ok = sqlite3_bind_text(m_stmt_update, 1, key, -1, SQLITE_TRANSIENT);
	//ok |= sqlite3_bind_text(m_stmt_update, 2, value, -1, SQLITE_TRANSIENT);

	//ok |= sqlite3_step(m_stmt_update);

	//ok |= sqlite3_reset(m_stmt_update);

	//if( ok != SQLITE_OK && ok != SQLITE_DONE )
	//{
	//	CCLOG( "[InsertData failed] Error Insert Data(key: %s,value: %s), Error Code: %d.", key, value, ok );
	//	return false;
	//}
//#else
	CCUserDefault::sharedUserDefault()->setStringForKey(key, std::string(value));
	CCUserDefault::sharedUserDefault()->flush();
//#endif
	return true;
}

const char* NNDB::GetData( const char* key )
{
	if ( false == m_hasInit)
	{
		CCLOG( "[GetData failed] Error Get Data(key: %s), The DB hasn't be initialed.", key );
		return NULL;
	}
//#if (CC_TARGET_PLATFORM != CC_PLATFORM_ANDROID)
	//int ok = sqlite3_reset(m_stmt_select);

	//ok |= sqlite3_bind_text(m_stmt_select, 1, key, -1, SQLITE_TRANSIENT);
	//ok |= sqlite3_step(m_stmt_select);
	//const unsigned char *ret = sqlite3_column_text(m_stmt_select, 0);


	//if( ok != SQLITE_OK && ok != SQLITE_DONE && ok != SQLITE_ROW)
	//{
	//	CCLOG( "[GetData failed] Error Get Data(key: %s), Error Code: %d.", key, ok );
	//	return NULL;
	//}
	//return (const char*)ret;
//#else
	std::string value = CCUserDefault::sharedUserDefault()->getStringForKey(key);
	return value.c_str();
//#endif
}

bool NNDB::delData( const char* key )
{
	if ( false == m_hasInit)
	{
		CCLOG( "[DelData failed] Error DEL Data(key: %s), The DB hasn't be initialed.", key );
		return false;
	}
//#if (CC_TARGET_PLATFORM != CC_PLATFORM_ANDROID)
	//int ok = sqlite3_bind_text(m_stmt_remove, 1, key, -1, SQLITE_TRANSIENT);

	//ok |= sqlite3_step(m_stmt_remove);

	//ok |= sqlite3_reset(m_stmt_remove);

	//if( ok != SQLITE_OK && ok != SQLITE_DONE)
	//{
	//	CCLOG( "[DelData failed] Error DEL Data(key: %s), Error Code: %d.", key, ok );
	//	return false;
	//}
//#else
	CCUserDefault::sharedUserDefault()->setStringForKey(key, "");
	CCUserDefault::sharedUserDefault()->flush();
//#endif
	return true;
}