#ifndef __ARC_SCENE__
#define __ARC_SCENE__

#include "cocos2d.h"
#include "cocos-ext.h"
#include "SJActor.h"
#include "SJTxtFile.h"
#include "SJConfig.h"
#include <Math.h>
#include "spine/Json.h"
#include "SJCustomActor.h"
USING_NS_CC;
USING_NS_RAPID_JSON;

class SJArcScene : public CCLayer
{
public:
	SJArcScene();
	~SJArcScene();

	static SJArcScene* create();

	virtual bool initScene();
	virtual void loadData(const char* name);
	virtual void loadResources(Value& resData);
	virtual void loadActors();
	virtual void removeFromParentAndCleanup(bool cleanup);
	virtual void removeAllChildrenWithCleanup(bool cleanup);
	virtual void cleanup(void);

	virtual void addActor(SJActor* actor, int z, int tag);
	virtual void removeActor(int tag);
	virtual void removeActor(SJActor* actor);

	virtual void setActorName(SJActor* actor, const char* name);
	virtual SJActor* getActorByName(const char* name);
	virtual CCArray* getAllActorNames();

	virtual void rotateScene(float angle);
	virtual void rotateSceneInterval(float angle, float speed);

	virtual float getSceneLength();
	virtual float getCurAngle();

	virtual float onClick(float x, float y);
	virtual CCArray* getSelectedActors();

	virtual void onEnter();
    virtual void onExit();

	bool isLoadingComplete();
	static long long GetSystemTime();
protected:
	float m_sceneLength;
	float m_curAngle;
	float m_rotateSpeed;
	float m_rotateAngle;

	int m_actorCount;
	CCDictionary* m_locateActors;

	CCArray* m_actorsOnClick;

	Document m_jsonValue;
	vector<const char*> m_resNames;
	vector<std::string>m_resNamesVec;
	vector<std::string>m_saveNames;
	bool m_isLoadingComplete;
	Json *m_jsonRoot;
	CCArray*m_actorArray;

private:
	void loadResAsync(float dt);
	void updateRotate(float dt);
};

#endif