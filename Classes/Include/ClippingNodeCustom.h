
#ifndef __CLIPPINGNODECUSTOM_CLIP__
#define __CLIPPINGNODECUSTOM_CLIP__
#include "cocos2d.h"
#include "cocos-ext.h"
using namespace cocos2d;
class ClippingNodeCustom:
	public CCNode
{
public:
	ClippingNodeCustom();
	virtual ~ClippingNodeCustom();
	static ClippingNodeCustom* create(int width,int height);
	virtual bool init(int width,int height);
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
	virtual void setInverted(bool invert);
	virtual void addContent(CCNode*node);
private:
	CCDrawNode* m_shape;
	CCSize      m_ImgSize;
	CCSprite*   m_content;
	CCClippingNode *m_clipper;
};
#endif

