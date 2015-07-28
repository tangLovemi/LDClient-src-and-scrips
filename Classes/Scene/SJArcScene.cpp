#include "SJArcScene.h"
#include "spine/Json.h"
SJArcScene::SJArcScene()
{
	m_sceneLength = 0;
	m_curAngle = 0;
	m_rotateSpeed = 0;
	m_actorCount = 0;
	m_isLoadingComplete = false;
	m_locateActors = CCDictionary::create();
	m_locateActors->retain();
	m_actorsOnClick = CCArray::create();
	m_actorsOnClick->retain();
	m_bIgnoreAnchorPointForPosition = false;
	m_jsonRoot = NULL;
}

SJArcScene::~SJArcScene()
{
	m_resNamesVec.clear();
	m_saveNames.clear();
	CC_SAFE_DELETE(m_locateActors);
	CC_SAFE_DELETE(m_actorsOnClick);
}

SJArcScene* SJArcScene::create()
{
	SJArcScene* scene = new SJArcScene();
	if (scene && scene->initScene())
	{
		scene->autorelease();
		return scene;
	}
	else
	{
		CC_SAFE_DELETE(scene);
		return NULL;
	}
}

bool SJArcScene::initScene()
{
	setContentSize(CCSize(SCREEN_WIDTH, SCREEN_HEIGHT));
	setAnchorPoint(CCPoint(0.5, 0.5));
	setPosition(SCREEN_CENTER_POS);
	return true;
}

void SJArcScene::loadData(const char* name)
{
	CCLog("begin load data %s",name);
	//m_isLoadingComplete = false;
	//unsigned long size = 0;
	//const char* content = (const char*)SJTxtFile::openFile(name, &size);
	//m_jsonValue.Parse<0>(content);

	//m_curAngle = 0;
	//m_sceneLength = m_jsonValue["Length"].GetDouble() / 2;
	//loadResources(m_jsonValue["Resources"]);
	//CCLog("the load file json length is %s",m_jsonValue["Length"].GetString());
	//CCLog("the load file json is %s",m_jsonValue["Resources"].GetString());
	//loadResAsync(0);

	m_isLoadingComplete = false;
	unsigned long size = 0;
	const char* content = (const char*)SJTxtFile::openFile(name, &size);
	m_jsonRoot=Json_create(content);
	Json*resources = Json_getItem(m_jsonRoot,"Resources");
	m_sceneLength = Json_getFloat(m_jsonRoot,"Length",0) / 2;
	if(resources)
	{
		int count = Json_getSize(resources);
		for(int i = 0;i<count; i++)
		{
			const char* resName = Json_getItemAt(resources,i)->name;
			m_resNames.push_back(resName);
			std::string str = "Res/Animations/Actors/";
			str.append(resName);
			m_resNamesVec.push_back(CCString::createWithFormat("%s0.png", str.c_str())->getCString());
			m_saveNames.push_back(str.append(".ExportJson"));
			//CCLog("C++ json key is%s",Json_getItemAt(resources,i)->name);
		}
	}else
	{
		CCLog("json resources is null");
	}
	delete content;
	loadResAsync(0);
}

void SJArcScene::loadResources(Value& resData)
{
	for (Value::ConstMemberIterator itr = resData.MemberonBegin(); itr != resData.MemberonEnd(); ++itr)
	{
		const char* resName = itr->name.GetString();
		CCLog("data name is %s",resName);
		m_resNames.push_back(resName);
	}
}

void SJArcScene::loadResAsync(float dt)
{
	//CCLog("data name is %s",resName);
	for(int i =0;i< m_resNames.size();i++)
	{	
		CCString* fileName = CCString::createWithFormat("Res/Animations/Actors/%s.ExportJson", m_resNames[i]);
		CCArmatureDataManager::sharedArmatureDataManager()->addArmatureFileInfo(fileName->getCString());
	}
	loadActors();
	CCDataReaderHelper::purge();
	m_isLoadingComplete = true;
	//if (!m_resNames.empty())
	//{
	//	CCString* fileName = CCString::createWithFormat("Res/Animations/Actors/%s.ExportJson", m_resNames.front());
	//	//CCLog("load actor name=%s",m_resNames.front());
	//	CCArmatureDataManager::sharedArmatureDataManager()->addArmatureFileInfoAsync(fileName->getCString(), this, schedule_selector(SJArcScene::loadResAsync));
	//	m_resNames.pop();
	//}
	//else
	//{
	//	loadActors();
	//	CCDataReaderHelper::purge();
	//	m_isLoadingComplete = true;
	//}
}

