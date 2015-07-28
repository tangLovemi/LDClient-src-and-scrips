
#ifndef __CLIENTCONNECT__
#define __CLIENTCONNECT__
#include "cocos2d.h"
#include "cocos-ext.h"
using namespace cocos2d;
using namespace cocos2d::extension;
//#include "network/HttpRequest.h"
using namespace cocos2d;
class ClientConnect:
	public CCNode
{
public:
	ClientConnect();
	virtual ~ClientConnect();
	void RequestServerList();
	void RegisterRequest(const char* account, const char* pwd);
	static ClientConnect* shareInstance();
private:
	void onHttpRequestServerListCallback(cocos2d::CCNode *sender, void *data);
	void onHttpRequestRegisterCallBack(cocos2d::CCNode *sender, void *data);
	static ClientConnect* m_instance;
	const char* m_ip;
};
#endif

