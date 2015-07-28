//
//  ChatLayer.cpp
//  LuanDou
//
//  Created by Chengxu-4 on 14-4-2.
//
//

#include "ChatLayer.h"
//#include "Util.h"
#include "SendContentData.h"
#include "DropDownListSprite.h"

ChatLayer * ChatLayer:: createChatLayer()
{
    ChatLayer * chatLayer = new ChatLayer();
    if (chatLayer && chatLayer->init())
    {
        chatLayer->autorelease();
        return chatLayer;
    }
    
    CC_SAFE_DELETE(chatLayer);
    return NULL;
}

ChatLayer:: ~ ChatLayer()
{
    
    CC_SAFE_RELEASE(m_sendContentDatas);
}

bool ChatLayer:: init()
{
    if (!CCLayer::init())
    {
        return false;
    }
    
    m_sendContentDatas = CCArray::create();
    m_sendContentDatas->retain();
    
    for (int i = 0; i<10; i++)
    {
        SendContentData * sendData = SendContentData::createSendContentData(CCString::createWithFormat("Res/Image/CrownIcons_0%02d.png",i+1), CCString::createWithFormat("tag = %d",i), 13, CCString::create("stupid man!"),false);
        m_sendContentDatas->addObject(sendData);
    }
    
    m_tableView = CCTableView::create(this, CCSizeMake(TABLESIZE.width, TABLESIZE.height));
    m_tableView->setDirection(kCCScrollViewDirectionVertical);
    m_tableView->setAnchorPoint(ccp(0.5,0.5));
    m_tableView->setPosition(ccp((1136-TABLESIZE.width)/2, (640-TABLESIZE.height)/2));
    m_tableView->setVerticalFillOrder(kCCTableViewFillTopDown);
    this->addChild(m_tableView);
    m_tableView->setDelegate(this);
    m_tableView->setTouchEnabled(true);
    m_tableView->reloadData();
    m_tableView->setContentOffset(ccp(0, 0));
    m_rect = CCRectMake(0, 0, 52, 36);
    
    m_bgLayer = CCLayerColor::create(ccc4(125, 125, 125,55), 800, 500);
    m_bgLayer->setPosition(ccp((1136-800)/2, 70));
    this->addChild(m_bgLayer,-1);
    
    this->createControlButton();
    this->createEditBox();
    this->addDropListBtn();
    
    return true;
}

void ChatLayer:: addDropListBtn()
{
    
    CCLabelTTF *initLabel = CCLabelTTF::create("to GamerChat...","Arial",DROPLISTFONT);
    
    DropDownListSprite * listBox = DropDownListSprite::create(initLabel, DROPLISTSIZE);
    
    CCLabelTTF * label1 = CCLabelTTF::create("Gamer1", "Arial", DROPLISTFONT);
    
    listBox->addLabel(label1);
    
    CCLabelTTF * label2 = CCLabelTTF::create("Gamer2", "Arial", DROPLISTFONT);
    listBox->addLabel(label2);
    
    CCLabelTTF * label3 = CCLabelTTF::create("Gamer3", "Arial", DROPLISTFONT);
    listBox->addLabel(label3);
    
    listBox->setPosition(ccp(80, 30));
    m_bgLayer->addChild(listBox,200);
    
}


CCSize ChatLayer:: cellSizeForTable(CCTableView *table)
{
    //******** cell size ************
    
    return CELLSIZE;
}

