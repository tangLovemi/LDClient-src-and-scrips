#ifndef __LuanDou__ChatLayer__
#define __LuanDou__ChatLayer__

#include <iostream>
#include "cocos2d.h"
#include "cocos-ext.h"

USING_NS_CC_EXT;
USING_NS_CC;

#define CHATFONT 15
#define BTNFONT 25

#define CELLSIZE CCSizeMake(800, 100)
#define TABLESIZE CCSizeMake(800, 350)
#define DROPLISTSIZE CCSizeMake(80,30)
#define DROPLISTFONT 22

#define MAXLENGHT 30 //editbox number

enum ButtonSwitch{
    SYSTEMCHAT,
    WORLDCHAT,
    PERSONALCHAT,
    FACTIONCHAT // bangpai
};

class ChatLayer : public CCLayer ,public CCTableViewDataSource,public CCTableViewDelegate,public CCEditBoxDelegate{
    
public:
    ~ ChatLayer();
    CREATE_FUNC(ChatLayer);
    virtual bool init();
    static ChatLayer * createChatLayer();
    
    //***************tableView Delegate****************
    virtual CCSize cellSizeForTable(CCTableView *table);
    virtual CCTableViewCell* tableCellAtIndex(CCTableView *table, unsigned int idx) ;
    virtual unsigned int numberOfCellsInTableView(CCTableView *table);
    virtual void tableCellTouched(CCTableView* table, CCTableViewCell* cell);
    
    virtual void scrollViewDidScroll(cocos2d::extension::CCScrollView* view);
    virtual void scrollViewDidZoom(cocos2d::extension::CCScrollView* view);
    
    void createLeftChat(CCTableViewCell * cell,CCString * chatText,int level,CCString * iconPath,CCString * name);
    void createRightChat(CCTableViewCell * cell,CCString * chatText,int level,CCString * iconPath,CCString * name);
    void createControlButton();
    
    void pressTopReplaceBtn(CCObject *senderz, CCControlEvent controlEvent);
    void pressSendBtn(CCObject *senderz, CCControlEvent controlEvent);
    
    void createEditBox();
    virtual void editBoxEditingDidBegin(CCEditBox* editBox);
    virtual void editBoxEditingDidEnd(CCEditBox* editBox);
    virtual void editBoxTextChanged(CCEditBox* editBox, const std::string& text);
    virtual void editBoxReturn(CCEditBox* editBox);
    
    void addDropListBtn();
    
private:
    CCTableView * m_tableView;
    
    CCRect m_rect;
    CCRect m_leftRectInset;
    CCRect m_rightRectInset;
    
    CCLayer * m_bgLayer;
    
    CCArray * m_sendContentDatas;
    
    
    
};

#endif