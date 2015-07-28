//
//  DropDownListSprite.h
//  LuanDou
//
//  Created by Chengxu-4 on 14-4-9.
//
//

#ifndef __LuanDou__DropDownListSprite__
#define __LuanDou__DropDownListSprite__

#include <iostream>
#include "cocos2d.h"

USING_NS_CC;


#define DROPDOWNLIST_NORMAL_COLOR       ccc4(128, 128, 128, 255)
#define DROPDOWNLIST_SELECTED_COLOR     ccc4(200, 200, 200, 255)
#define DROPDOWNLIST_HIGHLIGHT_COLOR    ccc4(0, 0, 255, 255)

#define DROPDOWNLIST_NORMAL_COLOR3       ccc3(128, 128, 128)
#define DROPDOWNLIST_SELECTED_COLOR3     ccc3(200, 200, 200)
#define DROPDOWNLIST_HIGHLIGHT_COLOR3    ccc3(0, 0, 255)

class DropDownListSprite : public CCLayer {
    
public:
    
    DropDownListSprite(CCLabelTTF * label,CCSize size);
    ~ DropDownListSprite();
    
    static DropDownListSprite* create(CCLabelTTF* label, CCSize size);
    std::string getShowLabelString ();
    int getSelectedIndex();
    void setSelectdIndex(int index);
    
    void onEnter();
    void onClose();
    
    void registerWithTouchDispathcher();
    virtual bool ccTouchBegan(CCTouch *pTouch, CCEvent *pEvent);
    virtual void ccTouchMoved(CCTouch *pTouch, CCEvent *pEvent);
    virtual void ccTouchEnded(CCTouch *pTouch, CCEvent *pEvent);
    
    void addLabel(CCLabelTTF * label);
    void onSelected(CCObject * sender);
    
private:
    
    CCMenu * m_mainMenu;
    CCLabelTTF * m_showLabel;
    std::vector<CCLabelTTF *> m_selectLabels;
    std::vector<CCLayerColor *> m_bgLayers;
    bool m_isShowMenu;
    int m_lastSelectedIndex;
    
};

#endif /* defined(__LuanDou__DropDownListSprite__) */
