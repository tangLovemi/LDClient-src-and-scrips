module("FriendsMain", package.seeall)

local m_isCreate = false;
local m_isOpen = false;
local m_rootLayer = nil;
local m_uiLayer = nil;
local m_UILayout = nil
--按钮组
local m_friendListBtn         = nil
local m_addFriendBtn          = nil
local m_allGigtBtn            = nil
local m_onKeyGiftBtn          = nil 
local m_onKeyRecommandBtn     = nil
local m_oneKeyTakeGiftsBtn    = nil 
local m_searchConfirmBtn      = nil
local m_LeftBtnPos            = nil 
local m_HidePosition          = CCPoint(10000,10000)

local m_selectedBtnIndex      = 1
--新标识
local m_newApplyFriend        = nil
local m_newFriendGift         = nil

local m_itemListPanel         = nil

local m_searchInputBox        = nil
local m_applyList             = nil
local m_friendList            = nil
local m_giftsData             = nil
local m_detailId              = ""
local fromOutSide             = false

local function colseOnClick(sender,eventType)
    if eventType == TOUCH_EVENT_TYPE_END then
        UIManager.close("FriendsMain")      
        NotificationManager.onCloseCheck("FriendsManager")
    end 
end

local function showFriendList(sender,eventType)
    if eventType == TOUCH_EVENT_TYPE_END then
        
        print("this is a .....showFriendList")
        if m_selectedBtnIndex~= 1 then
            initListView(1)
        end
        m_selectedBtnIndex= 1
    end
end
local function addFriendOnClick(sender,eventType)
    if eventType == TOUCH_EVENT_TYPE_END then
        print("this is a .....addFriendOnClick")
        if m_selectedBtnIndex~= 2 then
            initListView(2)
        end
        m_selectedBtnIndex= 2
    end
end
local function allGiftOnClick(sender,eventType)
    if eventType == TOUCH_EVENT_TYPE_END then
        print("this is a .....allGiftOnClick")
        if m_selectedBtnIndex~= 3 then
            initListView(3)
        end
        m_selectedBtnIndex= 3
    end
end
local function oneKeyGiftOnClick(sender,eventType)
    if eventType == TOUCH_EVENT_TYPE_END then
        print("this is a .....oneKeyGiftOnClick")
        FriendsManager.oneKeyGiveGifts(initListView)
    end
end
local function oneKeyRecommandOnClick(sender,eventType)
    if eventType == TOUCH_EVENT_TYPE_END then
        print("this is a .....oneKeyRecommandOnClick")
        FriendRecommandUI.create()
        FriendRecommandUI.open()
    end
end
local function oneKeyTakeGiftOnClick(sender,eventType)
    if eventType == TOUCH_EVENT_TYPE_END then
        if(GoodsManager.isBackpackFull_1()) then
            --背包满提示
            BackpackFullTishi.show();
            return
        end
        -- print("this is a .....oneKeyTakeGiftOnClick")
        FriendsManager.oneKeyGetAllGift(initListView)
    end
end
local function searchAndAddFriendSucess()
    -- initListView(3)
end
local function searchConfirmOnClick(sender,eventType)
    if eventType == TOUCH_EVENT_TYPE_END then
        print("this is a .....searchConfirmOnClick")
        local stringInput = m_searchInputBox:getStringValue()
        if stringInput ~= "" then
            FriendsManager.applyAddFriendBySearch(stringInput,1,searchAndAddFriendSucess)
        end
    end
end

local function deleteFriendOnClick(sender,eventType)
    if eventType == TOUCH_EVENT_TYPE_END then
        print("deleteFriendOnClick".. sender:getTag())
        local userId = m_friendList[sender:getTag()-30000].id
        FriendsManager.deleteFriend(userId,initListView)
        
    end
end
local function giftFriendOnClick(sender,eventType)
    if eventType == TOUCH_EVENT_TYPE_END then
        -- print("giftFriendOnClick".. sender:getTag())
        local userId = m_friendList[sender:getTag()-40000].id
        FriendsManager.giftFriend(userId,initListView)
        sender:setTouchEnabled(false)
        sender:setVisible(false)
    end
end
local function acceptFriendOnClick(sender,eventType)
    if eventType == TOUCH_EVENT_TYPE_END then
       local userId = m_applyList[sender:getTag()-20000].id
       FriendsManager.acceptFriend(userId,initListView)
    end
end

