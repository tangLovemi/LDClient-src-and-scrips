module("Mail", package.seeall)

local m_isCreate = false;
local m_isOpen = false;
local m_rootLayer = nil;
local m_uiLayer = nil;
local m_UILayout = nil
local m_allMailData = nil
local m_mailList = nil
local m_mailItem = nil
local m_selectedItem = nil
local m_mailDetailPanel = nil
local m_mailAttachPanel = nil
local m_mailAttachButton = nil 
local m_replyBtn = nil
local m_mailDetailPanelPos = nil
local m_detailCloseBtnPos = nil
local m_deletMailBtn = nil
local m_writeMailPanel = nil 
local m_writeMailBtn = nil 
local m_writePanelOpen = false
local m_inputTitle = nil
local m_inputReciever= nil
local m_inputContent = nil
local m_detailCloseBtn = nil
local m_showFreindListBtn = nil
local m_friendsListPanel = nil
local m_friendsItemPanel = nil
local m_openFriendList = false
local m_fixPosition = nil
local m_HidePosition =CCPoint(100000, 100000)  

local function onWriteCloseBtn(sender,eventType)--点击写信的关闭
    if eventType == TOUCH_EVENT_TYPE_END then
        m_writeMailPanel:setPosition(CCPoint(10000,10000))
        m_mailDetailPanel:setPosition(m_mailDetailPanelPos)
        m_writeMailBtn:setVisible(true)
    end
end
local function onSendMailSuccess()
    
    m_inputReciever:setText("")  
    m_inputTitle:setText("")  
    m_inputContent:setText("")  
    Util.showOperateResultPrompt("邮件发送成功")
end
local function onWriteSendBtn(sender,eventType) --点击发送邮件
    if eventType == TOUCH_EVENT_TYPE_END then
        local userName = m_inputReciever:getStringValue()
        local newMailTitle = m_inputTitle:getStringValue()
        local newMailContent = m_inputContent:getStringValue()
        if userName=="" then
            Util.showOperateResultPrompt("收件人不能为空，请检测后再发送")
        else
            if newMailTitle == "" then
                Util.showOperateResultPrompt("标题不能为空，请检测后再发送")
            else
                if newMailContent == "" then
                    Util.showOperateResultPrompt("邮件内容不能为空，请检测后再发送")
                else
                    MailManager.sendNewMail(userName,newMailTitle,newMailContent,onSendMailSuccess)
                end
            end
        end
    end
end


local function mailOperateResp(mailId, state)
    if state== 1 then
        local mailIcon = tolua.cast(m_selectedItem:getChildByName("youjian_img"),"ImageView")
        mailIcon:loadTexture(PATH_CCS_RES.."youxiang_youjian_2.png")
        Util.showOperateResultPrompt("邮件已读取")
    elseif state ==3  then
        m_mailList:removeItem(m_mailList:getIndex(m_selectedItem))
        m_mailList:refreshView()
        Util.showOperateResultPrompt("邮件已删除")
        m_selectedItem = nil
    elseif state ==4 then
        m_mailList:removeItem(m_mailList:getIndex(m_selectedItem))
        m_mailList:refreshView()
        Util.showOperateResultPrompt("邮件附件领取并已删除")
        m_selectedItem = nil
        updateMailDetail(nil)
        -- updateMailList()
    end
end

local function onGetAttachClick(sender,eventType)--点击领取按钮
    if eventType == TOUCH_EVENT_TYPE_END then
        if(GoodsManager.isBackpackFull_2()) then
            --背包满提示
            BackpackFullTishi.show();
            return
        end        
        local mailId = m_selectedItem:getTag()
        MailManager.mailOperate(mailId,2,mailOperateResp)

    end
end
local function deleteMailOnClick(sender,eventType)
    if eventType == TOUCH_EVENT_TYPE_END then
        if m_selectedItem ==nil then 
            return 
        end
        local mailId = m_selectedItem:getTag()
        MailManager.mailOperate(mailId,3,mailOperateResp)
        updateMailDetail(nil)
    end
end


local function goodsOnClick( sender,eventType )
    if eventType == TOUCH_EVENT_TYPE_BEGIN then
        GoodsDetails.onTouchBegin(sender, sender:getTag());
    elseif eventType == TOUCH_EVENT_TYPE_END or eventType == TOUCH_EVENT_TYPE_CANCEL then
        GoodsDetails.onTouchEnd();
    end
end


