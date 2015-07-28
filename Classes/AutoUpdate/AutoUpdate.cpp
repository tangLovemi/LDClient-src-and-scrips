#include "AutoUpdate.h"
#include "NNDB.h"
#include <curl/curl.h>
#include "curl/easy.h"
#include <stdio.h>
#include <vector>
#include <fstream>
#include "support/zip_support/unzip.h"
#include "spine/Json.h"
#include "NNUtils.h"
#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)
#include <sys/types.h>
#include <sys/stat.h>
#include <errno.h>
#include <dirent.h>
#endif
#include "cocos-ext.h"
using namespace extension;
USING_NS_CC;
#include "AttDefine.h"

AutoUpdate* AutoUpdate::m_instance = NULL;

AutoUpdate::AutoUpdate( void )
	:m_storagePath( "" )
	,m_willDownVersion( "" )
	,m_resUrl( "" )
	,m_versionFileUrl( "" )
	,m_url("")
	,m_compressPath("")
	,m_count( 0 )
	,m_zipFileCount(0)
	,m_recordedVersion(0)
	,m_willDownVersionToSave("")
	,m_obj(NULL)
	,m_callBackFun(NULL)
{
	m_updateList.clear();
	m_storagePath = CCFileUtils::sharedFileUtils()->getWritablePath();
	m_versionFileUrl =  VERSION_URL;
	_checkStoragePath();
	_setSearchPath();
}

AutoUpdate::~AutoUpdate( void )
{
	m_updateList.clear();
	delete m_instance;
	m_instance = NULL;
}
AutoUpdate* AutoUpdate::getInstance()
{
	if(m_instance == NULL)
		m_instance = new AutoUpdate();
	return m_instance;
}

void AutoUpdate::_checkStoragePath( void )
{
	if (m_storagePath.size() > 0 && m_storagePath[m_storagePath.size() - 1] != '/')
	{
		m_storagePath.append("/");
	}
}
int AutoUpdate::getDownVersion()
{
	return atoi(m_willDownVersionToSave.c_str());
}
void* beginUpdateVersion( void *arg )
{ 
		// 需要更新;
	int type = AutoUpdate::getInstance()->Update();
	if ( type == UPDATE_STATE_WRITE )
	{
		// 告诉主线程写入版本号;
		if (AutoUpdate::getInstance()->m_obj != NULL && AutoUpdate::getInstance()->m_callBackFun != NULL)//
			(AutoUpdate::getInstance()->m_obj->*AutoUpdate::getInstance()->m_callBackFun)(UpdateUnit(UPDATE_STATE_WRITE,AutoUpdate::getInstance()->getDownVersion(), 0, 0, 0));
		type = UPDATE_STATE_NONE;
	}

	if ( type == UPDATE_STATE_NONE || type == UPDATE_STATE_END)
	{
		// 告诉主线程直接进入游戏;
		if (AutoUpdate::getInstance()->m_obj != NULL && AutoUpdate::getInstance()->m_callBackFun != NULL)//
			(AutoUpdate::getInstance()->m_obj->*AutoUpdate::getInstance()->m_callBackFun)(UpdateUnit(UPDATE_STATE_END,0, 0, 0, 0));
	}

	if ( type == UPDATE_STATE_FAILED )
	{
		// 更新发生错误;
		if (AutoUpdate::getInstance()->m_obj != NULL && AutoUpdate::getInstance()->m_callBackFun != NULL)//
			(AutoUpdate::getInstance()->m_obj->*AutoUpdate::getInstance()->m_callBackFun)(UpdateUnit(UPDATE_STATE_ERROR,0, 0, 0, 0));
	}
	return NULL;
}

