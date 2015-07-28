#include "NetWorkManager.h"
#include "AppDelegate.h"
#include "Util/Utf8.h"

NetWorkManager* s_instance = NULL;

NetWorkManager::NetWorkManager()
{
	m_luaStack = CCLuaEngine::defaultEngine()->getLuaStack();
	addChild(new TCPSocketManager(), 0);
}

NetWorkManager::~NetWorkManager()
{

}

NetWorkManager* NetWorkManager::sharedInstance()
{
	if (NULL == s_instance)
	{
		s_instance = new NetWorkManager();
	//	s_instance->retain();
	}
	return s_instance;
}

void NetWorkManager::createSocket(CCScene* scene, const char* ip)
{
	if(sSocketMgr.GetSocket(1)!=NULL)
		return;

	scene->addChild(s_instance);
	sSocketMgr.createSocket(ip, CONNECT_PORT, 1);
	//注册回调函数
	sSocketMgr.register_process1(0, SCT_CALLBACK_2(NetWorkManager::onReceivedMessage, this));
}

void NetWorkManager::removeSocket(CCScene* scene)
{
	scene->removeChild(s_instance, false);
	sSocketMgr.removeSocket(1);
	//注销回调函数
	sSocketMgr.unregister_process1();
}

void NetWorkManager::setScriptHandler(int scriptHandler)
{
	m_scriptHandler = scriptHandler;
}

void NetWorkManager::sendMessage(short type, lua_State* luaStack)
{
	SJSendMessage msg(type, luaStack);
	sSocketMgr.SendPacket(1, &msg);
}

bool NetWorkManager::onReceivedMessage(uint16 _tag, char* buffer)
{
	m_luaStack->pushInt(_tag);
	SJRecvMessage msg(buffer);
  	msg.doDecode(_tag, m_luaStack->getLuaState());
	m_luaStack->executeFunctionByHandler(m_scriptHandler, 2);
	m_luaStack->clean();
	return true;
}