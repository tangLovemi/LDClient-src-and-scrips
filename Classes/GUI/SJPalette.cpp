#include "SJPalette.h"

SJPalette::SJPalette()
	: m_colourPicker(NULL)
	, m_huePicker(NULL)
	, m_background(NULL)
{
}


SJPalette::~SJPalette()
{
	if (m_background)
	{
		m_background->removeFromParentAndCleanup(true);
	}

	if (m_huePicker)
	{
		m_huePicker->removeFromParentAndCleanup(true);
	}

	if (m_colourPicker)
	{
		m_colourPicker->removeFromParentAndCleanup(true);
	}

	m_background     = NULL;
	m_huePicker      = NULL;
	m_colourPicker   = NULL;
}

SJPalette* SJPalette:: createPalette(const std::string& imageName)
{
	SJPalette * picker = new SJPalette();
	if(	picker && picker->initPalette(imageName))
	{
		picker->autorelease();
		return picker;
	}
	CC_SAFE_DELETE(picker);
	return NULL;
}
bool SJPalette:: initPalette(const std::string& imageName)
{
	if(CCControl::init())
	{
		string plistStr = ".plist";
		string plistPath = imageName + plistStr;

		string pngStr = ".png";
		string imagePath = imageName + pngStr;

		setTouchEnabled(true);

		CCSpriteFrameCache::sharedSpriteFrameCache()->addSpriteFramesWithFile(plistPath.c_str());

		CCSpriteBatchNode *spriteSheet  = CCSpriteBatchNode::create(imagePath.c_str());
		addChild(spriteSheet);

		m_hsv.h = 0;
		m_hsv.s = 0;
		m_hsv.v = 0;

		// Add image
		m_background=CCControlUtils::addSpriteToTargetWithPosAndAnchor("menuColourPanelBackground.png", spriteSheet, CCPointZero, ccp(0.5f, 0.5f));
		CC_SAFE_RETAIN(m_background);

		CCPoint backgroundPointZero = ccpSub(m_background->getPosition(), ccp (m_background->getContentSize().width / 2, m_background->getContentSize().height / 2));

		// Setup panels
		float hueShift                = 8;
		float colourShift             = 28;

		m_huePicker = new CCControlHuePicker();
		m_huePicker->initWithTargetAndPos(spriteSheet, ccp(backgroundPointZero.x + hueShift, backgroundPointZero.y + hueShift));
		m_colourPicker = new CCControlSaturationBrightnessPicker();
		m_colourPicker->initWithTargetAndPos(spriteSheet, ccp(backgroundPointZero.x + colourShift, backgroundPointZero.y + colourShift));

		// Setup events
		m_huePicker->addTargetWithActionForControlEvents(this, cccontrol_selector(SJPalette::hueSliderValueChanged), CCControlEventValueChanged);
		m_colourPicker->addTargetWithActionForControlEvents(this, cccontrol_selector(SJPalette::colourSliderValueChanged), CCControlEventValueChanged);

		// Set defaults
		updateHueAndControlPicker();
		addChild(m_huePicker);
		addChild(m_colourPicker);

		// Set content size
		setContentSize(m_background->getContentSize());

		setEnabled(true);
		return true;
	}
	else
		return false;

	
}

void SJPalette::setColor(const ccColor3B& color)
{
	// XXX fixed me if not correct
	CCControl::setColor(color);

	RGBA rgba;
	rgba.r      = color.r / 255.0f;
	rgba.g      = color.g / 255.0f;
	rgba.b      = color.b / 255.0f;
	rgba.a      = 1.0f;

	m_hsv=CCControlUtils::HSVfromRGB(rgba);
	updateHueAndControlPicker();
}

void SJPalette::setEnabled(bool enabled)
{
	CCControl::setEnabled(enabled);
	if (m_huePicker != NULL)
	{
		m_huePicker->setEnabled(enabled);
	}
	if (m_colourPicker)
	{
		m_colourPicker->setEnabled(enabled);
	} 
}


//need two events to prevent an infinite loop! (can't update huePicker when the huePicker triggers the callback due to CCControlEventValueChanged)
void SJPalette::updateControlPicker()
{
	m_huePicker->setHue(m_hsv.h);
	m_colourPicker->updateWithHSV(m_hsv);
}

void SJPalette::updateHueAndControlPicker()
{
	m_huePicker->setHue(m_hsv.h);
	m_colourPicker->updateWithHSV(m_hsv);
	m_colourPicker->updateDraggerWithHSV(m_hsv);
}


void SJPalette::hueSliderValueChanged(CCObject * sender, CCControlEvent controlEvent)
{
	m_hsv.h      = ((CCControlHuePicker*)sender)->getHue();

	// Update the value
	RGBA rgb    = CCControlUtils::RGBfromHSV(m_hsv);
	// XXX fixed me if not correct
	CCControl::setColor(ccc3((GLubyte)(rgb.r * 255.0f), (GLubyte)(rgb.g * 255.0f), (GLubyte)(rgb.b * 255.0f)));

	// Send CCControl callback
	sendActionsForControlEvents(CCControlEventValueChanged);
	updateControlPicker();
}

void SJPalette::colourSliderValueChanged(CCObject * sender, CCControlEvent controlEvent)
{
	m_hsv.s=((CCControlSaturationBrightnessPicker*)sender)->getSaturation();
	m_hsv.v=((CCControlSaturationBrightnessPicker*)sender)->getBrightness();


	// Update the value
	RGBA rgb    = CCControlUtils::RGBfromHSV(m_hsv);
	// XXX fixed me if not correct
	CCControl::setColor(ccc3((GLubyte)(rgb.r * 255.0f), (GLubyte)(rgb.g * 255.0f), (GLubyte)(rgb.b * 255.0f)));

	// Send CCControl callback
	sendActionsForControlEvents(CCControlEventValueChanged);
}

//ignore all touches, handled by children
bool SJPalette::ccTouchBegan(CCTouch* touch, CCEvent* pEvent)
{
	return false;
}