#ifndef __ATTDEFINE_H__
#define __ATTDEFINE_H__
//enum UPDATE_STATE
//{
//	UPDATE_STATE_NONE,				// 不需要更新;
//	UPDATE_STATE_END,		// 资源更新结束;
//	UPDATE_STATE_DOWNLOAD,		//下载资源
//	UPDATE_STATE_WRITE,		// 写入版本号
//	UPDATE_STATE_FAILED,				//更新失败
//	UPDATE_STATE_ERROR,//更新版本失败
//	UPDATE_COUNT,
//};
const int UPDATE_STATE_NONE = 0;
const int UPDATE_STATE_END = 1;
const int UPDATE_STATE_DOWNLOAD = 2;
const int UPDATE_STATE_WRITE = 3;
const int UPDATE_STATE_FAILED = 4;
const int UPDATE_STATE_ERROR = 5;
const int UPDATE_COUNT = 6;
struct UpdateContent
{
	std::string	    m_version;
	int				m_size;

	UpdateContent( void )
		:m_version( "" )
		,m_size( 0 )
	{

	}
};
struct UpdateUnit
{
	int type;
	float para_0;
	float para_1;
	float para_2;
	float para_3;

	UpdateUnit( int t, float p0, float p1, float p2, float p3 )
		:type( t )
		,para_0( p0 )
		,para_1( p1 )
		,para_2( p2 )
		,para_3( p3 )
	{

	}
};
#define KEY_OF_VERSION						"current-version-code"
#define UPDATE_FILE_VERSION					"version.json"
#define ENABLE_AUTO_UPDATE					true
#define RESOURCE_VERSION					1100
#define UPDATE_FILE_SUFFIX					".zip"
#define M_SIZE								1048576


#define VERSION_URL							"127.0.0.1:80/version.json"
#define RES_DOWN_RUL						"127.0.0.1:80/"
#endif