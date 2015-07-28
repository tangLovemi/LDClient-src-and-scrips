#include "ClipNode.h"

using namespace cocos2d;
ClipNode::ClipNode(void)
{
}


ClipNode::~ClipNode(void)
{
}
ClipNode* ClipNode::create(const char*img)
{//返回值类型必须是本类对象，返回父类对象lua识别不了
	ClipNode * node = new ClipNode();
	if (node && node->init(img))
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
bool ClipNode::init(const char*img)
{
	if(CCNode::init())
	{
		this->setAnchorPoint(ccp(0,0));
		m_shape = CCDrawNode::create();
		m_shape->setAnchorPoint(ccp(0,0));
		m_content = CCSprite::create(img);
		float height = m_content->getContentSize().height;
		float width = m_content->getContentSize().width;
		m_ImgSize.width = width;
		m_ImgSize.height = height;
		static CCPoint triangle[4];
		triangle[0] = ccp(0, 0);
		triangle[1] = ccp(width, 0);
		triangle[2] = ccp(width, height);
		triangle[3] = ccp(0, height);
		static ccColor4F green = {0, 1, 0, 1};
		m_shape->drawPolygon(triangle, 4, green, 0, green);

		CCSize s = CCDirector::sharedDirector()->getWinSize();

		CCNode *stencil = m_shape;
		stencil->setPosition( ccp(width,0) );

		CCClippingNode *clipper = CCClippingNode::create();
		clipper->setAnchorPoint(ccp(0, 0));
		clipper->setStencil(stencil);
		this->addChild(clipper);
		clipper->setInverted(true);
		m_content->setAnchorPoint(ccp(0,0));
		m_content->setPosition( ccp(0, 0) );
		clipper->addChild(m_content);
		return true;
	}
	return false;
}
void ClipNode::test(CCNode*node)
{
}
void ClipNode::setClipPosition(CCPoint p)
{
	m_shape->setPosition(p);
}
CCPoint ClipNode::getClipPosition()
{
	return m_shape->getPosition();
}
CCSize ClipNode::getImgSize()
{
	return m_ImgSize;
}

void ClipNode::setFlipX(bool flipx)
{
	m_content->setFlipX(flipx);
}
bool ClipNode::getFlipX()
{
	return m_content->isFlipX();
}
void ClipNode::setFlipY(bool flipy)
{
	m_content->setFlipY(flipy);
}
bool ClipNode::getFlipY()
{
	return m_content->isFlipY();
}
void ClipNode::setClipX(float x)
{
	m_shape->setPositionX(x);
}
void ClipNode::setClipY(float y)
{
	m_shape->setPositionY(y);
}

float ClipNode::getClipY()
{
	return m_shape->getPositionY();
}
float ClipNode::getClipX()
{
	return m_shape->getPositionX();
}
