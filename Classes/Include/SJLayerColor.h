#ifndef __LuanDou__SJLayerColor__
#define __LuanDou__SJLayerColor__

#include <iostream>
#include "cocos2d.h"
#include "cocos-ext.h"

using namespace std;

USING_NS_CC;
USING_NS_CC_EXT;

class SJLayerColor:public CCLayerColor
{

public:
	SJLayerColor();
	~SJLayerColor();
	 void onEnter();
	 void onExit();
	//LUA FUNCTION
	static SJLayerColor* createSJLayer(const ccColor4B& color, float width, float height);
	virtual bool initSJLayer(const ccColor4B& color, float width, float height);

};

#endif