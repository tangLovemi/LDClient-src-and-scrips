#ifndef __GAME_ACTOR__
#define __GAME_ACTOR__

#include "cocos2d.h"
#include "cocos-ext.h"
#include "SJConfig.h"
#include "Math.h"

USING_NS_CC;
USING_NS_CC_EXT;

#define DIALOG_FONT_SIZE 48
#define NUMBER_FONT_SIZE 72

//#define SHOW_RECT

#define ACTOR_COPY_STRING(str, orig)	int len = strlen(orig);				\
										char* str = new char[len + 1];		\
										memcpy(str, orig, len);				\
										str[len] = '\0';					\

enum ActorType
{
	actorTypeObject,
	actorTypeNpc,
	actorTypePlayer
};

class SJActor : public CCLayer
{
public:
	SJActor();
	virtual ~SJActor();

	static SJActor* createActor(const char *imgName, float height, float rotateRate);

	virtual bool init(const char *imgName, float height, float rotateRate);
	virtual void registerScriptHandler(int handler);
	virtual void unregisterScriptHandler();
	virtual void setName(const char *imgName);
	virtual void setRadius(float radius);
	virtual void setHeight(float radius);
	virtual void setRotateRate(float rotateRate);
	virtual void setOwnAngle(float angle);
	virtual void setType(const char* type);
	virtual void createTimer(float time, int handler);
	virtual void createImage(const char *imgName);

	virtual void setKeyName(const char* key);
	virtual const char* getKeyName();

	virtual void setEmotion(const char *emotionName, int loop);
	virtual void setDialog(const char *content);
	virtual void setDialogDisplay(const char* content);
	virtual void setAction(const char *actionName);
	virtual void setAction(const char *actionName, int loop);
	virtual void setRotation(float fRotation);
	virtual void rotateBy(float fRotation);
	virtual void moveBy(float height);
	virtual void rotateInterval(float fRotation, float speed);
	virtual void setFlipX(bool isFlip);
	virtual void setFlipY(bool isFlip);
	virtual void setTouchEnabled(bool isEnabled);
	virtual void setOrigAngle(float angle);

	virtual float getProcess();
	virtual float getRotation();
	virtual float getHeight();
	virtual float getRotateRate();
	virtual float getOwnAngle();
	virtual float getOrigAngle();
	virtual bool getTouchEnabled();
	virtual CCRect boundingBox();

	virtual void actionComplete(CCArmature* armature, MovementEventType type, const char* name);
	virtual void emotionComplete(CCArmature* armature, MovementEventType type, const char* name);
	virtual void tapActor();
	virtual void addItem(const char* resName);
	virtual void delItem();
	virtual void delAllItem();
	virtual int getItemCount();
	virtual void showNumber(const char* number, float height, const ccColor3B& color);
	virtual void clearNumber(CCNode* label);

	virtual void removeFromParentAndCleanup(bool cleanup);
	virtual void cleanup(void);

	void showRect(float width);

	CCArmature* getArmature();

	virtual void setPointTotalCount(int count);
	virtual int getPointTotalCount();

	virtual void setPointCount(int count);
	virtual int getPointCount();
	virtual ActorType getType();

	virtual CCObject* copy();

protected:
	const char* m_imgName;
	ActorType m_type;
	float m_radius;
	float m_rotateRate;
	float m_ownAngle;
	bool m_touchEnabled;
	CCArmature* m_armature;
	int m_scriptHandler;
	CCArmature* m_emotion;
	float m_emotionPosY;
	CCLabelTTF* m_dialog;
	CCScale9Sprite* m_dialogBG;
	CCSprite* m_dialogArrow;
	CCArray* m_items;
	const char* m_keyName;
	float m_origAngle;

	float m_moveTargetX;
	float m_moveTargetY;
	float m_moveSpeedX;
	float m_moveSpeedY;

	CCSprite* m_rectLineL;
	CCSprite* m_rectLineR;

	int m_pointTotalCount;
	int m_pointCount;
//	float m_rotateRate;

private:
	virtual void updateRotate(float dt);
};

#endif