local function rejectFriendOnClick(sender,eventType)
    if eventType == TOUCH_EVENT_TYPE_END then
       local userId = m_applyList[sender:getTag()-10000].id
       FriendsManager.rejectFriend(userId,initListView)
    end
end

local function takeGiftOnClick(sender,eventType)
   if eventType == TOUCH_EVENT_TYPE_END then
        if(GoodsManager.isBackpackFull_1()) then
            --背包满提示
            BackpackFullTishi.show();
            return
        end    
       local giftId = m_giftsData[sender:getTag()-50000].giftId
       FriendsManager.acceptGift(giftId,initListView)        
   end
end

--显示装备详细信息
function showEquipDetails( data )
    GoodsDetailsPanel.showFigureDetails(data, ccp(612, 130));
end

local function onShowFriendDetail(roleData) --展示好友详细信息
    local function closeDetail()

        Figure.close()
        Figure.removeAnimation();
        Figure.remove()

        Background.close();
        Background.remove();
        GoodsDetailsPanel.remove();

        -- if fromOutSide == true then 
        --     fromOutSide = false
        --     UIManager.close("FriendsMain")
        -- end       
        
    end
    Background.create(closeDetail,1)
    Background.open()  
    Figure.create()
    -- Figure.createAnimation();
    UIManager.open("Figure",roleData)
    Figure.setPosition(CCPoint(400,30))
    GoodsDetailsPanel.create();
end

local function onFriendDetailClicked(sender,eventType)
    if eventType == TOUCH_EVENT_TYPE_END then
        local userId = m_friendList[sender:getTag()-600000].id
        checkDetailForRole(userId)
    end
end
function checkDetailForRole(userId)
    -- fromOutSide = true
    -- m_UILayout:setVisible(false)
    FriendsManager.getFriendDetail(userId, onShowFriendDetail)

