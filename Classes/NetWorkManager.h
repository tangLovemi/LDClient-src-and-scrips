#ifndef __NETWORK_MANAGER__
#define __NETWORK_MANAGER__

#include "cocos-ext.h"
#include "CCLuaEngine.h"
#include "Message/SJRecvMessage.h"
#include "Message/SJSendMessage.h"
#include "SJConfig.h"

#define CONNECT_PORT	6888

USING_NS_CC;
USING_NS_CC_EXT;

class NetWorkManager : CCNode
{
public:
	NetWorkManager();
	virtual ~NetWorkManager();

	static NetWorkManager* sharedInstance();
	void createSocket(CCScene* scene, const char* ip);
	void removeSocket(CCScene* scene);

	void setScriptHandler(int scriptHandler);

	void sendMessage(short type, lua_State* luaStack);

private:
	CCLuaStack* m_luaStack;
	int m_scriptHandler;

	bool onReceivedMessage(uint16 _tag, char* buffer);
};

#endif