function updateMailDetail(mailId)--更新邮件内容
    
    local mailTitle = tolua.cast(m_UILayout:getWidgetByName("wenben_label"), "Label")
    local mailContent = tolua.cast(m_UILayout:getWidgetByName("xiangxiwenben_label"), "Label")
    local mailAttach  = tolua.cast(m_UILayout:getWidgetByName("jiangliceng_panel"), "Layout")


    local mailData = MailManager.getMailContentById(mailId)
    if mailId ~=nil then
        mailTitle:setText(mailData["title"])
        mailContent:setText(mailData["content"])
        if mailData["attach"]~= "" then--判断附件是否存在
            if mailData["mailType"] == 0 then
                m_mailAttachPanel:setVisible(true)
                m_mailAttachButton:setVisible(true)
                m_detailCloseBtn:setVisible(false)
                m_replyBtn:setVisible(false)
                m_deletMailBtn:setVisible(false)
            else

            end
            local attachString = mailData["attach"] 
            local attachArry = Util.Split(attachString,";")
            for i=1,6 do
                local itemPanel = tolua.cast(m_mailAttachPanel:getChildByName("jiangli"..i.."_panel"),"Layout")
                itemPanel:setVisible(false)
            end
            for k,v in pairs(attachArry) do
                if v~= "" then
                    itemArry = Util.Split(v,",")
                    local itemId = itemArry[1]

                    local itemPanel = tolua.cast(m_mailAttachPanel:getChildByName("jiangli"..k.."_panel"),"Layout")
                    itemPanel:setTouchEnabled(true);
                    itemPanel:setVisible(true)
                    local itemIcon = GoodsManager.getIconPathById(tonumber(itemId))
                    itemPanel:setBackGroundImage(itemIcon)
                    local frameImage = tolua.cast(itemPanel:getChildByName("jiangli"..k.."_img"),"ImageView")
                    local itemNum= tolua.cast(frameImage:getChildByName("wupinshuliang"..k.."_label"),"Label")
                    itemNum:setText(itemArry[2])
                    itemPanel:setTag(itemId);
                    itemPanel:addTouchEventListener(goodsOnClick);
                end
            end
        else
            m_mailAttachPanel:setVisible(false)
            m_mailAttachButton:setVisible(false)
            m_deletMailBtn:setVisible(true)
            m_detailCloseBtn:setPosition(CCPoint(10000,10000))
            m_replyBtn:setPosition(m_detailCloseBtnPos)
            m_replyBtn:setVisible(true)
            if mailData["mailType"] == 0  then
                m_replyBtn:setPosition(CCPoint(10000,10000))
                m_detailCloseBtn:setPosition(m_detailCloseBtnPos)
            end
        end
        
    else
        mailTitle:setText("")
        mailContent:setText("")
        m_mailAttachPanel:setVisible(false)
        m_mailAttachButton:setVisible(false)
        m_deletMailBtn:setVisible(true)
        m_detailCloseBtn:setPosition(CCPoint(10000,10000))
        m_replyBtn:setPosition(m_detailCloseBtnPos)
        m_replyBtn:setVisible(true)
    end
end

local function openWriteMailOnClick(sender,eventType) --点击写信
    if eventType == TOUCH_EVENT_TYPE_END then         
        m_inputReciever:setText("")  
        m_inputTitle:setText("")
        m_inputContent:setText("")  
        if sender:getTag() ==30002 then 
            if m_selectedItem~= nil then 
                local senderLabel = tolua.cast(m_selectedItem:getChildByName("fasongren_label"),"Label")
                m_inputReciever:setText(senderLabel:getStringValue())
            else
                Util.showOperateResultPrompt(TEXT.mailTip_no_selected_sender)
                return
            end
        end

        m_mailDetailPanel:setPosition(CCPoint(10000,10000))
        m_writeMailPanel:setPosition(m_mailDetailPanelPos)
        m_writeMailBtn:setVisible(false)
        m_writePanelOpen = true

    end
end
local function closeOnClick(sender,eventType)
    if eventType == TOUCH_EVENT_TYPE_END then
        UIManager.close("Mail")
        NotificationManager.onLineCheck("MailManager")
    end
end
local function updateSelectedItem(mailItem)
    if m_selectedItem ~= nil then 
        local itemFocus = tolua.cast(m_selectedItem:getChildByName("gaoliang_img"),"ImageView")
        itemFocus:setVisible(false)  
    end
    m_selectedItem = m_mailList:getChildByTag(mailItem:getTag())
    local itemFocus = tolua.cast(m_selectedItem:getChildByName("gaoliang_img"),"ImageView")
    itemFocus:setVisible(true)    
