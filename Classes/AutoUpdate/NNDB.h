 /*@@

	Copyright (c) Beijing Second Laboratory Game Studio. All rights reserved. 
	
	Created_datetime : 	2013-6-7 14:23
	
	File Name :	NNDB.h
	
	Author : zhuhuangqing; 
	
	Description : 数据库更删改查操作，按键值对的方式;
	
	Change List :
				操作如;
				1,增加修改操作调用SetDataToDB("1", "testData");
				2,查询操作调用GetDataFromDB("1");
				3,删除操作调用DelDataFromDB("1");
@@*/

#ifndef NNDB_H
#define NNDB_H


#if (CC_TARGET_PLATFORM != CC_PLATFORM_ANDROID)
//#include "sqlite3.h"
#endif
#include <string>
#include <stdio.h>
using namespace std;

class NNDB
{

public:
	static NNDB* getInstance();
	/* @brief 增加修改记录;
     */
	bool			SetData( const char* key, const char* value );

	/* @brief 获取记录;
     */
	const char*		GetData( const char* key );

	/* @brief 删除记录;
     */
	bool			delData( const char* key );

protected:
	/* @brief 初始化DB;
     */
	bool			_initDB( void );

	/* @brief 释放DB;
     */
	void			_freeDB( void );

	/* @brief 初始化表;
     */
	bool			_initTables( void );
	

protected:
	NNDB( void );
	~NNDB( void );

private:
	static NNDB           *m_instance;
	bool			m_hasInit;						// 是否已经初始化过;
	std::string		m_storagePath;					// 存储路径，即存放DB的路径;
#if (CC_TARGET_PLATFORM != CC_PLATFORM_ANDROID)
	//sqlite3*		m_dbPtr;						// 数据库指针;
	//sqlite3_stmt*	m_stmt_select;					// 查询预处理;	
	//sqlite3_stmt*	m_stmt_remove;					// 删除预处理;
	//sqlite3_stmt*	m_stmt_update;					// 更新增加预处理;
#endif
};
#endif