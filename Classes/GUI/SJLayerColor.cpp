#include "SJLayerColor.h"

SJLayerColor::SJLayerColor()
{


}

SJLayerColor::~SJLayerColor()
{

}


void SJLayerColor::onEnter()
{	
	CCTouchDispatcher * pTarget = CCDirector::sharedDirector()->getTouchDispatcher();
	pTarget->addTargetedDelegate(this,0,true);
}

void SJLayerColor:: onExit()
{	
	CCTouchDispatcher * pTarget = CCDirector::sharedDirector()->getTouchDispatcher();
	pTarget->removeDelegate(this);
}

SJLayerColor* SJLayerColor::createSJLayer(const ccColor4B& color, float width, float height)
{
	SJLayerColor * layerColor = new SJLayerColor();
	if(	layerColor && layerColor->initSJLayer(color,width,height))
	{
		layerColor->autorelease();
		return layerColor;
	}
	CC_SAFE_DELETE(layerColor);
	return NULL;

}



bool SJLayerColor::initSJLayer(const ccColor4B& color, float width, float height)
{
	if(!CCLayerColor::initWithColor(color,width,height))
	{
		return false;
	}
	return true;
}