bool AutoUpdate::AutoUpdateVersion( CCObject*obj, SEL_UpdateCallBackFunc fun )
{
	m_obj = obj;
	m_callBackFun = fun;
	m_url =  RES_DOWN_RUL;
	
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	/*AUTO_UPDATE.m_recordedVersion = atoi(AUTO_UPDATE.GetVersion().c_str());*/
#endif

	// 启动新的线程;
	int errCode = 0;
	do 
	{
		pthread_t		updateThread;
		pthread_attr_t  tAttr;
		errCode = pthread_attr_init( &tAttr );
		CC_BREAK_IF( errCode != 0 );
		errCode = pthread_attr_setdetachstate( &tAttr, PTHREAD_CREATE_DETACHED );
		if ( 0 != errCode )
		{
			pthread_attr_destroy( &tAttr );
			break;
		}
		errCode = pthread_create( &updateThread, &tAttr, beginUpdateVersion, NULL );
		pthread_attr_destroy( &tAttr );
	} while ( 0 );

	return errCode;
}

static size_t getVersionCode( void *ptr, size_t size, size_t nmemb, void* versionData )
{
	std::string* version = (std::string*)versionData;
	version->append( (char*)ptr, size * nmemb );
	return (size * nmemb);
}

int AutoUpdate::CheckUpdate()
{
	if ( false == ENABLE_AUTO_UPDATE )
	{//不允许自动更新
		_delOldRes();
		CCLog( "[CheckUpdate Success]there is not new version." );
		return UPDATE_STATE_NONE;
	}
	if ( 0 == m_versionFileUrl.size() )
	{//没有url不更新
		CCLog( "[CheckUpdate failed]no version file URL." );
		return UPDATE_STATE_NONE;
	}

	curl_global_init(CURL_GLOBAL_ALL);
	CURL* m_curl = curl_easy_init();
	if ( NULL == m_curl )
	{
		CCLog( "[CheckUpdate failed]can not init curl." );
		return UPDATE_STATE_NONE;
	}
	
	m_willDownVersion.clear();

	CURLcode res;
	curl_easy_setopt( m_curl, CURLOPT_URL, m_versionFileUrl.c_str() );
	curl_easy_setopt( m_curl, CURLOPT_SSL_VERIFYPEER, 0L );
	curl_easy_setopt( m_curl, CURLOPT_NOPROGRESS, true );
	curl_easy_setopt( m_curl, CURLOPT_WRITEFUNCTION, getVersionCode );
	curl_easy_setopt( m_curl, CURLOPT_WRITEDATA, &m_willDownVersion );
	res = curl_easy_perform( m_curl );
	curl_easy_cleanup( m_curl );
	curl_global_cleanup();
	Json* jobject=Json_create(m_willDownVersion.c_str());
	if ( NULL == jobject )
	{
		CCLog( "[CheckUpdate failed]down version file error." );
		return UPDATE_STATE_NONE;
	}

	size_t updateSize = Json_getSize(jobject);
	std::vector<UpdateContent> updateList;
	for (size_t i = 0; i < updateSize; ++i){
		Json* versionContent = Json_getItemAt(jobject, i);
		if (versionContent)
		{
			UpdateContent cont;
			cont.m_version = Json_getString(versionContent,"version","");
			updateList.push_back(cont);
		}
	}
	if ( 0 == updateList.size() )
	{
		CCLog( "[CheckUpdate failed]down version file error." );
		return UPDATE_STATE_NONE;
	}
	Json_dispose(jobject);//删除JSON指

	if ( false == m_updateList.empty() )
	{
		m_updateList.clear();
	}
	m_zipFileCount = 0;

	//获取本地当前资源版本
	int recordedVersion = 0;
//#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
//	//recordedVersion = AUTO_UPDATE.m_recordedVersion;
//#else
//	recordedVersion = atoi(GetVersion().c_str());
//#endif
	std::string value = CCUserDefault::sharedUserDefault()->getStringForKey(KEY_OF_VERSION);
	recordedVersion = atoi(value.c_str());
    CCLog("current version=%d",recordedVersion);
	for ( size_t i = 0; i < updateList.size(); ++i )
	{
		int willDownVersion = atoi(updateList[i].m_version.c_str());
		int	willDownSize = updateList[i].m_size;
		if ( (recordedVersion < willDownVersion) && (RESOURCE_VERSION < willDownVersion) )
		{
			m_updateList.push_back(updateList[i]);
		}
	}

	// 如果本地版本比大版本记录中的版本号小，则说明是刚刚覆盖安装过，需要删除本地临时文件
	if (recordedVersion > 0 && recordedVersion < RESOURCE_VERSION)
	{
		_delOldRes();
	}

	if ( 0 == m_updateList.size() )
	{
		return UPDATE_STATE_NONE;
	}

	return UPDATE_STATE_DOWNLOAD;
}

