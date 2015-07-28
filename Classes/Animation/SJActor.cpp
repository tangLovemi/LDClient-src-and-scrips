#include "SJActor.h"
#include "CCLuaEngine.h"

SJActor::SJActor()
{
	m_radius = 0;
	m_imgName = 0;
	m_type = actorTypeObject;
	m_scriptHandler = 0;
	m_emotionPosY = 0;
	m_rotateRate = 1;
	m_touchEnabled = false;
	m_armature = NULL;
	m_emotion = NULL;
	m_dialog = NULL;
	m_dialogBG = NULL;
	m_dialogArrow = NULL;
	m_keyName = NULL; 
	m_items = CCArray::create();
	m_items->retain();
	m_bIgnoreAnchorPointForPosition = false;

	m_moveTargetX = 0;
	m_moveTargetY = 0;
	m_moveSpeedX = 0;
	m_moveSpeedY = 0;
	m_origAngle = 0;
}

SJActor::~SJActor()
{
	m_armature = NULL;
	m_emotion = NULL;
	m_dialog = NULL;
	m_dialogBG = NULL;
	m_dialogArrow = NULL;
	CC_SAFE_RELEASE(m_items);
}

SJActor* SJActor::createActor(const char *imgName, float height, float rotateRate)
{
	SJActor * actor = new SJActor();
    if (actor && actor->init(imgName, height, rotateRate))
    {
        actor->autorelease();
		return actor;
    }
    else
    {
        CC_SAFE_DELETE(actor);
    }
	return NULL;
}

bool SJActor::init(const char *imgName, float height, float rotateRate)
{
	if (CCLayer::init())
	{
		setName(imgName);
		setRadius(height);
		setRotateRate(rotateRate);
		createImage(imgName);
		setAnchorPoint(CCPoint(0.5, 0));
		setPosition(CCPoint(SCREEN_CENTER_X, -(BASE_RADIUS - OFFSET_HEIGHT)));
		setContentSize(CCSize(10, BASE_RADIUS));
		return true;
	}
	return false;
}

void SJActor::registerScriptHandler(int handler)
{
	m_scriptHandler = handler;
}

void SJActor::unregisterScriptHandler()
{
	m_scriptHandler = 0;
}
	
void SJActor::setName(const char *imgName)
{
	m_imgName = imgName;
}
	
void SJActor::setRadius(float radius)
{
	m_radius = BASE_RADIUS + radius;
}

void SJActor::setHeight(float height)
{
	setRadius(height);
	m_armature->setPosition(CCPoint(5, m_radius));
}

void SJActor::setRotateRate(float rotateRate)
{
	m_rotateRate = rotateRate;
}

void SJActor::setOwnAngle(float angle)
{
	m_ownAngle = angle;
	bool isFlip = getScaleX() > 0 ? false : true;
	angle = isFlip ? -angle : angle;
	m_armature->setRotation(angle);
}

void SJActor::setType(const char* type)
{
	if (strcmp(type, "object") == 0)
	{
		m_type = actorTypeObject;
	}
	else if (strcmp(type, "player") == 0)
	{
		m_type = actorTypePlayer;
	}else if(strcmp(type, "npc") == 0)
	{
		m_type = actorTypeNpc;
		m_touchEnabled = true;
	}
}

ActorType SJActor::getType()
{
	return m_type;
}

void SJActor::createTimer(float time, int handler)
{
	CCDelayTime* delay = CCDelayTime::create(time);
	CCCallFuncN* call = CCCallFuncN::create(handler);
	CCSequence* seq = CCSequence::create(delay, call, NULL);
	runAction(seq);
}

CCArmature* SJActor::getArmature()
{
	return m_armature;
}

void SJActor::createImage(const char *imgName)
{
	CCArmature *armature = CCArmature::create(imgName);
	armature->getAnimation()->play("stand", 0, 0, -1, 0);
	armature->setPosition(CCPoint(5, m_radius));
	armature->getAnimation()->setMovementEventCallFunc(this, movementEvent_selector(SJActor::actionComplete));
	addChild(armature);
	m_armature = armature;
	m_emotionPosY = m_armature->boundingBox().size.height + m_radius;
}

void SJActor::setKeyName(const char* key)
{
	ACTOR_COPY_STRING(name, key);
	m_keyName = name;
}

const char* SJActor::getKeyName()
{
	return m_keyName;
}

