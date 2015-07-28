#ifndef __CUSTOM_ACTOR__
#define __CUSTOM_ACTOR__

#include "SJActor.h"
#include "SJArmature.h"
#include "SJCustomAnimProtocol.h"

#define AMOUNT_SCENE_MODULE_HAIR_FRONT	1
#define AMOUNT_SCENE_MODULE_HAIR_BACK	1
#define AMOUNT_SCENE_MODULE_FACE		1
#define AMOUNT_SCENE_MODULE_EYEBROWS	1
#define AMOUNT_SCENE_MODULE_EYES		1
#define AMOUNT_SCENE_MODULE_MOUTH		1
#define AMOUNT_SCENE_MODULE_GOATEE		1
#define AMOUNT_SCENE_MODULE_HAIR_OTHER	1

#define SCENE_BONE_HAIROTHER_COUNT		10

class SJCustomActor : public SJActor, public SJCustomAnimProtocol
{
public:
	SJCustomActor();
	virtual ~SJCustomActor();

	static SJCustomActor* createActor(const char *imgName, float height, float rotateRate);

	virtual void setActorFace(CCDictionary* faceInfo);
	virtual void changeAPart(const char* partName, const char* imgName, int count);
	virtual void setPartsColor(CCDictionary* colorInfo);
	virtual void setAPartColor(const char* partName, ccColor3B color, int count);

	virtual void createImage(const char *imgName);

	virtual void setAction(const char *actionName);
	virtual void setAction(const char *actionName, int loop);

	SJArmature* getArmature();

	virtual CCRect boundingBox();

	virtual void cleanup(void);
	virtual bool isCollision(CCPoint point);
	virtual CCObject* copy(void);

protected:
	SJArmature* m_armature;
};

#endif