int AutoUpdate::Update( void )
{
	if ( 0 == m_versionFileUrl.size() )
	{
		CCLog( "[Update Failed]no version file url." );
		return UPDATE_STATE_NONE;
	}

	CCFileUtils::sharedFileUtils()->purgeCachedEntries();
	// 开始更新;
	//AUTO_UPDATE.m_zipFileCount ++;
	//AUTO_UPDATE_VIEW_MGR->UpdateStateChange( UpdateNotifyUnit(NotifyType_BeginUpdate, 0, 0, 0, 0) );
	for( size_t i=0; i< m_updateList.size(); ++i ){
		m_zipFileCount++;
		std::string willDownVersion = m_updateList[i].m_version;
		std::string outFileName = m_storagePath + willDownVersion + UPDATE_FILE_SUFFIX;
		remove( outFileName.c_str() );

		std::string resURL = m_url;
		resURL.append(willDownVersion);
		resURL.append(UPDATE_FILE_SUFFIX);
		SetResUrl( resURL.c_str() );
		
		if ( false == _downLoad(outFileName))
		{
			remove( outFileName.c_str() );
			return UPDATE_STATE_FAILED;
		}
		
		// 解压;
		if ( false == _uncompress(outFileName) ){
			remove( outFileName.c_str() );
			return UPDATE_STATE_FAILED;
		}

		remove( outFileName.c_str() );

		// 设置版本号;
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
		m_willDownVersionToSave = willDownVersion;
#else
		NNDB::getInstance()->SetData( KEY_OF_VERSION, willDownVersion.c_str() );
#endif
	}

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
		return UPDATE_STATE_WRITE;
#else
	return UPDATE_STATE_END;
#endif

}
int AutoUpdate::getDownCount()
{
	return m_zipFileCount;
}
int AutoUpdate::getTotalZipCount()
{
	return m_updateList.size();
}
void AutoUpdate::HandleSaveVersion()
{
	CCUserDefault::sharedUserDefault()->setStringForKey(KEY_OF_VERSION, m_willDownVersionToSave);
	CCUserDefault::sharedUserDefault()->flush();
	m_recordedVersion = atoi(m_willDownVersionToSave.c_str());
}

void AutoUpdate::_deleteFile( const char* fileName )
{
	remove( fileName );
}

static size_t downLoadPackage( void *ptr, size_t size, size_t nmemb, void *outFile )
{
	FILE *fp = (FILE*)outFile;
	size_t written = fwrite( ptr, size, nmemb, fp );
	return written;
}

static int progressFunc( void *ptr, double totalToDownload, double nowDownloaded, double totalToUpLoad, double nowUpLoaded )
{
	CCLog( "downloading...%d%%", (int)(nowDownloaded / totalToDownload * 100) );
	if(totalToDownload < 0 || nowDownloaded < 0)
		return 0;
	UpdateUnit( UPDATE_STATE_DOWNLOAD,nowDownloaded,totalToDownload, 0, 0 );
	if (AutoUpdate::getInstance()->m_obj != NULL && AutoUpdate::getInstance()->m_callBackFun != NULL)
		(AutoUpdate::getInstance()->m_obj->*AutoUpdate::getInstance()->m_callBackFun)(UpdateUnit(UPDATE_STATE_DOWNLOAD,nowDownloaded, totalToDownload, AutoUpdate::getInstance()->getDownCount(), AutoUpdate::getInstance()->getTotalZipCount()));
	return 0;
}

