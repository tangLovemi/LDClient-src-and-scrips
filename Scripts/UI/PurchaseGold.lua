--
-- Author: Gao Jiefeng
-- Date: 2015-04-29 14:36:58
--
module("PurchaseGold", package.seeall)

local m_isCreate = false;
local m_isOpen = false;
local m_rootLayer = nil;
local m_uiLayer = nil;
local m_UILayout = nil


local m_avilable_time = nil
local m_total_times = nil 
local m_cast_diamond = nil
local m_get_gold = nil
local m_timeCount = 0

local m_AnimationPath = PATH_RES_ACTORS .."dianjinbaoji.ExportJson"
local function closeOnClick(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
		UIManager.close("PurchaseGold");
		NotificationManager.onCloseCheck("PurchaseGold")
	end
end
local function makePurchase(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
		local avilableTime  = tonumber(m_avilable_time:getStringValue());
		if avilableTime>0 then 
			local cast = tonumber(m_cast_diamond:getStringValue());
			local currentDiamond = UserInfoManager.getRoleInfo("diamond");
			if (currentDiamond>cast) then
				NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_PURCHACE_GOLD, {1});
			else
				Util.showOperateResultPrompt("钻石不足了")
			end
		else
			Util.showOperateResultPrompt("没有点金次数了")
		end
	end
end


local function OnRecieveDataBack(messageType, messageData)
	NotificationManager.onLineCheck("PurchaseGold")
	if messageData.crit_times ~= 1 then --暴击
	    CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo(m_AnimationPath);
	    local armature = CCArmature:create("dianjinbaoji")
		if messageData.crit_times == 2 then
			armature:getAnimation():playWithIndex(0) 
		elseif messageData.crit_times == 4 then
			armature:getAnimation():playWithIndex(1) 
		elseif messageData.crit_times == 8 then
			armature:getAnimation():playWithIndex(2) 
		elseif messageData.crit_times == 16 then
			armature:getAnimation():playWithIndex(3) 			
		end
		Util.showOperateResultPrompt("获得了"..messageData.get_gold.."金币",armature)
	else
		Util.showOperateResultPrompt("获得了"..messageData.get_gold.."金币")
	end
	NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_PURCHACE_GOLD, {0});
end
local function OnRecieveDataInit(messageType, messageData)
	m_timeCount = messageData.avilable_time
	if m_isOpen then
		NotificationManager.onLineCheck("PurchaseGold")
		m_avilable_time:setStringValue(messageData.avilable_time);
		m_total_times:setStringValue(messageData.total_times);
		m_cast_diamond:setStringValue(messageData.cast_diamond);
		m_get_gold:setStringValue(messageData.get_gold);
	end
end
function getDataFromServer()
	NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_PURCHACE_GOLD, {0});
end

NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_DIAMOND_TO_GOLD_INFO, OnRecieveDataInit);
NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_DIAMOND_TOGOLD_DATA, OnRecieveDataBack);
function create()
    if(not m_isCreate) then
        m_isCreate = true;
        m_rootLayer = CCLayer:create();
        m_rootLayer:retain();
        local UISource = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "dianjin_1.json");
        m_UILayout = TouchGroup:create();
        m_UILayout:addWidget(UISource);
        m_rootLayer:addChild(m_UILayout);
        local clickBtn = tolua.cast(m_UILayout:getWidgetByName("Button_8"),"Button");
        clickBtn:addTouchEventListener(closeOnClick);

        local backgroundLayout = tolua.cast(m_UILayout:getWidgetByName("Panel_14"),"Layout");
        backgroundLayout:addTouchEventListener(closeOnClick);

		m_avilable_time = tolua.cast(m_UILayout:getWidgetByName("AtlasLabel_11"),"LabelAtlas");
		m_total_times = tolua.cast(m_UILayout:getWidgetByName("AtlasLabel_11_0"),"LabelAtlas");
		m_cast_diamond = tolua.cast(m_UILayout:getWidgetByName("AtlasLabel_24"),"LabelAtlas");
		m_get_gold = tolua.cast(m_UILayout:getWidgetByName("AtlasLabel_24_0"),"LabelAtlas");
		local purchaseBtn = tolua.cast(m_UILayout:getWidgetByName("Button_27"),"Button");
		purchaseBtn:addTouchEventListener(makePurchase);



		m_avilable_time:setStringValue("0");
		m_total_times:setStringValue("0");
		m_cast_diamond:setStringValue("0");
		m_get_gold:setStringValue("0");
    end
end

function open()
    if (not m_isOpen) then
        create();
        m_isOpen = true;
        local uiLayer = getGameLayer(SCENE_UI_LAYER);
        uiLayer:addChild(m_rootLayer);
        getDataFromServer()
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
function checkNotification()
	if m_timeCount> 0 then
		return true
	end
    return false
end

function checkNotification_login()
    return checkNotification()
end
function checkNotification_line()
    return checkNotification()
end
function checkNotification_close()
    return checkNotification()
end