end
local function onMailItemClicked(sender,eventType)
    if eventType == TOUCH_EVENT_TYPE_END then
        local mailId = sender:getTag()
        updateSelectedItem(sender)
        updateMailDetail(mailId)
        if m_writePanelOpen then 
            onWriteCloseBtn(nil,2)
            m_writePanelOpen = false
        end
        local mailData = MailManager.getMailContentById(mailId)
        if mailData["state"] == 0 then
            MailManager.mailOperate(mailId,1,mailOperateResp)
        end
    end
end

function openWriteMailOutSide(reciverName)
    openWriteMailOnClick(nil,TOUCH_EVENT_TYPE_END)
    m_inputReciever:setText(reciverName)
end



local function insertMailItem ( mailId,mailData,index)
    local mailItem = m_mailItem:clone()
    mailItem:setTag(mailId)
    local itemFocus = tolua.cast(mailItem:getChildByName("gaoliang_img"),"ImageView")
    itemFocus:setVisible(false)
    local mailIcon = tolua.cast(mailItem:getChildByName("youjian_img"),"ImageView")
    local titleLabel = tolua.cast(mailItem:getChildByName("leixing_label"),"Label")
    local senderLabel = tolua.cast(mailItem:getChildByName("fasongren_label"),"Label")
    local m_timelLabel = tolua.cast(mailItem:getChildByName("shuzishijian_label"), "Label")
    local m_timeDescLabel = tolua.cast(mailItem:getChildByName("shijianzhuangtai_label"), "Label")
    if mailData.state>0 then 
        mailIcon:loadTexture(PATH_CCS_RES.."youxiang_youjian_2.png")
    end
    local timeDiff,timeDiffDesc = MailManager.getMailTimeDiffStrings(mailId)
    m_timelLabel:setText(timeDiff)
    m_timeDescLabel:setText(timeDiffDesc)

    titleLabel:setText(mailData.title)
    senderLabel:setText(mailData.sender_name)
    mailItem:addTouchEventListener(onMailItemClicked)
    if index~= nil then
        m_mailList:insertCustomItem(mailItem,index)
    else
        m_mailList:pushBackCustomItem(mailItem)
    end
end
function updateMailList()
    m_allMailData = MailManager.getAllMail()
    local initIndex = table.maxn(m_allMailData)

    updateMailDetail(nil)
    m_mailList:removeAllItems()
    m_mailList:refreshView()
    for k,v in pairs(m_allMailData) do
        if v~= nil then
            insertMailItem(v["mailId"],v)
        end
    end

end
function showFriendList(sender,eventType)
    if eventType == TOUCH_EVENT_TYPE_END then
        if (not m_openFriendList) then 
            m_openFriendList = true
              
            m_friendsListPanel:setPosition(m_fixPosition)
            local friendList = FriendsManager.getFriendList()
            for k,v in pairs(friendList) do
                local friendItem = m_friendsItemPanel:clone()
                local namelLebel = tolua.cast(friendItem:getChildByName("name_label"),"Label")
                local friendBtn  = tolua.cast(friendItem:getChildByName("friend_btn"),"Button")
                local function friendOnclick(sender,eventType)
                    if eventType == TOUCH_EVENT_TYPE_END then
                        m_inputReciever:setText(v.name)
                        m_openFriendList = false            
                        m_friendsListPanel:setPosition(m_HidePosition)
                        m_friendsListPanel:removeAllItems()
                    end
                end
                friendBtn:addTouchEventListener(friendOnclick)
                namelLebel:setText(v.name)
                m_friendsListPanel:pushBackCustomItem(friendItem)
            end
        else
            m_friendsListPanel:removeAllItems()
            m_openFriendList = false           
            m_friendsListPanel:setPosition(m_HidePosition)
        end
    end
end
function getNewMail(mailData)
    insertMailItem(mailData["mailId"],mailData,0)
    m_allMailData = MailManager.getAllMail()
end
function getOpenState()
    return m_isOpen
