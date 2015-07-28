#include "SJBattleActor.h"

SJBattleActor::SJBattleActor()
{
	m_hairOther = new string[BATTLE_BONE_HAIROTHER_COUNT];
	m_effects = CCArray::create();
	m_effects->retain();
}

SJBattleActor::~SJBattleActor()
{
	CC_SAFE_RELEASE(m_effects);
}

SJBattleActor* SJBattleActor::create(const char *name)
{
	SJBattleActor* actor = new SJBattleActor();
	if (actor && actor->init(name))
    {
        actor->autorelease();
		actor->getAnimation()->setFrameEventCallFunc(actor,frameEvent_selector(SJBattleActor::onFrameEvent));
        return actor;
    }
    CC_SAFE_DELETE(actor);
    return NULL;
}

float SJBattleActor::getPositionX()
{
	return SJArmature::getPositionX();
}

float SJBattleActor::getPositionY()
{
	return SJArmature::getPositionY();
}

float SJBattleActor::getBonePosX(const char* boneName)
{
	return getBone(boneName)->getDisplayRenderNode()->convertToWorldSpace(CCPoint(0,0)).x;
/*	CCBone* bone = getBone(boneName);
	CCPoint p = bone->getAnchorPoint();
	CCBone* pBone = bone->getParentBone();
	int x = bone->getPositionX();
	int y = bone->getPositionY();
//	return bone->getPositionX();
	if(x!=0 || y!=0)
	{
		int a = x;
	}
	return bone->getWorldInfo()->x;*/

}

float SJBattleActor::getBonePosY(const char* boneName)
{
	return SJArmature::getBone(boneName)->getPositionY();
/*	CCBone* bone = getBone(boneName);
//	return bone->getPositionY();
	return bone->getWorldInfo()->y;*/
}

void SJBattleActor::setActorFace(CCDictionary* faceInfo)
{
	m_hairFront = faceInfo->valueForKey(CUSTOM_KEY_HAIR_FRONT)->getCString();
	m_hairBack = faceInfo->valueForKey(CUSTOM_KEY_HAIR_BACK)->getCString();
	m_face = faceInfo->valueForKey(CUSTOM_KEY_FACE)->getCString();
	m_braid = faceInfo->valueForKey(CCString::createWithFormat(CUSTOM_KEY_HAIR_OTHER, 1)->getCString())->getCString();
//	m_eyebrows = faceInfo->valueForKey(CUSTOM_KEY_EYEBROWS)->getCString();
//	m_eyes = faceInfo->valueForKey(CUSTOM_KEY_EYES)->getCString();
//	m_mouth = faceInfo->valueForKey(CUSTOM_KEY_MOUTH)->getCString();
//	m_goatee = faceInfo->valueForKey(CUSTOM_KEY_GOATEE)->getCString();
	//for (int i = 1; i < BATTLE_BONE_HAIROTHER_COUNT; i++)
	//{
	//	const char* key = CCString::createWithFormat(CUSTOM_KEY_HAIR_OTHER, i)->getCString();
	//	m_hairOther[i] = faceInfo->valueForKey(key)->getCString();
	//}

	changeAPart(CUSTOM_MODULE_HAIR_FRONT, m_hairFront.c_str(), AMOUNT_BATTLE_MODULE_HAIR_FRONT);
	changeAPart(CUSTOM_MODULE_HAIR_BEISHI, m_hairBack.c_str(), AMOUNT_BATTLE_MODULE_HAIR_BACK);
	changeAPart(CUSTOM_MODULE_FACE, m_face.c_str(), AMOUNT_BATTLE_MODULE_FACE);
	changeAPart(CUSTOM_MODULE_HAIR_OTHER, m_braid.c_str(), AMOUNT_BATTLE_MODULE_HAIR_OTHER);
//	changeAPart(CUSTOM_MODULE_EYEBROWS, m_eyebrows.c_str(), AMOUNT_BATTLE_MODULE_EYEBROWS);
//	changeAPart(CUSTOM_MODULE_EYES, m_eyes.c_str(), AMOUNT_BATTLE_MODULE_EYES);
//	changeAPart(CUSTOM_MODULE_MOUTH, m_mouth.c_str(), AMOUNT_BATTLE_MODULE_MOUTH);
	//changeAPart(CUSTOM_MODULE_GOATEE, m_goatee.c_str(), AMOUNT_BATTLE_MODULE_GOATEE);
	//for (int i = 1; i < BATTLE_BONE_HAIROTHER_COUNT; i++)
	//{
	//	const char* partName = CCString::createWithFormat(CUSTOM_MODULE_HAIR_OTHER, i, "%d")->getCString();
	//	changeAPart(partName, m_hairOther[i].c_str(), AMOUNT_BATTLE_MODULE_HAIR_OTHER);
	//}
}

