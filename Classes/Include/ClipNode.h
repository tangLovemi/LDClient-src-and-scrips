
#ifndef __GAME_CLIP__
#define __GAME_CLIP__
#include "cocos2d.h"
#include "cocos-ext.h"
using namespace cocos2d;
class ClipNode:
	public CCNode
{
public:
	ClipNode();
	virtual ~ClipNode();
	static ClipNode* create(const char*img);
	virtual bool init(const char*img);
	virtual void setClipPosition(CCPoint p);
	virtual CCPoint getClipPosition();
	virtual CCSize getImgSize();
	virtual void setFlipX(bool flipx);
	virtual bool getFlipX();
	virtual void setFlipY(bool flipy);
	virtual bool getFlipY();
	virtual void setClipX(float x);
	virtual void setClipY(float y);
	virtual float getClipY();
	virtual float getClipX();
	virtual void test(CCNode*node);
private:
	CCDrawNode* m_shape;
	CCSize      m_ImgSize;
	CCSprite*   m_content;
};
#endif