CCTableViewCell* ChatLayer:: tableCellAtIndex(CCTableView *table, unsigned int idx)
{
    //******** tableCell data *********
    
    
    CCTableViewCell *pCell = table->dequeueCell();
    
    m_leftRectInset = CCRectMake(36, 20, 1, 1);
    m_rightRectInset = CCRectMake(20, 10, 1, 1);
    
    if (!pCell)
    {
        pCell = new CCTableViewCell();
        pCell->autorelease();
    }
    
    
    pCell->removeAllChildrenWithCleanup(true);
    
    SendContentData * sendData = (SendContentData *)m_sendContentDatas->objectAtIndex(idx);
    CCString * sendText = sendData->getSendText();
    int level = sendData->getLevel();
    CCString * iconPath = sendData->getIconPath();
    CCString * name = sendData->getName();
    bool isMe = sendData->getIsMe();
    
    if (isMe)
    {
        this->createRightChat(pCell, sendText, level, iconPath, name);
    }
    else
    {
        this->createLeftChat(pCell, sendText, level, iconPath, name);
    }
    
    
    
    return pCell;
}

void ChatLayer:: createLeftChat(CCTableViewCell * cell,CCString * chatText,int level,CCString * iconPath,CCString * name)
{
    
    CCLabelTTF * label = CCLabelTTF::create(chatText->getCString(), "Arial", CHATFONT);
    
    
    float labelWidth = label->getContentSize().width;
    if (labelWidth > 300)
    {
        labelWidth = 350;
    }
    
    else
    {
        labelWidth = labelWidth + 50;
    }
    
    if (labelWidth >= 600)
    {
        
    }
    
    
    CCScale9Sprite * chatBg = CCScale9Sprite::create("Res/Image/message_other.png", m_rect, m_leftRectInset);
    chatBg->setAnchorPoint(ccp(0, 0.5));
    chatBg->setContentSize(CCSizeMake(labelWidth,CELLSIZE.height/2));
    chatBg->setPosition(ccp(60, CELLSIZE.height/2));
    chatBg->setColor(ccGREEN);
    
    label->setColor(ccBLACK);
    label->setHorizontalAlignment(kCCTextAlignmentLeft);
    label->setAnchorPoint(ccp(0, 0.5));
    label->setPosition(ccp(95, chatBg->getPositionY()));
    
    CCLabelTTF * lvLabel = CCLabelTTF::create(CCString::createWithFormat("Lv %d",level)->getCString(), "Arial", 15);
    
    lvLabel->setColor(ccRED);
    lvLabel->setAnchorPoint(ccp(0, 0.5));
    lvLabel->setPosition(ccp(115,chatBg->getContentSize().height/2 + chatBg->getPositionY()+8));
    
    if (labelWidth > 300)
    {
        label->setAnchorPoint(ccp(0, 1));
        label->setPosition(ccp(115, chatBg->getPositionY() + chatBg->getContentSize().height/2 - 8));
        
    }
    label->setHorizontalAlignment(kCCTextAlignmentLeft);
    label->setDimensions(CCSizeMake(300, 0));
    
    
    
    CCLabelTTF * nameLabel = CCLabelTTF::create(name->getCString(), "Arial", 20);
    nameLabel->setAnchorPoint(ccp(0, 0));
    nameLabel->setColor(ccc3(0, 125, 255));
    nameLabel->setPosition(ccp(160, lvLabel->getPositionY()-10));
    
    
    CCSprite * icon = CCSprite::create(iconPath->getCString());
    
    icon->setScale(0.1);
    icon->setAnchorPoint(ccp(0, 0.5));
    icon->setPosition(ccp(85, chatBg->getContentSize().height/2 + chatBg->getPositionY()+12));
    
    cell->addChild(icon);
    cell->addChild(nameLabel);
    cell->addChild(lvLabel);
    cell->addChild(chatBg);
    cell->addChild(label);
    
}

