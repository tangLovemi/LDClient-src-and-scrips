--
-- Author: Gao Jiefeng
-- Date: 2015-03-27 14:26:15
--
module("FriendRecommandUI", package.seeall)

local m_isCreate = false;
local m_isOpen = false;
local m_rootLayer = nil;
local m_uiLayer = nil;
local m_UILayout = nil


local m_itemBasePanel = nil
local m_itemBase      = nil

local m_addMarkImg = nil
local m_recommandList = nil
local m_addAllBtn   = nil
local m_changeRecommandList = nil
local function addAllFriend(sender,eventType)
    if eventType == TOUCH_EVENT_TYPE_END then
        local userNames = ""        
        for k,v in pairs(m_recommandList) do
            userNames = userNames..v.name..","

        end
        local function addOneSucess(index)
            if index ==2 then
                -- stateImg:loadTexture(PATH_CCS_RES.."friend_img_ytj.png")
                -- sender:setTouchEnabled(false)
                initItemsPanel({})--传空表，清空所有的
                print("addAllfriend...............................")
            end
        end
        FriendsManager.applyAddFriendBySearch(userNames,2,addOneSucess)    

    end
end
local function changeFriendList(sender,eventType)
    if eventType == TOUCH_EVENT_TYPE_END then
        FriendsManager.getRecommandListData(initItemsPanel)
    end
end

local function addOneFriend(sender,eventType)
    if eventType == TOUCH_EVENT_TYPE_END then
        itemClickedId = sender:getTag()-1100        
        -- local stateImg = tolua.cast(sender:getChildByName("anj_img"), "ImageView"); 

        local function addOneSucess(index)
            if index ==2 then
                -- stateImg:loadTexture(PATH_CCS_RES.."friend_img_ytj.png")
                sender:setTouchEnabled(false)
            end
        end
        local userName = m_recommandList[itemClickedId].name
        FriendsManager.applyAddFriendBySearch(userName,2,addOneSucess)

    end
end

function initItemsPanel(recommandList)
    
    m_recommandList = recommandList
    if #recommandList<8 then

        for i=8,#recommandList+1,-1 do
            local item = m_itemBasePanel:getChildByTag(1000+i)
            item:setVisible(false)
        end
    end
    for k,v in pairs(recommandList) do
        local item = m_itemBasePanel:getChildByTag(1000+k)
        item:setVisible(true)
        local nameLabel = tolua.cast(item:getChildByName("wjiamzi_label"),"Label")
        local levelLabel = tolua.cast(item:getChildByName("dji_labelNum"),"LabelAtlas")        
        local tempPanel =  tolua.cast(item:getChildByName("rwuxx_panel"), "Layout"); 
        local hairColorImg = tolua.cast(tempPanel:getChildByName("Image_8"), "ImageView"); 
        local faceImg = tolua.cast(tempPanel:getChildByName("Image_6"), "ImageView"); 
        local coatImg = tolua.cast(tempPanel:getChildByName("Image_5"), "ImageView");
        local addBtn = tolua.cast(item:getChildByName("addFri_btn"), "Button");
        addBtn:setTag(1100+k)

        hairColorImg:loadTexture(Util.getHairImgPath(v.hair,v.haircolor))
        faceImg:loadTexture(Util.getFaceImgPath(v.face))
        coatImg:loadTexture(Util.getCoatImgPath(v.coat))
        nameLabel:setText(v.name)
        levelLabel:setStringValue(v.level)
        addBtn:addTouchEventListener(addOneFriend)

    end


end

local function closeOnClick(sender,eventType)
    if eventType == TOUCH_EVENT_TYPE_END then
        FriendRecommandUI.close()
    end
end
function create()
    if(not m_isCreate) then
        m_isCreate = true;
        m_rootLayer = CCLayer:create();
        m_rootLayer:retain();
        local UISource = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "Friends_RecommendItem.json");
        m_UILayout = TouchGroup:create();
        m_UILayout:addWidget(UISource);
        m_rootLayer:addChild(m_UILayout);
        local rootLayer = tolua.cast(m_UILayout:getWidgetByName("root_panel"), "Layout") 
        rootLayer:addTouchEventListener(closeOnClick)
        m_itemBasePanel = tolua.cast(m_UILayout:getWidgetByName("info_panel"), "Layout") 
        m_itemBase      = tolua.cast(m_UILayout:getWidgetByName("zikuang_panel"), "Layout") 
        m_addAllBtn     = tolua.cast(m_UILayout:getWidgetByName("anj_btn"), "Button")
        m_changeRecommandList     = tolua.cast(m_UILayout:getWidgetByName("anj1_btn"), "Button")  
        m_addAllBtn:addTouchEventListener(addAllFriend)
        m_changeRecommandList:addTouchEventListener(changeFriendList)


        local itemCount = 1
        for i=1,2 do
            for j=1,4 do
                local item = m_itemBase:clone()
                item:setPosition(CCPoint(5+200*(j-1),150*(2-i)-30))
                item:setTag(1000+itemCount)
                item:setVisible(false)
                itemCount = itemCount+1
                m_itemBasePanel:addChild(item)
            end
        end
    end
end

function open()
    if (not m_isOpen) then
        create();
        m_isOpen = true;
        local uiLayer = getGameLayer(SCENE_UI_LAYER);
        uiLayer:addChild(m_rootLayer);
        -- initItemsPanel()
        FriendsManager.getRecommandListData(initItemsPanel)
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