void SJActor::setEmotion(const char *emotionName, int loop)
{
	if (m_emotion)
	{
		m_emotion->removeFromParentAndCleanup(true);
		m_emotion = NULL;
	}
	if (strcmp(emotionName, "") == 0)
	{		
		return;
	}
	CCArmature *armature = CCArmature::create(emotionName);
	armature->setPosition(CCPoint(0, m_emotionPosY-50));
	armature->setAnchorPoint(CCPoint(0.5, 0));
	armature->getAnimation()->play("stand", 0, 0, loop, 0);
	if (m_fScaleX < 0)
	{
		armature->setScaleX(m_fScaleX);
	}
	addChild(armature, 1);
	m_emotion = armature;
}

void SJActor::setDialog(const char *content)
{
	if (m_dialog)
	{
		m_dialog->removeFromParentAndCleanup(true);
	}
	if (strcmp(content, "") == 0)
	{
		return;
	}
	m_dialog = CCLabelTTF::create(content, "Marker Felt", DIALOG_FONT_SIZE, CCSize(400, 0), kCCTextAlignmentLeft);
	m_dialog->setPosition(CCPoint(-15, m_emotionPosY));
	m_dialog->setAnchorPoint(CCPoint(0, 0));
	m_dialog->setColor(ccBLACK);
	if (!m_dialogBG)
	{
		m_dialogBG = CCScale9Sprite::create("Res/Image/dialog_frame.png");
		m_dialogArrow = CCSprite::create("Res/Image/dialog_arrow.png");
		//addChild(m_dialogBG, 2);
		//addChild(m_dialogArrow, 2);
	}
	CCSize bgSize = m_dialog->getContentSize() + CCSize(50, 50);
	m_dialogBG->setPosition(CCPoint(5, m_emotionPosY - 25));
	m_dialogBG->setAnchorPoint(CCPoint(0.5, 0));
	m_dialogBG->setContentSize(bgSize);
	m_dialogArrow->setPosition(CCPoint(5, m_emotionPosY - 20));
	m_dialogArrow->setAnchorPoint(CCPoint(0.5, 1));
	if (m_fScaleX < 0)
	{
		m_dialog->setFlipX(true);
	}
	addChild(m_dialog, 2);
}

void SJActor::setDialogDisplay(const char* content)
{
	m_dialog->setString(content);
}

void SJActor::setAction(const char *actionName)
{
//	m_armature->getAnimation()->setAnimationScale(0.1f);
	m_armature->getAnimation()->play(actionName, 0, 0, -1, 0);
}

void SJActor::setAction(const char *actionName, int loop)
{
	m_armature->getAnimation()->play(actionName, 0, 0, loop, 0);
}

void SJActor::setRotation(float fRotation)
{
	CCLayer::setRotation(fRotation);
}

float SJActor::getOrigAngle()
{
	return m_origAngle;
}

void SJActor::rotateBy(float fRotation)
{
	float angle = getRotation();
	CCLayer::setRotation(angle + fRotation * m_rotateRate);
}

void SJActor::moveBy(float height)
{
	m_radius += height;
	m_armature->setPosition(CCPoint(5, m_radius));
}

void SJActor::rotateInterval(float angle, float speed)
{
	unschedule(schedule_selector(SJActor::updateRotate));
	m_moveTargetX = angle * m_rotateRate;
	m_moveSpeedX = speed * m_rotateRate;
	int repeat = (int) abs(m_moveTargetX / m_moveSpeedX);
	schedule(schedule_selector(SJActor::updateRotate), 0, repeat, 0);
}

void SJActor::setFlipX(bool isFlip)
{
	setScaleX(isFlip? -1 : 1);
	if (isFlip)
	{
		if (m_emotion)
		{
			m_emotion->setScaleX(-1);
		}
		if (m_dialog)
		{
			m_dialog->setFlipX(true);
			m_dialogBG->setScaleX(-1);
		}
	}
}

void SJActor::setFlipY(bool isFlip)
{
	setScaleY(isFlip? -1 : 1);
	if (isFlip)
	{
		if (m_emotion)
		{
			m_emotion->setScaleY(-1);
		}
		if (m_dialog)
		{
			m_dialog->setFlipY(true);
			m_dialogBG->setScaleY(-1);
		}
	}
}

void SJActor::setTouchEnabled(bool isEnabled)
{
	m_touchEnabled = isEnabled;
}

float SJActor::getProcess()
{
	float process = m_armature->getAnimation()->getCurrentPercent();
	return process;
}

float SJActor::getRotation()
{
	return CCLayer::getRotation();
}

float SJActor::getHeight()
{
	return (m_radius - BASE_RADIUS);
}

float SJActor::getRotateRate()
{
	return m_rotateRate;
}

float SJActor::getOwnAngle()
{
	return m_ownAngle;
}