end
function initListView(updateType)--updateType{1：好友列表，2：推荐好友，3：收到礼物}
    updateButtonView(updateType)
    updateMarkView()
    m_selectedBtnIndex= updateType
    if updateType == 1 then   
        m_itemListPanel:removeAllItems() 
        m_itemListPanel:refreshView()   
        local friendItemUI = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "Friends_friendsItem.json")
        local itemBase = TouchGroup:create();
        itemBase:addWidget(friendItemUI);  
        local itemRoot =  tolua.cast(itemBase:getWidgetByName("root_panel"), "Layout");  
        m_friendList = FriendsManager.getFriendList() 
        for k,v in pairs(m_friendList) do
            local itemPanel = itemRoot:clone()     
            local deleteBtn = tolua.cast(itemPanel:getChildByName("quxiao_btn"), "Button");  
            local giftBtn = tolua.cast(itemPanel:getChildByName("tianjia_btn"), "Button");  
            local tempPanel =  tolua.cast(itemPanel:getChildByName("Panel_6"), "Layout"); 
            local nameLabel =  tolua.cast(tempPanel:getChildByName("jsm_label"), "Label");            
            local imgPanel = tolua.cast(tempPanel:getChildByName("Panel_2"), "Layout"); 
            local vipImg = tolua.cast(tempPanel:getChildByName("Image_7"), "ImageView"); 

            local hairColorImg = tolua.cast(imgPanel:getChildByName("gg__img"), "ImageView"); 
            local faceImg = tolua.cast(imgPanel:getChildByName("tx_img"), "ImageView"); 
            local coatImg = tolua.cast(imgPanel:getChildByName("yif_img"), "ImageView");
            local levelLabel = tolua.cast(tempPanel:getChildByName("AtlasLabel_13"), "LabelAtlas");
            local jjGroupImg = tolua.cast(tempPanel:getChildByName("Image_12"), "ImageView");
            local infoPanelBtn = tolua.cast(tempPanel:getChildByName("tmtu_panel"), "Layout");  
            infoPanelBtn:setTag(600000+k)
            infoPanelBtn:addTouchEventListener(onFriendDetailClicked)
            
            deleteBtn:setTag(30000+k)
            deleteBtn:addTouchEventListener(deleteFriendOnClick)  
            giftBtn:setTag(40000+k)     
            giftBtn:addTouchEventListener(giftFriendOnClick)   


            local headImgPath = Util.getHeadImgPath(v.hair,v.haircolor,v.face,v.coat)
                      
            hairColorImg:loadTexture(headImgPath["hairImg"])
            faceImg:loadTexture(headImgPath["faceImg"])
            coatImg:loadTexture( headImgPath["coatImg"])
            nameLabel:setText(v.name)
            levelLabel:setStringValue(v.jjcRanking)
            m_itemListPanel:pushBackCustomItem(itemPanel)
            jjGroupImg:loadTexture(PATH_CCS_RES.."jjc_zubie_"..v.jjcGroupId..".png")

            if v.isSendGift == 1 then
                giftBtn:setTouchEnabled(false)
                giftBtn:setVisible(false)
            end
            if v.viplevel == 0 then 
                vipImg:setVisible(false)
            else
                local vipLabel = tolua.cast(vipImg:getChildByName("dji_labelNum"), "LabelAtlas");
                vipLabel:setStringValue(v.viplevel)
            end

        end
    elseif updateType == 2 then
        m_itemListPanel:removeAllItems()  
        m_itemListPanel:refreshView()

        local addFriendUI = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "Friends_ApplyItem.json")
        local itemBase = TouchGroup:create();
        itemBase:addWidget(addFriendUI);  
        local itemRoot =  tolua.cast(itemBase:getWidgetByName("root_panel"), "Layout");  
        m_applyList= FriendsManager.getApplyList() 
        for k,v in pairs(m_applyList) do
            local itemPanel = itemRoot:clone()     
            local rejectBtn = tolua.cast(itemPanel:getChildByName("quxiao_btn"), "Button");  
            rejectBtn:setTag(10000+k)
            rejectBtn:addTouchEventListener(rejectFriendOnClick)  
            local acceptBtn = tolua.cast(itemPanel:getChildByName("tianjia_btn"), "Button");  
            acceptBtn:setTag(20000+k)     
            acceptBtn:addTouchEventListener(acceptFriendOnClick)   
            local tempPanel =  tolua.cast(itemPanel:getChildByName("Panel_6"), "Layout"); 
            local nameLabel =  tolua.cast(tempPanel:getChildByName("jsm_label"), "Label");
            local imgPanel = tolua.cast(tempPanel:getChildByName("Panel_2"), "Layout"); 
            local hairColorImg = tolua.cast(imgPanel:getChildByName("gg__img"), "ImageView"); 
            local faceImg = tolua.cast(imgPanel:getChildByName("tx_img"), "ImageView"); 
            local coatImg = tolua.cast(imgPanel:getChildByName("yif_img"), "ImageView");
            local levelLabel = tolua.cast(tempPanel:getChildByName("AtlasLabel_13"), "LabelAtlas");
            local jjGroupImg = tolua.cast(tempPanel:getChildByName("Image_12"), "ImageView");
            local vipImg = tolua.cast(tempPanel:getChildByName("Image_7"), "ImageView"); 

            local headImgPath = Util.getHeadImgPath(v.hair,v.haircolor,v.face,v.coat)
                      
            hairColorImg:loadTexture(headImgPath["hairImg"])
            faceImg:loadTexture(headImgPath["faceImg"])
            coatImg:loadTexture( headImgPath["coatImg"])
            jjGroupImg:loadTexture(PATH_CCS_RES.."jjc_zubie_"..v.jjcGroupId..".png")
            nameLabel:setText(v.name)
            levelLabel:setStringValue(v.jjcRanking)

            if v.viplevel == 0 then 
                vipImg:setVisible(false)
            else
                local vipLabel = tolua.cast(vipImg:getChildByName("dji_labelNum"), "LabelAtlas");
                vipLabel:setStringValue(v.viplevel)
            end

            m_itemListPanel:pushBackCustomItem(itemPanel)


        end

    elseif updateType == 3 then 
        m_itemListPanel:removeAllItems() 
        m_itemListPanel:refreshView() 

        local freindGiftItem = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "Friends_GiftItem.json")
        local itemBase = TouchGroup:create();
        itemBase:addWidget(freindGiftItem);  
        local itemRoot =  tolua.cast(itemBase:getWidgetByName("root_panel"), "Layout");  
        m_giftsData= FriendsManager.getGiftsData() 
        for k,v in pairs(m_giftsData) do
            local itemPanel = itemRoot:clone()     
            local takeGiftBtn = tolua.cast(itemPanel:getChildByName("tianjia_btn"), "Button");  
            takeGiftBtn:setTag(50000+k)     
            takeGiftBtn:addTouchEventListener(takeGiftOnClick)   
            local tempPanel =  tolua.cast(itemPanel:getChildByName("Panel_6"), "Layout"); 
            local nameLabel =  tolua.cast(tempPanel:getChildByName("jsm_label"), "Label");            
            local imgPanel = tolua.cast(tempPanel:getChildByName("Panel_2"), "Layout"); 
            local hairColorImg = tolua.cast(imgPanel:getChildByName("gg__img"), "ImageView"); 
            local faceImg = tolua.cast(imgPanel:getChildByName("tx_img"), "ImageView"); 
            local coatImg = tolua.cast(imgPanel:getChildByName("yif_img"), "ImageView");
            local levelLabel = tolua.cast(tempPanel:getChildByName("AtlasLabel_13"), "LabelAtlas");
            local jjGroupImg = tolua.cast(tempPanel:getChildByName("Image_12"), "ImageView");
            local vipImg = tolua.cast(tempPanel:getChildByName("Image_7"), "ImageView"); 

            local headImgPath = Util.getHeadImgPath(v.hair,v.haircolor,v.face,v.coat)
                      
            hairColorImg:loadTexture(headImgPath["hairImg"])
            faceImg:loadTexture(headImgPath["faceImg"])
            coatImg:loadTexture( headImgPath["coatImg"])
            jjGroupImg:loadTexture(PATH_CCS_RES.."jjc_zubie_"..v.jjcGroupId..".png")
            nameLabel:setText(v.name)
            levelLabel:setStringValue(v.jjcRanking)

            if v.viplevel == 0 then 
                vipImg:setVisible(false)
            else
                local vipLabel = tolua.cast(vipImg:getChildByName("dji_labelNum"), "LabelAtlas");
                vipLabel:setStringValue(v.viplevel)
            end            
            m_itemListPanel:pushBackCustomItem(itemPanel)
        end

    end
