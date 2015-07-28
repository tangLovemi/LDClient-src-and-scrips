#pragma once

#include "cocos2d.h"

#include "SJActor.h"
USING_NS_CC;

class GuideLayer : public CCLayer
{
public:
	GuideLayer(void);
	~GuideLayer(void);

	static GuideLayer* create(const char *pointImg, float height);

	bool init(const char *pointImg, float height);

	void showGuide(float x, float y, float w, float h);
	void clearGuide();

	void setTouchDelegate(CCPoint point);

	virtual bool ccTouchBegan(CCTouch *pTouch, CCEvent *pEvent);
	virtual void ccTouchMoved(CCTouch *pTouch, CCEvent *pEvent);
	virtual void ccTouchEnded(CCTouch *pTouch, CCEvent *pEvent);

protected:
	CCClippingNode* m_clipNode;

	CCArmature *armature;
	float pointH;

	CCRect* m_rec;

	bool m_touchFlag;

};

