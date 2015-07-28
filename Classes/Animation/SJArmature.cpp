#include "SJArmature.h"

SJArmature::SJArmature()
{
	m_isFlipX = false;
	m_isFlipY = false;
	m_animEventCBCount = 0;
	m_callbackInfo = NULL;
	for (int i = 0; i < AMOUNT_ANIM_EVENT_TYPE; i++)
	{
		m_animEventCBFunc[i] = -1;
	}
}

SJArmature::~SJArmature()
{

}

SJArmature* SJArmature::create(const char *name)
{
	SJArmature *armature = new SJArmature();
    if (armature && armature->init(name))
    {
        armature->autorelease();
        return armature;
    }
    CC_SAFE_DELETE(armature);
    return NULL;
}

void SJArmature::setFlipX(bool isFlip)
{
	if (m_isFlipX != isFlip)
	{
		m_isFlipX = isFlip;
		setScaleX(m_isFlipX ? -1 : 1);
	}
}

void SJArmature::setFlipY(bool isFlip)
{
	if (m_isFlipY != isFlip)
	{
		m_isFlipY = isFlip;
		setScaleY(m_isFlipY ? -1 : 1);
	}
}

bool SJArmature::getFlipX()
{
	return m_isFlipX;
}

bool SJArmature::getFlipY()
{
	return m_isFlipY;
}

CCSkin* SJArmature::getSkin(const char* boneName)
{
	CCDisplayManager* displayManager = getBone(boneName)->getDisplayManager();
	CCDecorativeDisplay* display = (CCDecorativeDisplay*)displayManager->getDecorativeDisplayList()->objectAtIndex(0);
	return (CCSkin*)display->getDisplay();
}

void SJArmature::modifySkin(const char* boneName, const char* imgName)
{
	CCBone* bone = getBone(boneName);
	//bone->setColor(ccc3(255,0,0));
	CCSkin* newSkin = CCSkin::createWithSpriteFrameName(imgName);
	/*string path = "Res/Modules/Scene/Male/";
	path.append(imgName);
	CCSkin* newSkin = CCSkin::create(path.c_str());*/
	
	//newSkin->setColor(ccc3(255,0,0));
	bone->addDisplay(newSkin, 0);
}

void SJArmature::addArmatureToBone(const char* boneName, int index, SJArmature* armature)
{
	CCBone* parentBone = (CCBone*)getBone(boneName)->getChildren()->objectAtIndex(0);
	parentBone->getName();
	CCBone* childBone = (CCBone*)parentBone->getChildren()->objectAtIndex(index);
	childBone->getName();
	childBone->addDisplay(armature, 0);
}

void SJArmature::removeArmatureFromBone(const char* boneName, int index)
{
	CCBone* parentBone = (CCBone*)getBone(boneName)->getChildren()->objectAtIndex(0);
	CCBone* childBone = (CCBone*)parentBone->getChildren()->objectAtIndex(index);
	CCSkin* skin = CCSkin::create();
	childBone->addDisplay(skin, 0);
}

void SJArmature::registerAnimEvent(int eventType, int scriptHandler)
{
	if (m_animEventCBFunc[eventType] < 0)
	{
		if (m_animEventCBCount == 0)
		{
			getAnimation()->setMovementEventCallFunc(this, movementEvent_selector(SJArmature::animationEventCallFunc));
		}
		m_animEventCBCount++;
	}
	m_animEventCBFunc[eventType] = scriptHandler;
}

void SJArmature::registerAnimEvent(int eventType, int scriptHandler, const char* text)
{
	m_callbackInfo = CCString::create(text);
	m_callbackInfo->retain();
	registerAnimEvent(eventType, scriptHandler);
}

void SJArmature::unregisterAnimEvent(int eventType)
{
	if (m_animEventCBFunc[eventType] >= 0)
	{
		m_animEventCBCount--;
		if (m_animEventCBCount == 0)
		{
			getAnimation()->stopMovementEventCallFunc();
		}
	}
	m_animEventCBFunc[eventType] = -1;
}

void SJArmature::animationEventCallFunc(CCArmature* armature, MovementEventType eventType, const char* eventID)
{
	if (m_animEventCBFunc[eventType] >= 0)
	{
		CCScriptEngineManager::sharedManager()->getScriptEngine()->executeEvent(m_animEventCBFunc[eventType], "", this, "SJArmature");
	}
}

ccColor3B SJArmature::convertColor(CCArray* rgb)
{
	if (rgb)
	{
		GLubyte red = ((CCInteger*)rgb->objectAtIndex(0))->getValue();
		GLubyte green = ((CCInteger*)rgb->objectAtIndex(1))->getValue();
		GLubyte blue = ((CCInteger*)rgb->objectAtIndex(2))->getValue();
		ccColor3B color = ccc3(red, green, blue);
		return ccc3(red, green, blue);
	}
	else
	{
		return ccc3(0, 0, 0);
	}
}

void SJArmature::removeFromParentAndCleanup(bool cleanup)
{
	CCArmature::removeFromParentAndCleanup(cleanup);
}
void SJArmature::registerFrameEvent(const char*eventName, int scriptHandler)
{
	if(eventName)
		m_frameEventCallBack[eventName] = scriptHandler;
	getAnimation()->setFrameEventCallFunc(this,frameEvent_selector(SJArmature::onFrameEvent));
}
void SJArmature::onFrameEvent(CCBone *bone, const char *name, int originFrameIndex, int currentFrameIndex)
{
	if (m_frameEventCallBack[name] >= 0)
	{
		CCScriptEngineManager::sharedManager()->getScriptEngine()->executeEvent(m_frameEventCallBack[name], "", this, "SJArmature");
	}	
}