void SJBattleActor::changeAPart(const char* partName, const char* imgName, int count)
{
	for (int i = 0; i < count; i++)
	{
		CCString* boneName = CCString::createWithFormat(partName, i);
		//CCString* boneName = CCString::create(partName);
		CCString* skinName = CCString::createWithFormat(imgName, i);
		modifySkin(boneName->getCString(), skinName->getCString());
	}
}

void SJBattleActor::setPartsColor(CCDictionary* colorInfo)
{
	//ccColor3B hairFrontColor = convertColor((CCArray*)colorInfo->objectForKey(CUSTOM_KEY_HAIR_FRONT));
	//ccColor3B hairBackColor = convertColor((CCArray*)colorInfo->objectForKey(CUSTOM_KEY_HAIR_BACK));
	//ccColor3B eyesColor = convertColor((CCArray*)colorInfo->objectForKey(CUSTOM_KEY_EYES));

	//setAPartColor(CUSTOM_MODULE_HAIR_FRONT, hairFrontColor, AMOUNT_BATTLE_MODULE_HAIR_FRONT);
	//setAPartColor(CUSTOM_MODULE_HAIR_BACK, hairFrontColor, AMOUNT_BATTLE_MODULE_HAIR_BACK);
	//setAPartColor(CUSTOM_MODULE_EYES, hairFrontColor, AMOUNT_BATTLE_MODULE_EYES);
}

void SJBattleActor::setAPartColor(const char* partName, ccColor3B color, int count)
{
	//if (color.r > 0 && color.g > 0 && color.b > 0)
	//{
	//	for (int i = 0; i < count; i++)
	//	{
	//		CCString* boneName = CCString::createWithFormat(partName, i);
			//CCSkin* skin = getSkin(boneName->getCString());
	//		skin->setColor(color);
	//	}
	//}
}

void SJBattleActor::addEffect(SJArmature* armature)
{
	m_effects->addObject(armature);
}

void SJBattleActor::delEffect(SJArmature* armature)
{
	m_effects->removeObject(armature);
}

void SJBattleActor::runEffectsAction(CCAction* action)
{
	int count = m_effects->count();
	for (int i = 0; i < count; i++)
	{
		SJArmature* effect = (SJArmature*)m_effects->objectAtIndex(i);
		effect->runAction((CCAction*)action->copy());
	}
}

void SJBattleActor::setAction(const char *actionName)
{CCUserDefault::sharedUserDefault()->getIntegerForKey("commonlock",1);
//	getAnimation()->setAnimationScale(0.3f);
	getAnimation()->play(actionName, 0, 0, false, 0);
}

void SJBattleActor::setAction(const char *actionName, bool isLoop)
{
//	getAnimation()->setAnimationScale(0.3f);
	getAnimation()->play(actionName, 0, 0, isLoop, 0);
}

void SJBattleActor::setActionQueue(CCArray *animNames, bool isLoop)
{
	getAnimation()->playWithArray(animNames, -1, isLoop);
}

void SJBattleActor::move(float x, float y)
{
	m_obPosition.x += (m_isFlipX ? x : -x);
	m_obPosition.y += y;
    m_bTransformDirty = m_bInverseDirty = true;

	int count = m_effects->count();
	for (int i = 0; i < count; i++)
	{
		SJArmature* effect = (SJArmature*)m_effects->objectAtIndex(i);
		effect->setPositionX(effect->getPositionX() + (m_isFlipX ? x : -x));
		effect->setPositionY(effect->getPositionY() + y);
	}
}