bool AutoUpdate::_downLoad( std::string outFileName )
{
	FILE *fp = fopen( outFileName.c_str(), "wb" );
	if ( NULL == fp )
	{
		CCLog( "[downLoad Failed]can not create file %s", outFileName.c_str() );
		return false;
	} 

	curl_global_init(CURL_GLOBAL_ALL);
	CURL* m_curl = curl_easy_init();

	CURLcode res;
	curl_easy_setopt( m_curl, CURLOPT_URL, m_resUrl.c_str() );
	curl_easy_setopt(m_curl, CURLOPT_POST, false); 
	curl_easy_setopt( m_curl, CURLOPT_WRITEFUNCTION, downLoadPackage );
	curl_easy_setopt( m_curl, CURLOPT_WRITEDATA, fp );
	curl_easy_setopt( m_curl, CURLOPT_NOPROGRESS, false );
	curl_easy_setopt( m_curl, CURLOPT_PROGRESSFUNCTION, progressFunc );
	curl_easy_setopt(m_curl, CURLOPT_PROGRESSDATA, this);
	res = curl_easy_perform( m_curl );

	curl_easy_cleanup( m_curl );
	curl_global_cleanup();
	if ( 0 != res )
	{
		CCLog( "[downLoad Failed]error when download res.error code:%d", (int)res );
		fclose( fp );
		return false;
	}

	CCLog( "[downLoad Success]succeed downloading res %s", m_resUrl.c_str() );
	fclose(fp);
	return true;
}

bool AutoUpdate::_isExistDirectory( const char* path )
{
#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)
	DIR *pDir = NULL;

	pDir = opendir (path);
	if (! pDir)
	{
		return false;
	}
	return true;
#else
	if ( (GetFileAttributesA(path)) == INVALID_FILE_ATTRIBUTES )
	{
		return false;
	}
	return true;
#endif
}

bool AutoUpdate::_createDirectory( const char* path )
{
#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)
	mode_t processMask = umask(0);
	int ret = mkdir(path, S_IRWXU | S_IRWXG | S_IRWXO);
	umask(processMask);
	if (ret != 0 && (errno != EEXIST))
	{
		return false;
	}

	return true;
#else
	BOOL ret = CreateDirectoryA( path, NULL );
	if ( !ret && ERROR_ALREADY_EXISTS != GetLastError() )
	{
		return false;
	}
	return true;
#endif
}

void AutoUpdate::_setSearchPath( void )
{
	std::string szPlatformPath = m_storagePath;
	std::vector<std::string> defaultSearchPathArray = CCFileUtils::sharedFileUtils()->getSearchPaths();
	std::vector<std::string> searchPaths = defaultSearchPathArray;
	searchPaths.insert( searchPaths.begin(),   m_storagePath );
	CCFileUtils::sharedFileUtils()->setSearchPaths( searchPaths );
}

void AutoUpdate::SetStoragePath( const char* storagePath )
{
	m_storagePath = storagePath;
	_checkStoragePath();
}

std::string AutoUpdate::GetVersion( void )
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	std::string value = CCUserDefault::sharedUserDefault()->getStringForKey(KEY_OF_VERSION);
	//CCLog(("VERSION == "+ value).c_str());
	return value.c_str();
#else
	const char* pVer = NNDB::getInstance()->GetData(KEY_OF_VERSION);
	if ( pVer )
	{
		return std::string(pVer);
	}
#endif
	return "";
}

void AutoUpdate::DeleteVersion( void )
{
	NNDB::getInstance()->delData(KEY_OF_VERSION);
}



void AutoUpdate::SetUrl( const char* url )
{
	//m_url = url;

	// 设置版本URL地址;
	//std::string versionURL = m_url;
	//versionURL.append( UPDATE_FILE_VERSION );
	SetVersionFileUrl(url);
}