void SJArcScene::loadActors()
{
	//Value& actorList = m_jsonValue["Actors"];
	//int count = actorList.IsNull() ? 0 : actorList.Size();
	//for (int i = 0; i < count; i++)
	//{
	//	CCLog("enter loadactors");
	//	Value& data = actorList[i];
	//	const char* res = data["res"].GetString();
	//	float height = data["height"].GetDouble();
	//	float rotate = data["speedcoef"].GetDouble();
	//	float ownAngle = data["ownangle"].GetDouble();

	//	SJActor* actor = SJActor::createActor(res, height, rotate);
	//	actor->setRotation(data["angle"].GetDouble());
	//	actor->setOrigAngle(data["angle"].GetDouble());
	//	actor->setFlipX(data["flip"].GetBool());
	//	actor->setOwnAngle(ownAngle);
	//	actor->setType(data["type"].GetString());
	//	setActorName(actor, data["name"].IsNull() ? NULL : data["name"].GetString());
	//	addActor(actor, data["z"].GetInt(), m_actorCount);
	//}

	Json*array = Json_getItem(m_jsonRoot,"Actors");
	int count = Json_getSize(array);
	for(int i = 0; i < count; i++)
	{
		Json*object = Json_getItemAt(array,i);
		const char* res = Json_getString(object,"res","");
		float height = Json_getFloat(object,"height",0);
		float rotate = Json_getFloat(object,"speedcoef",0);
		float ownAngle = Json_getFloat(object,"ownangle",0);

		SJActor* actor = SJActor::createActor(res, height, rotate);
		actor->setRotation(Json_getFloat(object,"angle",0));
		actor->setOrigAngle(Json_getFloat(object,"angle",0));
		actor->setFlipX(Json_getBool(object,"flip",false));
		actor->setOwnAngle(ownAngle);
		actor->setType(Json_getString(object,"type",0));
		setActorName(actor, Json_getString(object,"name",NULL));
		addActor(actor, Json_getInt(object,"z",0), m_actorCount);
	}
	//for(int i = 0;i < m_saveNames.size();i++)
	//{		
	//	CCArmatureDataManager::sharedArmatureDataManager()->removeArmatureFileInfo(m_saveNames[i].c_str());
	//}
}

void SJArcScene::removeFromParentAndCleanup(bool cleanup)
{
	//CCTextureCache::sharedTextureCache()->removeUnusedTextures();
	//CCSpriteFrameCache::sharedSpriteFrameCache()->removeUnusedSpriteFrames();
	CCLayer::removeFromParentAndCleanup(cleanup);
}

void SJArcScene::removeAllChildrenWithCleanup(bool cleanup)
{
	CCLayer::removeAllChildrenWithCleanup(cleanup);
	m_actorCount = 0;
	m_locateActors->removeAllObjects();

	//CCArmatureDataManager::purge();
	for(int i = 0;i < m_saveNames.size();i++)
	{		
		CCArmatureDataManager::sharedArmatureDataManager()->removeArmatureFileInfo(m_saveNames[i].c_str());
	}

	for (int i = 0;i < m_resNamesVec.size();i++)
	{
		CCTextureCache::sharedTextureCache()->removeTextureForKey(m_resNamesVec[i].c_str());
	}

	CCLog("remove old scene res");
}

void SJArcScene::cleanup()
{
	//CCSpriteFrameCacheHelper::sharedSpriteFrameCacheHelper()->removeAnimationSpriteFrames();
	CCLayer::cleanup();
}

void SJArcScene::addActor(SJActor* actor, int z, int tag)
{
	addChild(actor, z, tag);
	m_actorCount++;
}

void SJArcScene::removeActor(int tag)
{
	removeChildByTag(tag);
	m_actorCount--;
}

void SJArcScene::removeActor(SJActor* actor)
{
	removeChild(actor, true);
	m_actorCount--;
}

void SJArcScene::setActorName(SJActor* actor, const char* name)
{
	if(name == NULL)
		return;
	if (strlen(name) > 0)
	{
		if (m_locateActors->objectForKey(name))
		{
			CCLog("actor name: '%s' is already exist", name);
		}
		else
		{
			actor->setKeyName(name);
			m_locateActors->setObject(actor, name);
		}
	}
}

SJActor* SJArcScene::getActorByName(const char* name)
{
	SJActor* actor = (SJActor*)m_locateActors->objectForKey(name);
	return actor;
}

CCArray* SJArcScene::getAllActorNames()
{
	CCArray* allNames = m_locateActors->allKeys();
	return allNames;
}

