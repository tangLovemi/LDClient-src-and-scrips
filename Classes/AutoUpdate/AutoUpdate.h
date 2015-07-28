
#ifndef __AUTO_UPDATE_H__
#define __AUTO_UPDATE_H__
#include "cocos2d.h"
#include <pthread.h>
//#include <curl/curl.h>
//#include "curl/easy.h"
#include <string>
using namespace cocos2d;
#define M_SIZE								1048576
#define BUFFER_SIZE							8192							
#define MAX_FILENAME						512
#include "UpdateLayer.h"

typedef void (CCObject::*SEL_UpdateCallBackFunc)(UpdateUnit unit);
#define updatecallback_selector(_SELECTOR) (SEL_UpdateCallBackFunc)(&_SELECTOR)
class AutoUpdate : public CCObject
{
public:
	/* @brief 更新入口，会启动新的线程;
	 * 由于ios中不允许使用主线程去连接服务器，防止主线程假死，所以此处会单启一个线程来进行文件更新;
     */
	bool			AutoUpdateVersion(CCObject*obj, SEL_UpdateCallBackFunc fun);
	//void* beginUpdateVersion( void *arg );
	/* @brief 检查是否有新的版本;
     */
	int		CheckUpdate( void );

	/* @brief 更新;
     */
    int		Update( void );
	static AutoUpdate* getInstance();
public:
	/* @brief 获取URL;
     */
	//inline const char* GetUrl( void ) const { return m_url.c_str(); };
    
    /* @brief 设置URL;
     */
	void SetUrl( const char* url );

	/* @brief 获取资源URL;
     */
	inline const char* GetResUrl( void ) const { return m_resUrl.c_str(); };
    
    /* @brief 设置资源的URL;
     */
	inline void SetResUrl( const char* resUrl ) { m_resUrl = resUrl; };
    
    /* @brief 获取版本URL.
     */
	inline const char* GetVersionFileUrl( void ) const { return m_versionFileUrl.c_str(); };
    
    /* @brief 设置版本的URL.
     */
    inline void SetVersionFileUrl( const char* versionFileUrl )  { m_versionFileUrl = versionFileUrl; };

	/* @brief 获取存储地址;
     */
    inline const char* GetStoragePath( void ) const { return m_storagePath.c_str(); };

	/* @brief 设置存储地址;
     */
    void SetStoragePath( const char* storagePath );
    
    /* @brief 获取当前版本;
     */
    std::string GetVersion( void );
    
    /* @brief 删除记录的版本;
     */
    void DeleteVersion( void );

	void			_setSearchPath( void );																	// 设置查询路径;

	//std::string		_generateMd5( const char* fileName );													// 生成NNMD5码;
	bool			_uncompress( std::string outFileName, std::string strFileIndex = "" );					// 解压;
	void HandleSaveVersion();						// 在主线程保存版本号，只Android使用
	int getDownVersion();
	int getDownCount();
	int getTotalZipCount();
public:
	AutoUpdate( void );
	~AutoUpdate( void );

	bool			_downLoad(std::string outFileName);														// 下载文件;
	void			_checkStoragePath( void );																// 检查存储路径，如果存储的路径不带/，则添加/;
	bool			_checkRes(std::string outFileName,std::string willDownMD5);								// 检查资源是否完整;																// 比较资源NNMD5码;
	void			_deleteFile( const char* fileName );													// 删除指定文件;
	bool			_isExistDirectory( const char* path );													// 是否有目录;
	bool			_createDirectory( const char* path );													// 创建目录;
	
	bool			_delOldRes( void );																		// 删除旧资源;

private:
    std::string		m_storagePath;					// 存储路径，即下载的路径;
    std::string		m_willDownVersion;				// 需要更新的资源版本信息;
    std::string		m_resUrl;						// 资源请求URL地址;(动态变化的)
    std::string		m_versionFileUrl;				// 版本文件请求URL地址;
	std::string		m_url;							// 版本更新文件前缀下载url（不包含.zip包名）
	std::map<std::string, UpdateContent>
					m_needUpdateTable;				// 需要更新内容;
	
	std::string		m_compressPath;					// 压缩路径;
	int             m_recordedVersion;              // 本地版本号，只Android使用
	std::string     m_willDownVersionToSave;        // 要保存到本地的版本号，只Android使用

public:
	SEL_UpdateCallBackFunc m_callBackFun;
	CCObject * m_obj;
	SEL_UpdateCallBackFunc m_callBackFun1;
	int				m_count;						// 更新次数;
	int				m_zipFileCount;					// 需要更新zip文件数量;
	std::vector<UpdateContent> m_updateList;
	static AutoUpdate*m_instance;
};
#endif