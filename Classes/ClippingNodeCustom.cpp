#include "ClippingNodeCustom.h"

using namespace cocos2d;
ClippingNodeCustom::ClippingNodeCustom(void)
{
}


ClippingNodeCustom::~ClippingNodeCustom(void)
{
}
ClippingNodeCustom* ClippingNodeCustom::create(int width,int height)
{//返回值类型必须是本类对象，返回父类对象lua识别不了
	ClippingNodeCustom * node = new ClippingNodeCustom();
	if (node && node->init(width,height))
	{
		node->autorelease();
		return node;
	}
	else
	{
		CC_SAFE_DELETE(node);
	}
	return NULL;
}
bool ClippingNodeCustom::init(int width,int height)
{
	if(CCNode::init())
	{
		this->setAnchorPoint(ccp(0,0));
		m_shape = CCDrawNode::create();
		m_shape->setAnchorPoint(ccp(0,0));
		static CCPoint triangle[4];
		triangle[0] = ccp(0, 0);
		triangle[1] = ccp(width, 0);
		triangle[2] = ccp(width, height);
		triangle[3] = ccp(0, height);
		static ccColor4F green = {0, 1, 0, 1};
		m_shape->drawPolygon(triangle, 4, green, 0, green);

		CCSize s = CCDirector::sharedDirector()->getWinSize();

		CCNode *stencil = m_shape;
		stencil->setPosition( ccp(0,0) );

		m_clipper = CCClippingNode::create();
		m_clipper->setAnchorPoint(ccp(0, 0));
		m_clipper->setStencil(stencil);
		this->addChild(m_clipper);
		m_clipper->setInverted(false);
		return true;
	}
	return false;
}

void ClippingNodeCustom::addContent(CCNode*node)
{
	m_clipper->addChild(node);
}

void ClippingNodeCustom::setInverted(bool invert)
{
	m_clipper->setInverted(invert);
}

void ClippingNodeCustom::test(CCNode*node)
{
}
void ClippingNodeCustom::setClipPosition(CCPoint p)
{
	m_shape->setPosition(p);
}
CCPoint ClippingNodeCustom::getClipPosition()
{
	return m_shape->getPosition();
}
CCSize ClippingNodeCustom::getImgSize()
{
	return m_ImgSize;
}

void ClippingNodeCustom::setFlipX(bool flipx)
{
	m_content->setFlipX(flipx);
}
bool ClippingNodeCustom::getFlipX()
{
	return m_content->isFlipX();
}
void ClippingNodeCustom::setFlipY(bool flipy)
{
	m_content->setFlipY(flipy);
}
bool ClippingNodeCustom::getFlipY()
{
	return m_content->isFlipY();
}
void ClippingNodeCustom::setClipX(float x)
{
	m_shape->setPositionX(x);
}
void ClippingNodeCustom::setClipY(float y)
{
	m_shape->setPositionY(y);
}

float ClippingNodeCustom::getClipY()
{
	return m_shape->getPositionY();
}
float ClippingNodeCustom::getClipX()
{
	return m_shape->getPositionX();
}