bool AutoUpdate::_checkRes( std::string outFileName, std::string willDownMD5  )
{
	//std::string downMd5 = _generateMd5( outFileName.c_str() );
	//if ( 0 == downMd5.size() || downMd5 != willDownMD5 )
	//{
	//	CCLog( "[Update Failed]Down package file break down.%s",outFileName.c_str() );
	//	return false;
	//}
	return true;
}

bool AutoUpdate::_uncompress( std::string outFileName, std::string strFileIndex )
{
	unzFile zipfile = unzOpen( outFileName.c_str() );
	if (! zipfile)
	{
		CCLog("[uncompress failed]can not open downloaded zip file %s", outFileName.c_str());
		return false;
	}

	unz_global_info global_info;
	if (unzGetGlobalInfo(zipfile, &global_info) != UNZ_OK)
	{
		CCLog("[uncompress failed]can not read file global info of %s", outFileName.c_str());
		unzClose(zipfile);
	}

	CCLog("[uncompress]start uncompressing");
	char readBuffer[BUFFER_SIZE];

	uLong i;
	for (i = 0; i < global_info.number_entry; ++i)
	{
		unz_file_info fileInfo;
		char fileName[MAX_FILENAME];
		if (unzGetCurrentFileInfo(zipfile,
			&fileInfo,
			fileName,
			MAX_FILENAME,
			NULL,
			0,
			NULL,
			0) != UNZ_OK)
		{
			CCLog("[uncompress failed]can not read file info");
			unzClose(zipfile);
			return false;
		}

		std::string fullPath = m_storagePath + strFileIndex + fileName;
		const size_t filenameLength = strlen(fileName);
		if (fileName[filenameLength-1] == '/')
		{
			if (!_createDirectory(fullPath.c_str()))
			{
				CCLog("[uncompress failed]can not create directory %s", fullPath.c_str());
				unzClose(zipfile);
				return false;
			}
		}
		else
		{
			if (unzOpenCurrentFile(zipfile) != UNZ_OK)
			{
				CCLog("[uncompress failed]can not open file %s", fileName);
				unzClose(zipfile);
				return false;
			}
			FILE *out = fopen(fullPath.c_str(), "wb");
			if (! out)
			{
				CCLog("[uncompress failed]can not open destination file %s", fullPath.c_str());
				unzCloseCurrentFile(zipfile);
				unzClose(zipfile);
				return false;
			}
			int error = UNZ_OK;
			do
			{
				error = unzReadCurrentFile(zipfile, readBuffer, BUFFER_SIZE);
				if (error < 0)
				{
					CCLog("[uncompress failed]can not read zip file %s, error code is %d", fileName, error);
					unzCloseCurrentFile(zipfile);
					unzClose(zipfile);
					return false;
				}

				if (error > 0)
				{
					fwrite(readBuffer, error, 1, out);
				}
			} while(error > 0);

			fclose(out);
		}

		unzCloseCurrentFile(zipfile);

		if ((i+1) < global_info.number_entry)
		{
			if (unzGoToNextFile(zipfile) != UNZ_OK)
			{
				CCLog("[uncompress failed]can not read next file");
				unzClose(zipfile);
				return false;
			}
		}
	}
	unzClose(zipfile);
	CCLog("[uncompress success]end uncompressing");
	return true;
}

bool AutoUpdate::_delOldRes( void )
{
	// 删除老资源目录即可;
	std::string szPlatformPath = m_storagePath;
	std::vector<std::string> dirVec;

	dirVec.push_back( "/fonts" );
	dirVec.push_back( "/Res" );
	dirVec.push_back( "/Scripts" );
	dirVec.push_back( "/User" );
	for ( size_t i=0; i < dirVec.size(); ++i )
	{
	DeleteDir(szPlatformPath+dirVec[i]);
	}
	return true;
}
