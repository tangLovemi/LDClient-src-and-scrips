#include "TestScene.h"
#include "ChatLayer.h"

CCScene * TestScene::scene()
{
    CCScene * scene = CCScene::create();
    auto * layer = TestScene::create();
    scene->addChild(layer);
    return scene;
}

bool TestScene::init()
{
    if (!CCLayer::init())
	{
        return false;
    }
    
    ChatLayer * chatLayer = ChatLayer::createChatLayer();
    chatLayer->setPosition(ccp(0, 0));
    this->addChild(chatLayer);
    
    return true;
}