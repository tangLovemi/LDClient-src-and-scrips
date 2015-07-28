#include "SendContentData.h"

SendContentData::~SendContentData()
{
    CC_SAFE_RELEASE(m_iconPath);
    CC_SAFE_RELEASE(m_sendText);
    CC_SAFE_RELEASE(m_name);
}

SendContentData * SendContentData::createSendContentData(CCString * iconPath, CCString * sendText,int level, CCString * name, bool isMe)
{
    SendContentData * sendContentData = new SendContentData();
    if (sendContentData && sendContentData->init(iconPath, sendText, level, name, isMe))
	{
        sendContentData->autorelease();
        return sendContentData;
    }
    
    CC_SAFE_DELETE(sendContentData);
    return NULL;
}

bool SendContentData::init(CCString * iconPath,CCString * sendText,int level,CCString * name,bool isMe)
{
    m_iconPath = CCString::createWithFormat("%s",iconPath->getCString());
    m_iconPath->retain();
    m_sendText = CCString::createWithFormat("%s",sendText->getCString());
    m_sendText->retain();
    m_name = CCString::createWithFormat("%s",name->getCString());
    m_name->retain();
    
    m_level = level;
    m_IsMe = isMe;
    return true;
    
}

CCString * SendContentData::getIconPath()
{
    return m_iconPath;
}

CCString * SendContentData::getSendText()
{
    return m_sendText;
}

int SendContentData::getLevel()
{
    return m_level;
}

CCString * SendContentData::getName()
{
    return m_name;
}

bool SendContentData::getIsMe()
{
    return m_IsMe;
}