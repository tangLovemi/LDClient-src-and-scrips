
// 源自于互联网修改
// Author: gaojiefeng
// Date: 2015-03-02 13:42:36
//

#include "Toast.h"
#include "Util.h"
Toast* Toast::m_instance = NULL;

Toast::Toast()
{
	m_isFirst = true;
	m_bgpath = "Res/Image/toast_bg.png";
}

Toast::~Toast()
{
	m_instance = NULL;
}

Toast* Toast::getInstance()
{
	if(m_instance == NULL)
	{
		m_instance = create();
	}
	return m_instance;
}

Toast* Toast:: create()
{ 
	Toast *pRet = new Toast();
	if (pRet && pRet->init())
	{ 
		pRet->autorelease();
		return pRet;
	} 
	else
	{
		delete pRet;
		pRet = NULL;
		return NULL;
	} 
}


bool Toast::init()
{
    bool bRet = false;
    do {
        CC_BREAK_IF(!CCLayerColor::initWithColor(ccc4(0, 0, 0, 0)));//ccc4(0, 0, 0, 125)
		//CCSize visibleSize = CCDirector::sharedDirector()->getVisibleSize();
		//CCPoint origin = CCDirector::sharedDirector()->getVisibleOrigin();
		////====================================
		//m_bg = CCScale9Sprite::create("Res/Image/toast_bg.png");
		//m_bg->setPosition(ccp(origin.x+visibleSize.width/2,origin.y+130*visibleSize.height/960));
		//this->addChild(m_bg,10);
		////============================
        bRet = true;
    } while (0);
    return bRet;
}

void Toast::changeBg(const char* bgpath)
{
	m_bgpath = bgpath;
}

CCAction* Toast::createAction(float time)
{
	CCAction* addAction = CCSpawn::create(CCArray::create(
		CCMoveBy::create(time/2, CCPointMake(0.0, 100.0)), 
		CCFadeOut::create(time/2), 
		NULL
		));
	CCAction* action = CCSequence::create(CCArray::create(
		CCFadeIn::create(0.1),
		CCDelayTime::create(0.3),
		CCMoveBy::create(time/2, CCPointMake(0.0, 100.0)),
		addAction, 
		CCCallFuncN::create(this, callfuncN_selector(Toast::removeSelf)),
		NULL)
		);
	return action;
}

void Toast::show( string msg,float time ,float posX,float posY)
{
	m_isFirst = false;
	CCSprite* pLabel = createEdgeLabel(msg.c_str(),2,ccc3(0,0,0));
	pLabel->setPosition(ccp(posX,posY));
	this->addChild(pLabel,10);
	pLabel->runAction(createAction(time));
}
void  Toast::showWithNode(string msg,float time,float posX,float posY,CCNode* pNode)
{
	m_isFirst = false;

	CCSprite* pLabel = createEdgeLabel(msg.c_str(),2,ccc3(0,0,0));
	pLabel->setPosition(ccp(posX,posY));
	this->addChild(pLabel,1);
	pLabel->runAction(createAction(time));

	pNode->setAnchorPoint(ccp(0.5,0.5));
	pNode->setPosition(ccp(posX,posY));
	this->addChild(pNode,2);
	pNode->runAction(createAction(time));
}
void Toast::removeSelf(CCNode* pSender)
{	
	/*this->removeAllChildrenWithCleanup(true);
	this->removeFromParentAndCleanup(true);
	onExit();*/

	pSender->stopAllActions();
	pSender->removeFromParentAndCleanup(true);
	pSender = NULL;
}


void Toast::onExit()
{
	CCLayerColor::onExit();
}

bool Toast::isFirst()
{
	return m_isFirst;
}