bool SJActor::getTouchEnabled()
{
	return m_touchEnabled;
}

CCRect SJActor::boundingBox()
{

	return m_armature->boundingBox();
}

void SJActor::actionComplete(CCArmature* armature, MovementEventType type, const char* name)
{
	if (type == COMPLETE)
	{
		if (m_scriptHandler)
		{
			CCScriptEngineManager::sharedManager()->getScriptEngine()->executeEvent(m_scriptHandler, "anim_end", this, "Actor");
		}
	}
}

void SJActor::emotionComplete(CCArmature* armature, MovementEventType type, const char* name)
{
	if (type == COMPLETE)
	{
		m_emotion->removeFromParentAndCleanup(true);
		m_emotion = NULL;
	}
}

void SJActor::tapActor()
{
	
}

void SJActor::addItem(const char* resName)
{
	int count = m_items->count();
	CCArmature *armature = CCArmature::create(resName);
	armature->setPosition(CCPoint(5, BASE_RADIUS + count * 50));
	armature->setAnchorPoint(CCPoint(1, 0));
	armature->getAnimation()->play("stand", 0, 0, 0, 0);
	m_items->addObject(armature);
	addChild(armature, -1);
}

void SJActor::delItem()
{
	if (m_items->count() == 0)
	{
		return;
	}
	CCNode* obj = (CCNode*)m_items->lastObject();
	obj->removeFromParentAndCleanup(true);
	m_items->removeObject(obj);
}

void SJActor::delAllItem()
{
	int count = m_items->count();
	if (count == 0)
	{
		return;
	}
	for (int i = 0; i < count; i++)
	{
		CCNode* obj = (CCNode*)m_items->objectAtIndex(i);
		obj->removeFromParentAndCleanup(true);
	}
	m_items->removeAllObjects();
}

int SJActor::getItemCount()
{
	return m_items->count();
}

void SJActor::showNumber(const char* number, float height, const ccColor3B& color)
{
	CCLabelBMFont* label = CCLabelBMFont::create(number, "fonts/number.fnt");
	label->setPosition(CCPoint(5, m_radius + height));
	label->setAnchorPoint(CCPoint(0.5, 0));
	label->setColor(color);
	label->setScaleX(m_fScaleX);
	addChild(label, 3);
	CCMoveBy* move = CCMoveBy::create(1, CCPoint(0, 400));
	CCCallFuncN* call = CCCallFuncN::create(label, callfuncN_selector(SJActor::clearNumber));
	CCSequence* seq = CCSequence::create(move, call, NULL);
	label->runAction(seq);
}

void SJActor::clearNumber(CCNode* label)
{
	label->removeFromParentAndCleanup(true);
}

void SJActor::removeFromParentAndCleanup(bool cleanup)
{
	CCLayer::removeFromParentAndCleanup(cleanup);
}

void SJActor::cleanup()
{
	m_armature->getAnimation()->stopMovementEventCallFunc();
	CCLayer::cleanup();
}

void SJActor::updateRotate(float dt)
{
	float disAngle = abs(m_moveTargetX);

	if (disAngle > 0)
	{
		float angle = disAngle < m_moveSpeedX ? disAngle : m_moveSpeedX;
		rotateBy(m_moveTargetX > 0 ? angle : -angle);
	}
}

void SJActor::setOrigAngle(float angle)
{
	m_origAngle = angle;
}

void SJActor::showRect(float width)
{
#ifdef SHOW_RECT
	m_rectLineL = CCSprite::create("Res/Images/line.png");
	m_rectLineR = CCSprite::create("Res/Images/line.png");
	m_rectLineL->setPosition(CCPoint(5, 0));
	m_rectLineR->setPosition(CCPoint(5, 0));
	m_rectLineL->setAnchorPoint(CCPoint(0.5, 0));
	m_rectLineR->setAnchorPoint(CCPoint(0.5, 0));
	m_rectLineL->setScaleY(35);
	m_rectLineR->setScaleY(35);
	m_rectLineL->setRotation(-(width / 2));
	m_rectLineR->setRotation((width / 2));
	addChild(m_rectLineL, 100);
	addChild(m_rectLineR, 100);
#endif
}


void SJActor::setPointTotalCount(int count)
{
	this->m_pointTotalCount = count;
}
int SJActor::getPointTotalCount()
{
	return this->m_pointTotalCount;
}
void SJActor::setPointCount(int count)
{
	this->m_pointCount = count;
}
int SJActor::getPointCount()
{
	return this->m_pointCount;
}

CCObject* SJActor::copy()
{
	return CCLayer::copy();
}