end
function updateButtonView(updateType)--updateType{1：好友列表，2：推荐好友，3：收到礼物}
    print("updateButtonView(updateType)-"..updateType)
    local freindBtnImg          = PATH_CCS_RES.."haoyou_bq_haoyou_1.png"
    local friendBtnimg_di       = PATH_CCS_RES.."haoyou_bq_haoyou_2.png"
    local addFriendBtnImg       = PATH_CCS_RES.."haoyou_bq_tianjia_1.png" 
    local addFriendBtnImg_di    = PATH_CCS_RES.."haoyou_bq_tianjia_2.png" 
    local giftImg               = PATH_CCS_RES.."haoyou_bq_liwu_1.png" 
    local giftImg_di            = PATH_CCS_RES.."haoyou_bq_liwu_2.png"  

    if updateType == 1 then     
        m_friendListBtn:loadTextures(freindBtnImg,friendBtnimg_di,"")
        m_addFriendBtn:loadTextures(addFriendBtnImg_di,addFriendBtnImg,"")
        m_allGigtBtn:loadTextures(giftImg_di,giftImg,"")  

        m_onKeyGiftBtn:setPosition(m_LeftBtnPos)
        m_onKeyRecommandBtn:setPosition(m_HidePosition)
        m_oneKeyTakeGiftsBtn:setPosition(m_HidePosition)        
    elseif updateType == 2 then
        m_friendListBtn:loadTextures(friendBtnimg_di,freindBtnImg,"")
        m_addFriendBtn:loadTextures(addFriendBtnImg,addFriendBtnImg_di,"")
        m_allGigtBtn:loadTextures(giftImg_di,giftImg,"") 

        m_onKeyGiftBtn:setPosition(m_HidePosition)
        m_onKeyRecommandBtn:setPosition(m_LeftBtnPos)
        m_oneKeyTakeGiftsBtn:setPosition(m_HidePosition)            
    elseif updateType == 3 then
        m_friendListBtn:loadTextures(friendBtnimg_di,freindBtnImg,"")
        m_addFriendBtn:loadTextures(addFriendBtnImg_di,addFriendBtnImg,"")
        m_allGigtBtn:loadTextures(giftImg,giftImg_di,"") 

        m_onKeyGiftBtn:setPosition(m_HidePosition)
        m_onKeyRecommandBtn:setPosition(m_HidePosition)
        m_oneKeyTakeGiftsBtn:setPosition(m_LeftBtnPos)               
    end