CCNode* SJBattleActor::createNumber(const char* number, float disX, float disY, float time,int type)
{//1暴击，2重击，3重击加暴击
	CCNode*node = CCNode::create();
	string name ="";
	switch(type)
	{
	case 1:
		name = "Res/Animations/Label/baoji.png";
		break;
	case 2:
		name = "Res/Animations/Label/zhongji.png";
		break;
	case 3:
		name = "Res/Animations/Label/zhongjibaoji.png";
		break;
	case 4:
		name = "Res/Animations/Label/gedang.png";
		break;
	case 5:
		name = "Res/Animations/Label/counter.png";
		break;
	case 6:
		name = "Res/Animations/Label/lianji.png";
		break;
	case 7:
		name = "Res/Animations/Label/zhandou_dot.png";
		break;
	case 8:
		name = "Res/Animations/Label/zhandou_heal.png";
		break;
	case 9:
		name = "Res/Animations/Label/zhandou_rebound.png";
		break;
	}
	int width = 0;
	float posx = 0;
	if(name != "")
	{
		CCSprite*sprite = CCSprite::create(name.c_str());
		sprite->setAnchorPoint(ccp(0,0.5));
		node->setAnchorPoint(ccp(0,0.5));
		width += sprite->getContentSize().width; 
		posx += sprite->getContentSize().width; 
		node->addChild(sprite);
	}
	string name1 = "";//fuhao
	string name2 = "";//tupian
	int value = abs(atoi(number));
	int numberWidth = 0;
	int numberHeight = 0;
	if(atoi(number) > 0)
	{
		name1 = "Res/Animations/Label/plus.png";
		name2 = "Res/Animations/Label/sz_2.png";
		numberWidth = 38;
		numberHeight = 30;
	}	
	else
	{
		name1 = "Res/Animations/Label/reduce.png";
		name2 = "Res/Animations/Label/sz_3.png";
		numberWidth = 40;
		numberHeight = 32;
	}
	char hurt[256];
	sprintf(hurt,"%d",value);
	CCSprite*fuhao = CCSprite::create(name1.c_str());
	fuhao->setAnchorPoint(ccp(0,0.5));
	fuhao->setPositionX(posx);
	width += fuhao->getContentSize().width; 
	posx += fuhao->getContentSize().width; 
	CCLabelAtlas* label = CCLabelAtlas::create(hurt, name2.c_str(),numberWidth,numberHeight,'0');
	width += label->getContentSize().width;
	label->setPosition(ccp(posx,-16));
	int posY1 = 210;
	if(atoi(number) > 0)
	{
		posY1 = 240;
	}
	node->setPosition(getPosition() + CCPoint(-width/2, posY1));
	CCArray* actList = CCArray::create();
	CCAction* move = CCMoveBy::create(time, CCPoint(disX, disY));
	CCAction* callback = CCCallFuncN::create(this, callfuncN_selector(SJBattleActor::removeNumber));
	actList->addObject(move);
	actList->addObject(callback);
	node->addChild(fuhao);
	node->addChild(label);
	node->runAction(CCSequence::create(actList));
	return node;
}

void SJBattleActor::removeNumber(CCNode* label)
{
	label->removeFromParentAndCleanup(true);
}

void SJBattleActor::setPausePoint(float startTime, float durationTime)
{
	CCArray* actList = CCArray::create();
	CCAction* actDelay = CCDelayTime::create(startTime);
	CCAction* actPause = CCCallFunc::create(this, callfunc_selector(SJBattleActor::pauseAnimation));
	CCAction* actduration = CCDelayTime::create(durationTime);
	CCAction* actResume = CCCallFunc::create(this, callfunc_selector(SJBattleActor::unpauseAnimation));
	actList->addObject(actDelay);
	actList->addObject(actPause);
	actList->addObject(actduration);
	actList->addObject(actResume);
	this->runAction(CCSequence::create(actList));
}

void SJBattleActor::pauseAnimation()
{
	getAnimation()->pause();
}

void SJBattleActor::unpauseAnimation()
{
	getAnimation()->resume();
}

void SJBattleActor::purgeAnimRes()
{
	CCSpriteFrameCacheHelper::sharedSpriteFrameCacheHelper()->removeAnimationSpriteFrames();
}

void SJBattleActor::animationEventCallFunc(CCArmature* armature, MovementEventType eventType, const char* eventID)
{//回调是根据调用者对象的类名，此类方法不具有可继承性
	if (m_animEventCBFunc[eventType] >= 0)
	{
		CCScriptEngineManager::sharedManager()->getScriptEngine()->executeEvent(m_animEventCBFunc[eventType], "", this, "SJBattleActor");
	}
}

void SJBattleActor::registerFrameEvent(const char*eventName, int scriptHandler)
{
	if(eventName)
	m_frameEventCallBack[eventName] = scriptHandler;
	getAnimation()->setFrameEventCallFunc(this,frameEvent_selector(SJBattleActor::onFrameEvent));
}
void SJBattleActor::onFrameEvent(CCBone *bone, const char *name, int originFrameIndex, int currentFrameIndex)
{
	if (m_frameEventCallBack[name] >= 0)
	{
		CCScriptEngineManager::sharedManager()->getScriptEngine()->executeEvent(m_frameEventCallBack[name], "", this, "SJBattleActor");
	}	
}