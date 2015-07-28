#ifndef __TOUCH__GESTURE__
#define __TOUCH__GESTURE__

#include <iostream>
#include "cocos2d.h"
#include "math.h"

using namespace cocos2d;
using namespace std;

#define CALC_TOUCH_DISTANCE(point)	point.x /= m_screenWidth;	\
									point.y /= m_screenHeight;

class TouchGesture : public CCLayer
{
public:
	TouchGesture();
	~TouchGesture();

	static TouchGesture* create(int handler);
	virtual bool init(int handler);
	void sendTouchInfoToScript(int touchType, CCPoint position);
      //触摸事件
	virtual bool ccTouchBegan(CCTouch *pTouch, CCEvent *pEvent);
	virtual void ccTouchMoved(CCTouch *pTouch, CCEvent *pEvent);
	virtual void ccTouchEnded(CCTouch *pTouch, CCEvent *pEvent);

protected:
	float m_screenWidth;
	float m_screenHeight;
	CCPoint m_pointBegin;
	int m_scriptHandler;
	CCScriptEngineManager* m_luaManager;
};

#endif /* defined(__TouchOne__TouchMoveHeng__) */
