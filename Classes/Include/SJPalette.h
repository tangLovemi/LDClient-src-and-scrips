#ifndef __LuanDou__SJPalette__
#define __LuanDou__SJPalette__

#include <iostream>
#include "cocos2d.h"
#include "cocos-ext.h"

using namespace std;

USING_NS_CC;
USING_NS_CC_EXT;

class SJPalette:public CCControl
{
public:
	SJPalette();
	~SJPalette();
	//LUA FUNCTION
	static SJPalette* createPalette(const std::string& imageName);
	virtual bool initPalette(const std::string& imageName);
	void hueSliderValueChanged(CCObject * sender, CCControlEvent controlEvent);
	void colourSliderValueChanged(CCObject * sender, CCControlEvent controlEvent);
	//LUA FUNCTION
	virtual void setColor(const ccColor3B& colorValue);
	virtual void setEnabled(bool bEnabled);
protected:
	HSV m_hsv;
	CC_SYNTHESIZE_RETAIN(CCControlSaturationBrightnessPicker*, m_colourPicker, colourPicker)
	CC_SYNTHESIZE_RETAIN(CCControlHuePicker*, m_huePicker, HuePicker)
	CC_SYNTHESIZE_RETAIN(CCSprite*, m_background, Background)

	void updateControlPicker();
	void updateHueAndControlPicker();
	virtual bool ccTouchBegan(CCTouch* touch, CCEvent* pEvent);
private:

};

#endif