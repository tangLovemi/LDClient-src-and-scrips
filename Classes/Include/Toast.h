#pragma once
/**
 * 这个类是模仿Android中的toast类，暂时只是初步实现了在指定位置出现消息弹框，并在指定时间内消失的功能
 * 初步打算以后为此类添加基本的动画功能，类似tween
 */
#include "cocos2d.h"
#include "cocos-ext.h"
USING_NS_CC;
USING_NS_CC_EXT;
using namespace std;

class Toast: public CCLayerColor
{
private:
	Toast();
	static Toast* m_instance;
protected:
	boolean m_isFirst;
	string m_bgpath;
public:
	~Toast();
	static Toast* getInstance();
	bool isFirst();
	static Toast* create();
	virtual bool init();
	void changeBg(const char* bgpath);
	void show(string msg,float time,float posX,float posY);
	void removeSelf(CCNode* pSender);
    void onExit();
	void showWithNode(string msg,float time,float posX,float posY,CCNode* pNode);
	CCAction* createAction(float time);
};