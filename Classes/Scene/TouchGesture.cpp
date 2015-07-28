#include "TouchGesture.h"

TouchGesture::TouchGesture()
{
	CCSize screenSize = CCEGLView::sharedOpenGLView()->getVisibleSize();
	m_screenWidth = screenSize.width;
	m_screenHeight = screenSize.height;
	m_luaManager = NULL;
	m_scriptHandler = 0;
}

TouchGesture::~TouchGesture()
{
	
}

bool TouchGesture::init(int handler)
{
      m_scriptHandler = handler;
	  m_luaManager = CCScriptEngineManager::sharedManager();
      CCDirector::sharedDirector()->getTouchDispatcher()->addTargetedDelegate(this, 1, false);
	  m_bTouchEnabled = true;
      return true;
}

TouchGesture* TouchGesture::create(int handler)
{
	TouchGesture *pRet = new TouchGesture();
	if (pRet && pRet->init(handler))
	{
		pRet->autorelease();
		return pRet;
	}
	else
	{
		CC_SAFE_DELETE(pRet);
		return NULL;
	}
}

void TouchGesture::sendTouchInfoToScript(int touchType, CCPoint position)
{
	int id = 0;
	CCInteger* value = CCInteger::create(id);
	m_luaManager->getScriptEngine()->executeTouchEvent(m_scriptHandler, touchType, position.x, position.y);
}

bool TouchGesture::ccTouchBegan(CCTouch *pTouch, CCEvent *pEvent)
{
      m_pointBegin = pTouch->getLocation();
	  sendTouchInfoToScript(CCTOUCHBEGAN, m_pointBegin);
      return true;
}

void TouchGesture::ccTouchMoved(CCTouch *pTouch, CCEvent *pEvent)
{
	CCPoint curPoint = pTouch->getLocation();
	CCPoint disPoint = curPoint - m_pointBegin;
	m_pointBegin = curPoint;
	CALC_TOUCH_DISTANCE(disPoint);
	sendTouchInfoToScript(CCTOUCHMOVED, disPoint);
}

 void TouchGesture::ccTouchEnded(CCTouch *pTouch, CCEvent *pEvent)
{
	CCPoint curPoint = pTouch->getLocation();
	sendTouchInfoToScript(CCTOUCHENDED, curPoint);
}