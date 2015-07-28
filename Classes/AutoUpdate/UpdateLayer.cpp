#include "UpdateLayer.h"
#include "AttDefine.h"
#include "../SJConfig.h"
extern "C" {
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
};
UpdateLayer::UpdateLayer(void)
{

}


UpdateLayer::~UpdateLayer(void)
{
}

bool UpdateLayer::init()
{
	if(!CCLayer::init())
		return false;
	CCSprite* bg = CCSprite::create("Res/Update/progress_bg.png");
	CCSprite* tActor = CCSprite::create("Res/Update/progress_tile.png");
	bg->setPosition(ccp(SCREEN_WIDTH/2,200));
	m_BarProgress = CCProgressTimer::create(tActor);
	m_BarProgress->setAnchorPoint(CCPointZero);
	m_BarProgress->setPosition(bg->getPosition().x - tActor->getContentSize().width/2, bg->getPosition().y-tActor->getContentSize().height/2);
	m_BarProgress->setType(kCCProgressTimerTypeBar);
	m_BarProgress->setMidpoint(ccp(0, 0));
	m_BarProgress->setBarChangeRate(ccp(1, 0));
	m_BarProgress->setPercentage(0);
	m_BarProgress->setVisible(false);
	this->addChild(m_BarProgress);
	this->addChild(bg);
	m_countLabel = CCLabelTTF::create("","",25,CCSize(100,50),kCCTextAlignmentLeft);
	m_countLabel->setAnchorPoint(ccp(0,0.5));
	m_countLabel->setPosition(ccp(bg->getPosition().x+bg->getContentSize().width,bg->getPosition().y));
	this->addChild(m_countLabel);
	AutoUpdate::getInstance()->AutoUpdateVersion(this,updatecallback_selector(UpdateLayer::UpdateState));
	schedule(schedule_selector(UpdateLayer::Update));
	return true;
}
UpdateLayer* UpdateLayer::create()
{
	UpdateLayer * layer = new UpdateLayer();
	if (layer && layer->init())
	{
		layer->autorelease();
		return layer;
	}
	CC_SAFE_DELETE(layer);
	return NULL;
}
void UpdateLayer::UpdateState(UpdateUnit unit)
{
	if(m_queue.size()>5)
		return;
	m_queue.push(unit);
}
void UpdateLayer::Update( float dt )
{
	if ( false == m_queue.empty() )
	{
		UpdateUnit unit = m_queue.front();
		m_queue.pop();

		switch( unit.type )
		{
		case UPDATE_STATE_NONE://不需要更新
			
			break;
		case UPDATE_STATE_END://更新结束
			callLuaFunction("Update/UpdateScene.lua","UpdateAuto",UPDATE_STATE_END);
			break;
		case UPDATE_STATE_DOWNLOAD://更新中
			m_BarProgress->setVisible(true);
			m_BarProgress->setPercentage(unit.para_0/unit.para_1*100);
			char name[128];
			sprintf(name,"%d/%d", (int)unit.para_2,(int)unit.para_3);
			m_countLabel->setString(name);
			//CCLOG("percentage=%d",unit.para_0);
			break;
		case UPDATE_STATE_WRITE://写版本
			{
				char name[128];
				sprintf(name,"%d",(int)unit.para_0);
				CCUserDefault::sharedUserDefault()->setStringForKey(KEY_OF_VERSION, name);
				CCUserDefault::sharedUserDefault()->flush();
			}
			break;
		case UPDATE_STATE_FAILED://更新失败
			callLuaFunction("UpdateScene","Update",UPDATE_STATE_FAILED);
			break;
		case UPDATE_STATE_ERROR://更新发生错误
			callLuaFunction("UpdateScene","Update",UPDATE_STATE_ERROR);
			break;
		default:
			break;
		}
	}
}

void UpdateLayer::callLuaFunction(const char* luaFileName,const char* functionName, int state){
    lua_State*  ls = CCLuaEngine::defaultEngine()->getLuaStack()->getLuaState();
	////luaL_openlibs(ls);
	string dd = CCFileUtils::sharedFileUtils()->fullPathForFilename(luaFileName).c_str();
    int isOpen = luaL_dofile(ls, CCFileUtils::sharedFileUtils()->fullPathForFilename(luaFileName).c_str());
    if(isOpen!=0){
        CCLOG("Open Lua Error: %i", isOpen);
    }
 
    lua_getglobal(ls, functionName);
    lua_pushnumber(ls, state);
 
    /*
     lua_call
     第一个参数:函数的参数个数
     第二个参数:函数返回值个数
     */
    int error = lua_pcall(ls, 1, 0, 0);
	if(error!=0){
		CCLOG("Run Lua Error: %s", lua_tostring(ls, -1));
	}
    //const char* iResult = lua_tostring(ls, -1);
 
    //return iResult;
}