end
function create()
    if(not m_isCreate) then
        m_isCreate = true;
        m_rootLayer = CCLayer:create();
        m_rootLayer:retain();
        local UISource = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "Friends_Main.json");
        m_UILayout = TouchGroup:create();
        m_UILayout:addWidget(UISource);
        m_rootLayer:addChild(m_UILayout);       
        m_friendListBtn     = tolua.cast(m_UILayout:getWidgetByName("Button_9"),  "Button")     
        m_friendListBtn:addTouchEventListener(showFriendList)   
        m_addFriendBtn      = tolua.cast(m_UILayout:getWidgetByName("Button_11"), "Button")  
        m_addFriendBtn:addTouchEventListener(addFriendOnClick)          
        m_allGigtBtn        = tolua.cast(m_UILayout:getWidgetByName("Button_10"), "Button")
        m_allGigtBtn:addTouchEventListener(allGiftOnClick)               
        m_onKeyGiftBtn      = tolua.cast(m_UILayout:getWidgetByName("Button_32"), "Button") 
        m_onKeyGiftBtn:addTouchEventListener(oneKeyGiftOnClick)            
        m_onKeyRecommandBtn = tolua.cast(m_UILayout:getWidgetByName("Button_32_0"), "Button")  
        m_onKeyRecommandBtn:addTouchEventListener(oneKeyRecommandOnClick)      
        m_oneKeyTakeGiftsBtn= tolua.cast(m_UILayout:getWidgetByName("Button_32_1"), "Button") 
        m_oneKeyTakeGiftsBtn:addTouchEventListener(oneKeyTakeGiftOnClick)      
        m_searchConfirmBtn  = tolua.cast(m_UILayout:getWidgetByName("Button_17"), "Button")   
        m_searchConfirmBtn:addTouchEventListener(searchConfirmOnClick)    
        m_itemListPanel     = tolua.cast(m_UILayout:getWidgetByName("ListView_27"), "ListView") 
        -- local closeBtn  = tolua.cast(m_UILayout:getWidgetByName("Button_19"), "Button")   
        -- closeBtn:addTouchEventListener(colseOnClick)  
        local closePanel = tolua.cast(m_UILayout:getWidgetByName("root_panel"), "Layout")   
        closePanel:addTouchEventListener(colseOnClick)   

        m_newApplyFriend    = tolua.cast(m_UILayout:getWidgetByName("Image_57"),  "ImageView") 
        m_newApplyFriend:setVisible(false)
        m_newFriendGift     = tolua.cast(m_UILayout:getWidgetByName("Image_59"),  "ImageView") 
        m_newFriendGift:setVisible(false)      
        m_LeftBtnPos        = CCPoint(m_oneKeyTakeGiftsBtn:getPositionX(),m_oneKeyTakeGiftsBtn:getPositionY())

        m_searchInputBox    = tolua.cast(m_UILayout:getWidgetByName("TextField_16"), "TextField") 
        m_friendCountLabel  = tolua.cast(m_UILayout:getWidgetByName("Label_21_0"), "Label") 
    end
end
function updateMarkView()
    m_friendList = FriendsManager.getFriendList()
    local friendNum = #m_friendList
    if friendNum ==nil then
        friendNum = 0
    end
    m_friendCountLabel:setText(friendNum)



    m_applyList = FriendsManager.getApplyList()
    local applyNum =#m_applyList 
    if applyNum ==nil then
        applyNum =0
    end
    if applyNum>0 then 
        m_newApplyFriend:setVisible(true)
        local newApplyLabel =  tolua.cast(m_newApplyFriend:getChildByName("AtlasLabel_5"),  "LabelAtlas") 
        newApplyLabel:setStringValue(applyNum)
    else
        m_newApplyFriend:setVisible(false)
    end

    m_giftsData = FriendsManager.getGiftsData()
    local giftNum =#m_giftsData 
    if giftNum ==nil then
        giftNum =0
    end
    if giftNum>0 then 
        m_newFriendGift:setVisible(true)
        local newGiftLabel =  tolua.cast(m_newFriendGift:getChildByName("AtlasLabel_22"),  "LabelAtlas") 
        newGiftLabel:setStringValue(giftNum)
    else
        m_newFriendGift:setVisible(false)
    end    
end

function open()
    if (not m_isOpen) then
        create();
        m_isOpen = true;
        local uiLayer = getGameLayer(SCENE_UI_LAYER);
        uiLayer:addChild(m_rootLayer);

        initListView(1)
        updateMarkView()
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
    end
end