void ChatLayer:: createRightChat(CCTableViewCell * cell,CCString * chatText,int level,CCString * iconPath,CCString * name)
{
    
    CCLabelTTF * label = CCLabelTTF::create(chatText->getCString(), "Arial", CHATFONT);
    
    
    float labelWidth = label->getContentSize().width;
    if (labelWidth > 300)
    {
        labelWidth = 350;
    }
    
    else
    {
        labelWidth = labelWidth + 50;
    }
    
    if (labelWidth >= 600)
    {
        
    }
    
    CCScale9Sprite * chatBg = CCScale9Sprite::create("Res/Image/message_i.png", m_rect, m_rightRectInset);
    chatBg->setAnchorPoint(ccp(0, 0.5));
    chatBg->setContentSize(CCSizeMake(labelWidth,CELLSIZE.height/2));
    chatBg->setPosition(ccp(TABLESIZE.width - chatBg->getContentSize().width - 30, 25));
    
    
    
    label->setColor(ccBLACK);
    label->setAnchorPoint(ccp(0, 0.5));
    label->setPosition(ccp(chatBg->getPositionX() + 20, chatBg->getPositionY()));
    
    if (labelWidth > 300)
    {
        label->setAnchorPoint(ccp(0, 1));
        label->setPosition(ccp(chatBg->getPositionX() + 20, chatBg->getPositionY() + chatBg->getContentSize().height/2 - 8));
    }
    
    label->setHorizontalAlignment(kCCTextAlignmentLeft);
    label->setDimensions(CCSizeMake(300, 0));
    
    
    
    
    CCLabelTTF * lvLabel = CCLabelTTF::create(CCString::createWithFormat("Lv %d",level)->getCString(), "Arial", 15);
    lvLabel->setColor(ccRED);
    lvLabel->setAnchorPoint(ccp(0, 0.5));
    lvLabel->setPosition(ccp(chatBg->getPositionX() + 40,chatBg->getContentSize().height/2 + chatBg->getPositionY()+8));
    
    CCLabelTTF * nameLabel = CCLabelTTF::create(name->getCString(), "Arial", 20);
    nameLabel->setAnchorPoint(ccp(0, 0));
    nameLabel->setColor(ccc3(0, 125, 255));
    nameLabel->setPosition(ccp(chatBg->getPositionX() + 85, lvLabel->getPositionY()-10));
    
    
    CCSprite * icon = CCSprite::create(iconPath->getCString());
    icon->setScale(0.1);
    icon->setAnchorPoint(ccp(0, 0.5));
    icon->setPosition(ccp(lvLabel->getPositionX() - 30, chatBg->getContentSize().height/2 + chatBg->getPositionY()+12));
    
    cell->addChild(icon);
    cell->addChild(nameLabel);
    cell->addChild(lvLabel);
    cell->addChild(chatBg);
    cell->addChild(label);
}

unsigned int ChatLayer:: numberOfCellsInTableView(CCTableView *table)
{
    return m_sendContentDatas->count();
}

void ChatLayer:: tableCellTouched(CCTableView* table, CCTableViewCell* cell)
{
    //******** Touch down ***********
}

void ChatLayer:: scrollViewDidScroll(cocos2d::extension::CCScrollView* view)
{
    
}

void ChatLayer:: scrollViewDidZoom(cocos2d::extension::CCScrollView* view)
{
    
}

void ChatLayer:: createControlButton()
{
    CCString * sysText = CCString::createWithFormat("system chat");
    CCString * worldText = CCString::createWithFormat("world chat");
    CCString * prichatText = CCString::createWithFormat("personal chat");
    CCString * factionText = CCString::createWithFormat("faction chat");
    
    for (int i=0; i<4; i++)
    {
        CCScale9Sprite * scale9Sprite = CCScale9Sprite::create("Res/Image/dialog_frame.png");
        const char * ch;
        switch (i)
        {
            case SYSTEMCHAT:
                ch = sysText->getCString();
                break;
            case WORLDCHAT:
                ch = worldText->getCString();
                break;
            case PERSONALCHAT:
                ch = prichatText->getCString();
                break;
            case FACTIONCHAT:
                ch = factionText->getCString();
                break;
            default:
                break;
        }
        
        CCLabelTTF * label = CCLabelTTF::create(ch, "Arial", BTNFONT);
        label->setColor(ccBLACK);
        CCControlButton * btn = CCControlButton::create(label, scale9Sprite);
        btn->setTag(i);
        btn->setPreferredSize(CCSizeMake(115, 40));
        btn->setAnchorPoint(ccp(0, 1));
        btn->setPosition(ccp(75 + i*188, 480));
        btn->addTargetWithActionForControlEvents(this, cccontrol_selector(ChatLayer::pressTopReplaceBtn), CCControlEventTouchDown);
        m_bgLayer->addChild(btn);
    }
    
    CCLabelTTF * sendLable = CCLabelTTF::create("send", "Arial", 25);
    sendLable->setColor(ccBLACK);
    CCScale9Sprite * sendBg = CCScale9Sprite::create("Res/Image/dialog_frame.png");
    CCControlButton * sendBtn = CCControlButton::create(sendLable,sendBg);
    sendBtn->setPreferredSize(CCSizeMake(115, 40));
    sendBtn->setAnchorPoint(ccp(0, 0.5));
    sendBtn->setPosition(ccp(600, 40));
    m_bgLayer->addChild(sendBtn);
    sendBtn->addTargetWithActionForControlEvents(this, cccontrol_selector(ChatLayer::pressSendBtn), CCControlEventTouchDown);
    
}

