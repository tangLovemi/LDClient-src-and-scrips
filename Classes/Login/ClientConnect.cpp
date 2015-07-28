#include "ClientConnect.h"
#include "spine/Json.h"
extern "C" {
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
};
#include "CCLuaEngine.h"
using namespace cocos2d;
ClientConnect* ClientConnect::m_instance = NULL;
ClientConnect::ClientConnect(void)
{
	CCHttpClient::getInstance()->setTimeoutForConnect(30);
	CCHttpClient::getInstance()->setTimeoutForRead(30);
	lua_State*  ls = CCLuaEngine::defaultEngine()->getLuaStack()->getLuaState();
	lua_getglobal(ls, "REQUEST_REGISTER_IP");
	m_ip = lua_tostring(ls,-1);
	//m_instance = NULL;
}


ClientConnect::~ClientConnect(void)
{
	m_instance->release();
	m_instance = NULL;
	delete m_ip;
}
ClientConnect* ClientConnect::shareInstance()
{
	if(m_instance == NULL)
	{
		m_instance = new ClientConnect();
	}
	return m_instance;
}

void ClientConnect::RegisterRequest(const char* account, const char* pwd)
{
	CCHttpRequest* request = new CCHttpRequest();
	string path = m_ip;
	path.append("game_web/regist?account=" + string(account) + "&password=" + string(pwd));
	request->setUrl(path.c_str());
	request->setRequestType(CCHttpRequest::kHttpGet);
	request->setResponseCallback(this, callfuncND_selector(ClientConnect::onHttpRequestRegisterCallBack));
	CCHttpClient::getInstance()->send(request);
	request->release();
}

void ClientConnect::RequestServerList()//请求服务器列表
{
	CCHttpRequest* request = new CCHttpRequest();
	lua_State*  ls = CCLuaEngine::defaultEngine()->getLuaStack()->getLuaState();
	string path = m_ip;
	path.append("game_web/serverList?");
	request->setUrl(path.c_str());
	request->setRequestType(CCHttpRequest::kHttpGet);
	request->setResponseCallback(this, callfuncND_selector(ClientConnect::onHttpRequestServerListCallback));
	CCHttpClient::getInstance()->send(request);
	request->release();
}
void ClientConnect::onHttpRequestRegisterCallBack(cocos2d::CCNode *sender, void *data)
{
	CCHttpResponse *response = (CCHttpResponse*)data;
	lua_State*  ls = CCLuaEngine::defaultEngine()->getLuaStack()->getLuaState();
	if (!response->isSucceed())//连接失败
	{
		lua_getglobal(ls, "ConnectErrorBack");
		int error = lua_pcall(ls, 0, 0, 0);
		if(error!=0){
			CCLOG("Run Lua Error: %s", lua_tostring(ls, -1));
		}
		return;
	}
	std::string bufferStr;
	std::vector<char> *buffer = response->getResponseData();
	for (std::vector<char>::iterator it = buffer->begin(); it != buffer->end(); ++it)
	{
		bufferStr.push_back(*it);
	}
	Json* jobject=Json_create(bufferStr.c_str());
	if ( NULL == jobject )
	{
		CCLog( "[CheckUpdate failed]down version file error." );
	}
	
	lua_getglobal(ls, "RegisterCallBack");
	lua_newtable(ls);
	lua_pushstring(ls, "isOk");	
	lua_pushnumber(ls, Json_getInt(jobject,"isOk",0));	
	lua_settable(ls, -3);

	lua_pushstring(ls, "accountid");			
	lua_pushstring(ls, Json_getString(jobject,"accountid",""));	
	lua_settable(ls, -3);

	lua_pushstring(ls, "account");			
	lua_pushstring(ls, Json_getString(jobject,"account",""));	
	lua_settable(ls, -3);

	lua_pushstring(ls, "password");			
	lua_pushstring(ls, Json_getString(jobject,"password",""));	
	lua_settable(ls, -3);

	int error = lua_pcall(ls, 1, 0, 0);
	if(error!=0){
		CCLOG("Run Lua Error: %s", lua_tostring(ls, -1));
	}
}
void ClientConnect::onHttpRequestServerListCallback(cocos2d::CCNode *sender, void *data)//服务器列表返回
{
	CCHttpResponse *response = (CCHttpResponse*)data;
	CCLuaEngine::defaultEngine()->getLuaStack()->clean();
	lua_State*  ls = CCLuaEngine::defaultEngine()->getLuaStack()->getLuaState();
	int isOpen = luaL_dofile(ls, CCFileUtils::sharedFileUtils()->fullPathForFilename("InitialConnect.lua").c_str());
	if (!response->isSucceed())//连接失败
	{
		//模拟2501
		lua_getglobal(ls, "ConnectErrorBack");
		int error = lua_pcall(ls, 0, 0, 0);
		if(error!=0){
			CCLOG("Run Lua Error: %s", lua_tostring(ls, -1));
		}
		return;
	}
	std::string bufferStr;
	std::vector<char> *buffer = response->getResponseData();
	for (std::vector<char>::iterator it = buffer->begin(); it != buffer->end(); ++it)
	{
		bufferStr.push_back(*it);
	}
	Json* jobject=Json_create(bufferStr.c_str());
	if ( NULL == jobject )
	{
		CCLog( "[CheckUpdate failed]down version file error." );
	}
	size_t listSize = Json_getSize(jobject);


	//string dd = CCFileUtils::sharedFileUtils()->fullPathForFilename(luaFileName).c_str();
	//int isOpen = luaL_dofile(ls, CCFileUtils::sharedFileUtils()->fullPathForFilename("InitialConnect.lua").c_str());
	if(isOpen!=0){
		CCLOG("Open Lua Error: %i", isOpen);
	}

	lua_getglobal(ls, "OpenSelectServerList");
	lua_newtable(ls);
	for (size_t i = 0; i < listSize; ++i)
	{
		//lua_newtable(ls);
		Json* serverData = Json_getItemAt(jobject, i);
		if (serverData)
		{
			lua_pushnumber(ls,i+1);
			lua_newtable(ls);
			lua_pushstring(ls, "id");	
			lua_pushnumber(ls, Json_getInt(serverData,"id",0));	
			lua_settable(ls, -3);
			lua_pushstring(ls, "serverIP");			
			lua_pushstring(ls, Json_getString(serverData,"serverIP",""));	
			lua_settable(ls, -3);
			lua_pushstring(ls, "gameServerPort");			
			lua_pushnumber(ls, Json_getInt(serverData,"gameServerPort",0));	
			lua_settable(ls, -3);
			lua_pushstring(ls, "webServerPort");			
			lua_pushnumber(ls, Json_getInt(serverData,"webServerPort",0));	
			lua_settable(ls, -3);
			lua_pushstring(ls, "serverName");			
			lua_pushstring(ls, Json_getString(serverData,"serverName",""));	
			lua_settable(ls, -3);
			lua_pushstring(ls, "fire");			
			lua_pushnumber(ls, Json_getInt(serverData,"fire",0));	
			lua_settable(ls, -3);
			lua_pushstring(ls, "status");			
			lua_pushnumber(ls, Json_getInt(serverData,"status",0));	
			lua_settable(ls, -3);

			lua_settable(ls, -3);
		}
		//lua_settable(ls, -3);
	}
	int error = lua_pcall(ls, 1, 0, 0);
	if(error!=0){
		CCLOG("Run Lua Error: %s", lua_tostring(ls, -1));
	}
}
