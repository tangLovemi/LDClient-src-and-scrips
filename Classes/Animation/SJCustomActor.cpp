#include "SJCustomActor.h"

SJCustomActor::SJCustomActor()
{
	//SJActor::SJActor();
	m_type = actorTypePlayer;
	m_touchEnabled = true;
	m_hairOther = new string[SCENE_BONE_HAIROTHER_COUNT];
}

SJCustomActor::~SJCustomActor()
{

}

SJCustomActor* SJCustomActor::createActor(const char *imgName, float height, float rotateRate)
{
	SJCustomActor * actor = new SJCustomActor();
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

void SJCustomActor::setActorFace(CCDictionary* faceInfo)
{
	m_hairFront = faceInfo->valueForKey(CUSTOM_KEY_HAIR_FRONT)->getCString();
	//m_hairBack = faceInfo->valueForKey(CUSTOM_KEY_HAIR_BACK)->getCString();
	m_face = faceInfo->valueForKey(CUSTOM_KEY_FACE)->getCString();
	//m_eyebrows = faceInfo->valueForKey(CUSTOM_KEY_EYEBROWS)->getCString();
	//m_eyes = faceInfo->valueForKey(CUSTOM_KEY_EYES)->getCString();
	//m_mouth = faceInfo->valueForKey(CUSTOM_KEY_MOUTH)->getCString();
	//m_goatee = faceInfo->valueForKey(CUSTOM_KEY_GOATEE)->getCString();
	/*for (int i = 1; i <= SCENE_BONE_HAIROTHER_COUNT; i++)
	{
		const char* key = CCString::createWithFormat(CUSTOM_KEY_HAIR_OTHER, i)->getCString();
		m_hairOther[i] = faceInfo->valueForKey(key)->getCString();
	}*/
	
	m_braid = faceInfo->valueForKey(CCString::createWithFormat(CUSTOM_KEY_HAIR_OTHER, 1)->getCString())->getCString();

	changeAPart(CUSTOM_MODULE_HAIR_FRONT, m_hairFront.c_str(), AMOUNT_SCENE_MODULE_HAIR_FRONT);
	//changeAPart(CUSTOM_MODULE_HAIR_BACK, m_hairBack.c_str(), AMOUNT_SCENE_MODULE_HAIR_BACK);
	changeAPart(CUSTOM_MODULE_FACE, m_face.c_str(), AMOUNT_SCENE_MODULE_FACE);
	//changeAPart(CUSTOM_MODULE_EYEBROWS, m_eyebrows.c_str(), AMOUNT_SCENE_MODULE_EYEBROWS);
	//changeAPart(CUSTOM_MODULE_EYES, m_eyes.c_str(), AMOUNT_SCENE_MODULE_EYES);
	//changeAPart(CUSTOM_MODULE_MOUTH, m_mouth.c_str(), AMOUNT_SCENE_MODULE_MOUTH);
	//changeAPart(CUSTOM_MODULE_GOATEE, m_goatee.c_str(), AMOUNT_SCENE_MODULE_GOATEE);
	changeAPart(CUSTOM_MODULE_HAIR_OTHER, m_braid.c_str(), AMOUNT_SCENE_MODULE_FACE);



	/*for (int i = 1; i <= SCENE_BONE_HAIROTHER_COUNT; i++)
	{
		const char* partName = CCString::createWithFormat(CUSTOM_MODULE_HAIR_OTHER, i, "%d")->getCString();
		changeAPart(partName, m_hairOther[i].c_str(), AMOUNT_SCENE_MODULE_HAIR_OTHER);
	}*/
}

void SJCustomActor::changeAPart(const char* partName, const char* imgName, int count)
{
	for (int i = 0; i < count; i++)
	{
		CCString* boneName = CCString::createWithFormat(partName, i);
		CCString* skinName = CCString::createWithFormat(imgName, i);
		m_armature->modifySkin(boneName->getCString(), skinName->getCString());
	}
}

void SJCustomActor::setPartsColor(CCDictionary* colorInfo)
{
	ccColor3B hairFrontColor = SJArmature::convertColor((CCArray*)colorInfo->objectForKey(CUSTOM_KEY_HAIR_FRONT));
	ccColor3B hairBackColor = SJArmature::convertColor((CCArray*)colorInfo->objectForKey(CUSTOM_KEY_HAIR_BACK));
	ccColor3B eyesColor = SJArmature::convertColor((CCArray*)colorInfo->objectForKey(CUSTOM_KEY_EYES));

	setAPartColor(CUSTOM_MODULE_HAIR_FRONT, hairFrontColor, AMOUNT_SCENE_MODULE_HAIR_FRONT);
	setAPartColor(CUSTOM_MODULE_HAIR_BACK, hairFrontColor, AMOUNT_SCENE_MODULE_HAIR_BACK);
	setAPartColor(CUSTOM_MODULE_EYES, hairFrontColor, AMOUNT_SCENE_MODULE_EYES);
}

void SJCustomActor::setAPartColor(const char* partName, ccColor3B color, int count)
{
	for (int i = 0; i < count; i++)
	{
		CCString* boneName = CCString::createWithFormat(partName, i);
		CCSkin* skin = m_armature->getSkin(boneName->getCString());
		skin->setColor(color);
	}
}

void SJCustomActor::createImage(const char *imgName)
{
	m_armature = SJArmature::create(imgName);
	m_armature->getAnimation()->play("stand", 0, 0, -1, 0);
	m_armature->setPosition(CCPoint(5, m_radius));
	m_armature->getAnimation()->setMovementEventCallFunc(this, movementEvent_selector(SJActor::actionComplete));
	addChild(m_armature);
	m_emotionPosY = m_armature->boundingBox().size.height + m_radius;
}

void SJCustomActor::setAction(const char *actionName)
{
	//m_armature->getAnimation()->setAnimationScale(0.3f);
	m_armature->getAnimation()->play(actionName, 0, 0, -1, 0);
}

void SJCustomActor::setAction(const char *actionName, int loop)
{
	//m_armature->getAnimation()->setAnimationScale(0.3f);
	m_armature->getAnimation()->play(actionName, 0, 0, loop, 0);
}

SJArmature* SJCustomActor::getArmature()
{
	return m_armature;
}

CCRect SJCustomActor::boundingBox()
{
	return m_armature->boundingBox();
}

void SJCustomActor::cleanup()
{
	m_armature->getAnimation()->stopMovementEventCallFunc();
	//CCLayer::cleanup();
}

CCObject* SJCustomActor::copy()
{
	return SJActor::copy();
}


bool SJCustomActor::isCollision(CCPoint point)
{
	CCDictElement *element = NULL ;  
	if(getArmature() == NULL)
	{
		return false;
	}
	CCBone *bone = static_cast < CCBone*>(m_armature->getBone("cross_0"));  
	CCPoint pos = bone->convertToNodeSpace(point);
	CCArray *bodyList = bone->getColliderBodyList();
	CCObject *object = NULL ;  
	CCARRAY_FOREACH (bodyList, object)  
	{  
		ColliderBody *body = static_cast < ColliderBody*>(object);  
		CCContourData *data = body->getContourData();
		CCArray &vertexList = data->vertexList;  
		float  minx, miny, maxx, maxy = 0;   
		int  length = vertexList.count();   
		for  ( int  i = 0; i<length; i++) 
		{  
			CCContourVertex2 *vertex = static_cast < CCContourVertex2*>(vertexList.objectAtIndex(i));  
			if  (i == 0)   
			{  
				minx = maxx = vertex->x;  
				miny = maxy = vertex->y;  
			}else    
			{  
				minx = vertex->x < minx ? vertex->x : minx;  
				miny = vertex->y < miny ? vertex->y : miny;  
				maxx = vertex->x > maxx ? vertex->x : maxx;  
				maxy = vertex->y > maxy ? vertex->y : maxy;  
			}  
		}  
		CCRect temp = CCRectMake (minx, miny, maxx - minx, maxy - miny);  

		if  (temp.containsPoint(pos))   
		{  
			return true;  
		}  
	}  
	return false;
}