void ChatLayer:: pressTopReplaceBtn(CCObject *senderz, CCControlEvent controlEvent)
{
    CCControlButton * btn = (CCControlButton *)senderz;
    switch (btn->getTag())
    {
        case SYSTEMCHAT:
            CCLOG("system button");
            break;
        case WORLDCHAT:
            CCLOG("world button");
            break;
        case PERSONALCHAT:
            CCLOG("personal button");
            break;
        case FACTIONCHAT:
            CCLOG("faciton button");
            break;
        default:
            break;
    }
}

void ChatLayer:: createEditBox()
{
    CCScale9Sprite * inputBox = CCScale9Sprite::create("Res/Image/SendTextViewBkg@2x.png",CCRectMake(0, 0, 100, 80),CCRectMake(30, 30, 20, 20));
    inputBox->setContentSize(CCSizeMake(400, 70));
    inputBox->setPosition(ccp(400, 40));
    m_bgLayer->addChild(inputBox,-1);
    
    auto editBox = CCEditBox::create(CCSizeMake(350, 40), CCScale9Sprite::create());
    editBox->setPosition(inputBox->getPosition());
    editBox->setPlaceHolder("send message...");
    editBox->setInputMode(kEditBoxInputModeAny);
    editBox->setDelegate(this);
    editBox->setMaxLength(MAXLENGHT);
    editBox->setFontColor(ccBLACK);
    editBox->setReturnType(kKeyboardReturnTypeSend);
    m_bgLayer->addChild(editBox);
}

void ChatLayer:: editBoxEditingDidBegin(CCEditBox* editBox)
{
    
}

void ChatLayer:: editBoxEditingDidEnd(CCEditBox* editBox)
{
    
    
}

void ChatLayer:: editBoxTextChanged(CCEditBox* editBox, const std::string& text)
{
    
}

void ChatLayer:: editBoxReturn(CCEditBox* editBox)
{
    
    
    CCString * sendText = CCString::createWithFormat("%s",editBox->getText());
    
    if (sendText->length() >= editBox->getMaxLength())
    {
        CCLOG("Equal!");
        sendText = CCString::createWithFormat("%s...",sendText->getCString());
    }
    
    if (sendText->compare(""))
    {
        
        SendContentData * sendData = SendContentData::createSendContentData(CCString::createWithFormat("Res/Image/CrownIcons_002.png"), sendText, 13, CCString::createWithFormat("cao"), true);
        m_sendContentDatas->addObject(sendData);
        m_tableView->reloadData();
        m_tableView->setContentOffset(ccp(0, 0));
        editBox->setText("");
        
    }
    
}

void ChatLayer:: pressSendBtn(CCObject *senderz, CCControlEvent controlEvent)
{
    
    m_tableView->reloadData();
    m_tableView->setContentOffset(ccp(0, 0));
}






