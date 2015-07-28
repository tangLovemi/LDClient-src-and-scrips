#include "GuideLayer.h"


GuideLayer::GuideLayer(void):
	m_clipNode(NULL),
	armature(NULL),
	m_rec(NULL),
	m_touchFlag(false)
{
}


GuideLayer::~GuideLayer(void)
{
	m_clipNode->removeFromParentAndCleanup(true);
	m_clipNode = NULL;
}


GuideLayer* GuideLayer::create(const char *pointImg, float height)
{
	GuideLayer* guideLayer = new GuideLayer();

	if (guideLayer && guideLayer->init(pointImg, height))
	{
		guideLayer->autorelease();
		return guideLayer;
	}
	else
	{
		CC_SAFE_DELETE(guideLayer);
		return NULL;
	}
}

bool GuideLayer::init(const char *pointImg, float height)
{
	bool result = false;
	if(CCLayer::init() == false){
		return false;
	}

	do 
	{
		m_clipNode = CCClippingNode::create();
		m_clipNode->setInverted(true);
		m_clipNode->setAlphaThreshold(0.0f);
		m_clipNode->setAnchorPoint(ccp(0.5, 0.5));
		this->addChild(m_clipNode);

		CCString* name = CCString::createWithFormat("Res/Animations/Other/%s.ExportJson", pointImg);
		CCArmatureDataManager::sharedArmatureDataManager()->addArmatureFileInfo(name->getCString());
		armature = CCArmature::create(pointImg);
		pointH = height;
		this->addChild(armature);
		
		//±³¾°ÒõÓ°
		CCNode* bgPanel = CCNode::create();
		bgPanel->retain();
		m_clipNode->addChild(bgPanel);
		CCLayerColor* black = CCLayerColor::create(ccc4(0,0,0,150));  
		bgPanel->addChild(black);

		this->setTouchEnabled(false);
		result = true;
	} while (0);


	return result;
}

void GuideLayer::showGuide(float x, float y, float w, float h)
{
	if(m_rec != NULL)
	{
		m_rec = NULL;
	}
	m_rec = new CCRect(x - w/2, y - h/2, w, h);
	//¾ØÐÎ¸ßÁÁ
	CCDrawNode* front=CCDrawNode::create();   
	ccColor4F yellow = {20, 20, 20, 180};
	float hw = w/2;
	float hh = h/2;
	CCPoint rect[4]={ccp(-hw, hh),ccp(hw, hh),ccp(hw, -hh),ccp(-hw, -hh)};
	front->drawPolygon(rect, 4, yellow, 0, yellow);
	front->setPosition(ccp(x, y));
	m_clipNode->setStencil(front);
	//ÍÌÊÉµã»÷
	this->setTouchEnabled(true);
	CCDirector::sharedDirector()->getTouchDispatcher()->addTargetedDelegate(this, -257, true);
	m_touchFlag = true;

	//¼ýÍ·Ë÷ÒýÎ»ÖÃ
	float px = x;
	float py;
	if(y >= SCREEN_CENTER_Y)
	{
		armature->setRotation(180);
		py = y - h/2 - pointH - 30;
	}else{
		armature->setRotation(0);
		py = y + h/2 + 30;
	}

	armature->setPosition(ccp(px, py));
	armature->getAnimation()->playWithIndex(0);
}

void GuideLayer::clearGuide()
{
	CCDirector::sharedDirector()->getTouchDispatcher()->removeDelegate(this);
	this->setTouchEnabled(false);
	m_rec = NULL;
	m_touchFlag = false;
}

void GuideLayer::setTouchDelegate(CCPoint point)
{
	if(m_rec->containsPoint(point))
	{
		if(m_touchFlag == true)
		{
			m_touchFlag = false;
			CCDirector::sharedDirector()->getTouchDispatcher()->setPriority(0, this);
		}
	}else{
		if(m_touchFlag == false)
		{
			m_touchFlag = true;
			CCDirector::sharedDirector()->getTouchDispatcher()->setPriority(-257, this);
		}
	}
}

bool GuideLayer::ccTouchBegan(CCTouch *pTouch, CCEvent *pEvent)
{
	CCPoint p = pTouch->getLocation();
	setTouchDelegate(p);

	return m_touchFlag;
}

void GuideLayer::ccTouchMoved(CCTouch *pTouch, CCEvent *pEvent)
{
	CCPoint p = pTouch->getLocation();
	setTouchDelegate(p);
}

void GuideLayer::ccTouchEnded(CCTouch *pTouch, CCEvent *pEvent)
{
	CCPoint p = pTouch->getLocation();
	setTouchDelegate(p);
}