#ifndef __CUSTOM_ARMATURE__
#define __CUSTOM_ARMATURE__

#include "cocos2d.h"
#include "cocos-ext.h"
#include "SJConfig.h"

USING_NS_CC;
USING_NS_CC_EXT;

#define AMOUNT_ANIM_EVENT_TYPE 3

class SJArmature : public CCArmature
{
public:
	SJArmature();
	virtual ~SJArmature();

	static SJArmature *create(const char *name);

	virtual void setFlipX(bool isFlip);
	virtual void setFlipY(bool isFlip);
	virtual bool getFlipX();
	virtual bool getFlipY();

	virtual CCSkin* getSkin(const char* boneName);
	virtual void modifySkin(const char* boneName, const char* imgName);

	virtual void addArmatureToBone(const char* boneName, int index, SJArmature* armature);
	virtual void removeArmatureFromBone(const char* boneName, int index);

	virtual void registerAnimEvent(int eventType, int scriptHandler);
	virtual void registerAnimEvent(int eventType, int scriptHandler, const char* text);
	virtual void unregisterAnimEvent(int eventType);
	virtual void animationEventCallFunc(CCArmature* armature, MovementEventType eventType, const char* eventID);

	static ccColor3B convertColor(CCArray* rgb);

	virtual void removeFromParentAndCleanup(bool cleanup);
	void registerFrameEvent(const char*eventName, int scriptHandler);
	void onFrameEvent(CCBone *, const char *, int, int);
protected:
	bool m_isFlipX;
	bool m_isFlipY;
	int m_animEventCBFunc[AMOUNT_ANIM_EVENT_TYPE];
	int m_animEventCBCount;
	CCString* m_callbackInfo;
	map<string,int>m_frameEventCallBack;

};

#endif