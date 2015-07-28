#ifndef __LuanDou__SendContentData__
#define __LuanDou__SendContentData__

#include <iostream>
#include "cocos2d.h"

USING_NS_CC;

class SendContentData:public CCObject
{
public:
    ~SendContentData();
    
    static SendContentData * createSendContentData(CCString * iconPath, CCString * sendText, int level, CCString * name, bool isMe);
    bool init(CCString * iconPath,CCString * sendText, int level, CCString * name, bool isMe);
    
    CCString * getIconPath();
    CCString * getSendText();
    int getLevel();
    CCString * getName();
    bool getIsMe();
    
private:
    
    CCString * m_iconPath;
    CCString * m_sendText;
    int m_level;
    CCString * m_name;
    bool m_IsMe;
};

#endif