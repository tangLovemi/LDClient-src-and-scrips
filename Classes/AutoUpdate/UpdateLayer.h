#ifndef __UpdateLayer_H__
#define __UpdateLayer_H__

#include "cocos2d.h"
#include "AttDefine.h"
#include <queue>
using namespace std;
using namespace cocos2d;
#include "AutoUpdate.h"

#include "CCLuaEngine.h"
typedef void (CCObject::*SEL_UpdateEndCallBackFunc)(int state);
#define updateendcallback_selector(_SELECTOR) (SEL_UpdateEndCallBackFunc)(&_SELECTOR)
class UpdateLayer:
	public CCLayer
{
public:
	UpdateLayer(void);
	virtual ~UpdateLayer(void);
	virtual bool init();
	static UpdateLayer* create();
	void UpdateState(UpdateUnit unit);
	void				Update( float dt );
	void callLuaFunction(const char* luaFileName,const char* functionName, int state);
private:
	std::queue<UpdateUnit> m_queue;
	CCProgressTimer*	m_BarProgress;
	int updateCallBack[UPDATE_COUNT];
	CCObject* m_target;
	SEL_UpdateEndCallBackFunc m_callBack;
	CCLabelTTF* m_countLabel;
};

#endif