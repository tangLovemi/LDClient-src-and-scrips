#include "DropDownListSprite.h"

DropDownListSprite:: DropDownListSprite(CCLabelTTF * label,CCSize size):m_showLabel(label),m_isShowMenu(false),m_lastSelectedIndex(0)
{
    m_mainMenu = CCMenu::create();
    m_mainMenu->setPosition(ccp(size.width/2, size.height/2));
    CC_SAFE_RETAIN(m_mainMenu);
    
    m_showLabel->setPosition(ccp(size.width/2, size.height/2));
    this->addChild(m_showLabel);
    this->setContentSize(size);
    
}

DropDownListSprite:: ~ DropDownListSprite()
{
    CC_SAFE_RELEASE(m_mainMenu);
}

DropDownListSprite* DropDownListSprite:: create(CCLabelTTF* label, CCSize size)
{
    DropDownListSprite * list = new DropDownListSprite(label,size);
    if (list) {
        list->autorelease();
        return list;
    }
    CC_SAFE_DELETE(list);
    return NULL;
}

std::string DropDownListSprite:: getShowLabelString()
{
    return m_showLabel->getString();
}

int DropDownListSprite:: getSelectedIndex()
{
    return m_lastSelectedIndex;
}

void DropDownListSprite:: setSelectdIndex(int index)
{
    m_lastSelectedIndex = index;
    
    for (int i = 0, j = (int) m_selectLabels.size(); i<j; ++i)
    {
        if (i == m_lastSelectedIndex)
        {
            m_bgLayers[i]->setColor(DROPDOWNLIST_HIGHLIGHT_COLOR3);
            m_showLabel->setString(m_selectLabels[i]->getString());
        }
        
        else
        {
            m_bgLayers[i]->setColor(DROPDOWNLIST_NORMAL_COLOR3);
        }
        
    }
}

void DropDownListSprite:: onEnter()
{
    setTouchEnabled(true);
    CCLayer::onEnter();
    this->registerWithTouchDispathcher();
}

void DropDownListSprite:: onClose()
{
    removeChild(m_mainMenu,true);
    m_isShowMenu = false;
}

void DropDownListSprite:: registerWithTouchDispathcher()
{
    CCDirector * pDirector = CCDirector::sharedDirector();
    pDirector->getTouchDispatcher()->addTargetedDelegate(this, kCCMenuHandlerPriority, true);
}

bool DropDownListSprite:: ccTouchBegan(CCTouch *pTouch, CCEvent *pEvent)
{
    if (!m_isShowMenu)
    {
        CCRect rect;
        rect.origin = CCPointZero;
        rect.size = getContentSize();
        CCPoint position = convertTouchToNodeSpace(pTouch);
        
        if (rect.containsPoint(position))
        {
           
            m_isShowMenu = true;
            
            addChild(m_mainMenu);
            
            for (int i = 0, j = (int) m_selectLabels.size(); i<j; ++i)
            {
                if (i == m_lastSelectedIndex)
                {
                    CCLOG("xxxx");
                    m_bgLayers[i]->setColor(DROPDOWNLIST_HIGHLIGHT_COLOR3);
                    m_showLabel->setString(m_selectLabels[i]->getString());
                }
                
                else
                {
                    CCLOG("xxxy");
                    m_bgLayers[i]->setColor(DROPDOWNLIST_NORMAL_COLOR3);
                }
                
            }
            
            return true;
            
        }
    }
    
    return false;
    
}

void DropDownListSprite:: ccTouchMoved(CCTouch *pTouch, CCEvent *pEvent)
{
    
}

void DropDownListSprite:: ccTouchEnded(CCTouch *pTouch, CCEvent *pEvent)
{
    
}

void DropDownListSprite:: addLabel(CCLabelTTF * label)
{
    
    CCSize size = getContentSize();
    CCLayerColor * normal = CCLayerColor::create(DROPDOWNLIST_NORMAL_COLOR,size.width,size.height);
    CCLayerColor * selected = CCLayerColor::create(DROPDOWNLIST_SELECTED_COLOR, size.width, size.height);
    
    m_bgLayers.push_back(normal);
    m_selectLabels.push_back(label);
    CCMenuItem * item = CCMenuItemSprite::create(normal, selected, NULL,this, SEL_MenuHandler(&DropDownListSprite::onSelected));
    
    label->setPosition(ccp(size.width/2, size.height/2));
    item->addChild(label);
    item->setTag((int)m_selectLabels.size()-1);
    item->setPosition(ccp(0,- (int)m_selectLabels.size() * size.height));
    m_mainMenu->addChild(item);
    
}
void DropDownListSprite:: onSelected(CCObject * sender)
{
    CCMenuItem * item = dynamic_cast<CCMenuItem *>(sender);
    if (item)
    {
        m_lastSelectedIndex = item->getTag();
        m_showLabel->setString(m_selectLabels[item->getTag()]->getString());
    }
    
    onClose();
}