void SJArcScene::rotateSceneInterval(float angle, float speed)
{
	unschedule(schedule_selector(SJArcScene::updateRotate));
	m_rotateAngle = angle;
	m_rotateSpeed = speed;
	int repeat = (int)abs(m_rotateAngle/m_rotateSpeed);
	schedule(schedule_selector(SJArcScene::updateRotate), 0, repeat, 0);
}

void SJArcScene::updateRotate(float dt)
{
	if(m_rotateAngle < -0.1 || m_rotateAngle > 0.1)
	{
		float disAngle = m_rotateAngle > 0 ? m_rotateSpeed : -m_rotateSpeed;
		rotateScene(disAngle);
		m_rotateAngle = m_rotateAngle - disAngle;
	}
}

void SJArcScene::rotateScene(float angle)
{
	if ((angle < 0 && m_curAngle >= m_sceneLength) || (angle > 0 && m_curAngle <= -m_sceneLength))
	{
		return;
	}

	float oldAngle = m_curAngle;
	m_curAngle -= angle;
	if (m_curAngle > m_sceneLength)
	{
		angle = m_sceneLength - oldAngle;
		m_curAngle = m_sceneLength;
	}
	else if(m_curAngle < -m_sceneLength)
	{
		angle = m_sceneLength + oldAngle;
		m_curAngle = -m_sceneLength;
	}

	if(m_pChildren && m_pChildren->count() > 0)
	{
		CCObject* child;
		CCARRAY_FOREACH(m_pChildren, child)
		{
			SJActor* actor = (SJActor*) child;
			if (actor->getTag() >= 0)
			{
				actor->setRotation(actor->getOrigAngle() - m_curAngle);
			}
			else if(actor->getTag()<-10)
			{
				actor->rotateBy(angle);
			}
		}
	}
}

float SJArcScene::getSceneLength()
{
	return m_sceneLength;
}

float SJArcScene::getCurAngle()
{
	return m_curAngle;
}

float SJArcScene::onClick(float x, float y)
{
	double value = (x - SCREEN_CENTER_X)/(BASE_RADIUS - OFFSET_HEIGHT - (SCREEN_CENTER_Y - y));
	double angle = -CC_RADIANS_TO_DEGREES(atan(value));
	if ((angle < 0 && m_curAngle >= m_sceneLength) || (angle > 0 && m_curAngle <= -m_sceneLength))
	{
		angle = 0;
	}
	//float oldAngle = m_curAngle;
	//m_curAngle -= angle;
	//if (m_curAngle > m_sceneLength)
	//{
	//	angle = m_sceneLength - oldAngle;
	//	m_curAngle = m_sceneLength;
	//}
	//else if(m_curAngle < -m_sceneLength)
	//{
	//	angle = m_sceneLength + oldAngle;
	//	m_curAngle = -m_sceneLength;
	//}
	///////////////
	m_actorsOnClick->removeAllObjects();

	if(m_pChildren && m_pChildren->count() > 0)
	{
		CCPoint screenPosition = CCPoint(x, y);
		CCObject* child;
		CCARRAY_FOREACH(m_pChildren, child)
		{
			SJActor* actor = (SJActor*) child;
			if (actor->getTouchEnabled() == true)
			{
				if(actor->getTag() < -10)
				{
					SJCustomActor*actor = (SJCustomActor*) child;
					CCPoint pos = actor->convertToNodeSpace(screenPosition);
					if(actor->isCollision(screenPosition))
					{
						m_actorsOnClick->addObject(actor);
					}
				}else
				{
					if(actor->getType() == 1)
					{
						CCPoint pos = actor->convertToNodeSpace(screenPosition);
						CCRect rect = actor->boundingBox();
						if (rect.containsPoint(pos))
						{
							m_actorsOnClick->addObject(actor);
						}
					}
				}
			}
		}
	}
	////////////////
	//if(m_pChildren && m_pChildren->count() > 0)
	//{
	//	CCObject* child;
	//	CCARRAY_FOREACH(m_pChildren, child)
	//	{
	//		SJActor* actor = (SJActor*) child;
	//		if (actor->getTag() >= 0)
	//		{
	//			float ang = actor->getOrigAngle();
	//			actor->setRotation(actor->getOrigAngle() + m_curAngle);
	//		}
	//	}
	//}
	return angle;

}

CCArray* SJArcScene::getSelectedActors()
{
	return m_actorsOnClick;
}

void SJArcScene::onEnter()
{
	CCLayer::onEnter();
}

void SJArcScene::onExit()
{
	CCLayer::onExit();
}

bool SJArcScene::isLoadingComplete()
{
	return m_isLoadingComplete;
}