end
function create()
    if(not m_isCreate) then
        m_isCreate = true;
        m_rootLayer = CCLayer:create();
        m_rootLayer:retain();
        local UISource = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "youxiang_1.json");
        m_UILayout = TouchGroup:create();
        m_UILayout:addWidget(UISource);
        m_rootLayer:addChild(m_UILayout);
        local basePanel = tolua.cast(m_UILayout:getWidgetByName("beijing_panel"), "Layout")
        basePanel:addTouchEventListener(closeOnClick)
        m_mailList= tolua.cast(m_UILayout:getWidgetByName("youxiang_list"), "ListView")
        m_mailItem= tolua.cast(m_UILayout:getWidgetByName("youjian_panel"), "Layout")
        m_mailDetailPanel = tolua.cast(m_UILayout:getWidgetByName("xiangxi_panel"), "Layout")
        m_mailAttachPanel  = tolua.cast(m_UILayout:getWidgetByName("jiangliceng_panel"), "Layout")
        m_mailAttachPanel:setVisible(false)
        m_mailAttachButton = tolua.cast(m_UILayout:getWidgetByName("lingqu_btn"), "Button")
        m_mailAttachButton:addTouchEventListener(onGetAttachClick)
        m_mailAttachButton:setVisible(false)
        m_detailCloseBtn= tolua.cast(m_UILayout:getWidgetByName("guanbi_btn"), "Button")
        m_detailCloseBtnPos =   CCPoint(m_detailCloseBtn:getPositionX(),m_detailCloseBtn:getPositionY()) 
        m_detailCloseBtn:addTouchEventListener(closeOnClick)

        m_replyBtn= tolua.cast(m_UILayout:getWidgetByName("huifu_btn"), "Button")
        m_replyBtn:setTag(30002)
        m_replyBtn:addTouchEventListener(openWriteMailOnClick)
        m_writeMailBtn = tolua.cast(m_UILayout:getWidgetByName("xiexin_btn"), "Button")
        m_writeMailBtn:addTouchEventListener(openWriteMailOnClick)
        
        m_deletMailBtn = tolua.cast(m_UILayout:getWidgetByName("shanchu_btn"), "Button")
        m_deletMailBtn:addTouchEventListener(deleteMailOnClick)
        m_mailDetailPanelPos = CCPoint(m_mailDetailPanel:getPositionX(),m_mailDetailPanel:getPositionY())

        m_writeMailPanel = tolua.cast(m_UILayout:getWidgetByName("xiangxi1_panel"), "Layout")
        local writeCloseBtn = tolua.cast(m_UILayout:getWidgetByName("guanbi2_btn"), "Button")
        writeCloseBtn:addTouchEventListener(onWriteCloseBtn)
        local writeSendBtn = tolua.cast(m_UILayout:getWidgetByName("fasong2_btn"), "Button")
        writeSendBtn:addTouchEventListener(onWriteSendBtn)
        m_inputReciever = tolua.cast(m_UILayout:getWidgetByName("shoujian_textfield"), "TextField")
        m_inputTitle= tolua.cast(m_UILayout:getWidgetByName("biaoti_textfield"), "TextField")
        m_inputContent = tolua.cast(m_UILayout:getWidgetByName("TextField_84"), "TextField")    
        m_showFreindListBtn= tolua.cast(m_UILayout:getWidgetByName("xialahaoyou_btn"), "Button") 
        m_showFreindListBtn:addTouchEventListener(showFriendList)
        m_friendsListPanel= tolua.cast(m_UILayout:getWidgetByName("ListView_12"), "ListView")
        m_fixPosition = CCPoint(m_friendsListPanel:getPositionX(),m_friendsListPanel:getPositionY())
        m_friendsListPanel:setPosition(CCPoint(10000,10000))
        m_friendsItemPanel= tolua.cast(m_UILayout:getWidgetByName("name_panel"), "Layout")

        
        m_inputReciever:setText("")  
        m_inputTitle:setText("")  
        m_inputContent:setText("")  

    end
end

function open()
    NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_MAILREQUEST, {0});
    if (not m_isOpen) then
        create();
        m_isOpen = true;
        local uiLayer = getGameLayer(SCENE_UI_LAYER);
        uiLayer:addChild(m_rootLayer);
        updateMailList()

    end
end

function close()
    if (m_isOpen) then
        m_isOpen = false;
        local uiLayer = getGameLayer(SCENE_UI_LAYER);
        uiLayer:removeChild(m_rootLayer, false);
    end
end

function remove()
    if(m_isCreate) then
        m_isCreate = false;
        if(m_rootLayer) then
            m_rootLayer:removeAllChildrenWithCleanup(true);
            m_rootLayer:release();
        end
        m_isCreate = nil;
        m_isOpen = nil;
        m_rootLayer = nil;
        m_uiLayer = nil;
        m_UILayout = nil
        m_allMailData = nil
        m_mailList = nil
        m_mailItem = nil
        m_selectedItem = nil
        m_mailDetailPanel = nil
        m_mailAttachPanel = nil
        m_mailAttachButton = nil 
        m_mailDetailPanelPos = nil
        m_writeMailPanel = nil 
        m_writeMailBtn = nil 
        m_writePanelOpen = nil
        m_replyBtn = nil
        m_mailDetailPanelPos = nil
        m_inputTitle = nil
        m_inputReciever= nil
        m_inputContent = nil
    end
end
