#ifndef __BATTLE_ACTOR__
#define __BATTLE_ACTOR__

#include "cocos2d.h"
#include "cocos-ext.h"
#include "SJArmature.h"
#include "SJCustomAnimProtocol.h"
#include "SJConfig.h"

USING_NS_CC;
USING_NS_CC_EXT;

#define NUMBER_FNT_PATH "fonts/number.fnt"

#define AMOUNT_BATTLE_MODULE_HAIR_FRONT	1
#define AMOUNT_BATTLE_MODULE_HAIR_BACK	1
#define AMOUNT_BATTLE_MODULE_FACE		1
#define AMOUNT_BATTLE_MODULE_EYEBROWS	1
#define AMOUNT_BATTLE_MODULE_EYES		1
#define AMOUNT_BATTLE_MODULE_MOUTH		1
#define AMOUNT_BATTLE_MODULE_GOATEE		1
#define AMOUNT_BATTLE_MODULE_HAIR_OTHER	1

#define BATTLE_BONE_HAIROTHER_COUNT		10

#define EFFECT_NUMBER_MAX 7

class SJBattleActor : public SJArmature, public SJCustomAnimProtocol
{
public:
	SJBattleActor();
	virtual ~SJBattleActor();

	static SJBattleActor* create(const char *name);

	virtual float getPositionX();
	virtual float getPositionY();

	virtual float getBonePosX(const char* boneName);
	virtual float getBonePosY(const char* boneName);

	virtual void setActorFace(CCDictionary* faceInfo);
	virtual void changeAPart(const char* partName, const char* imgName, int count);
	virtual void setPartsColor(CCDictionary* colorInfo);
	virtual void setAPartColor(const char* partName, ccColor3B color, int count);

	virtual void addEffect(SJArmature* armature);
	virtual void delEffect(SJArmature* armature);
	virtual void runEffectsAction(CCAction* action);

	virtual void setAction(const char *actionName);
	virtual void setAction(const char *actionName, bool isLoop);
	virtual void setActionQueue(CCArray *animNames, bool isLoop);

	virtual void move(float x, float y);

	virtual CCNode* createNumber(const char* number, float disX, float disY, float time,int type);
	virtual void removeNumber(CCNode* label);

	virtual void setPausePoint(float startTime, float durationTime);
	virtual void pauseAnimation();
	virtual void unpauseAnimation();

	static void purgeAnimRes();


	virtual void animationEventCallFunc(CCArmature* armature, MovementEventType eventType, const char* eventID);
	void registerFrameEvent(const char*eventName, int scriptHandler);
	void onFrameEvent(CCBone *, const char *, int, int);
protected:
	CCArray* m_effects;
	map<string,int>m_frameEventCallBack;
};

#endif