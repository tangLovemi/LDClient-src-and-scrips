--
-- Author: Your Name
-- Date: 2015-06-04 17:02:00
--
module("WishMain", package.seeall)

local m_rootLayer = nil
local m_UILayout= nil
local m_isOpen = false
local m_isCreate = false;
local m_goldbtn = nil
local m_diamondbtn = nil
local m_diamond10btn = nil
local m_freeImg1 = PATH_CCS_RES.."xuyuan_mianfei_1.png"
local m_freeImg2 = PATH_CCS_RES.."xuyuan_mianfei_2.png"
local m_chargeImg1 = PATH_CCS_RES.."xuyuanyici_1.png"
local m_chargeImg2 = PATH_CCS_RES.."xuyuanyici_2.png"
local m_scheduler = CCDirector:sharedDirector():getScheduler();
local m_schedulerEntry = nil;

local m_goldMinusLabel= nil
local m_GoldSecoundLabel= nil
local m_GoldCountDown =0 

local m_DiamondMinusLabel= nil
local m_DiamondHourLabel= nil
local m_DiamondSecoundLabel= nil
local m_DiamondCountDown =0 

function openItemDetailUI(messageData)
	UIManager.open("WishItemEffect",messageData)
end
local function choukaOnClick(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
		if(GoodsManager.isBackpackFull_1()) then
			BackpackFullTishi.show();
		else
			WishManager.setBaseInfoCallback(initBaseInfo)
			local clicktype =sender:getTag()-10000 
			if clicktype==1 then
				WishManager.chouchaWork(1,1,openItemDetailUI)
			elseif clicktype==2 then
				WishManager.chouchaWork(2,1,openItemDetailUI)
			elseif clicktype==3 then
				WishManager.chouchaWork(2,10,openItemDetailUI)
			end
		end
	end
end
local function closeOnClick(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then	
		UIManager.close("WishMain")
	end

end
function updateFrame()
	if m_GoldCountDown ==0 then
	else
		m_GoldCountDown = m_GoldCountDown-1
		local minus = math.floor(m_GoldCountDown/60)
		if minus<10 then 
			minus = "0"..minus
		end
		local secound = m_GoldCountDown%60
		if secound<10 then 
			secound = "0"..secound
		end
		m_goldMinusLabel:setStringValue(minus)
		m_GoldSecoundLabel:setStringValue(secound)
	end
	if m_DiamondCountDown ==0 then
	else
		m_DiamondCountDown = m_DiamondCountDown-1
		local hour = math.floor(m_DiamondCountDown/3600)
		if hour<10 then 
			hour = "0"..hour
		end
		local minus = math.floor((m_DiamondCountDown-hour*3600)/60)
		if minus<10 then 
			minus = "0"..minus
		end
		local secound = m_DiamondCountDown%60
		if secound<10 then 
			secound = "0"..secound
		end
		m_DiamondSecoundLabel:setStringValue(secound) 
		m_DiamondMinusLabel:setStringValue(minus) 
		m_DiamondHourLabel:setStringValue(hour) 

	end
end
function initBaseInfo(messageData)
	if not m_isOpen then
		return
	end
	local gold_FreeTime = tonumber(messageData.gold_time)
	local diamond_FreeTime = tonumber(messageData.gold_time)
	local will_get = tonumber(messageData.remain_time)
	local gold_countdown = tonumber(messageData.gold_countdown)
	local diamond_countdown = tonumber(messageData.diamond_countdown)
	local gold_drawPanel = tolua.cast(m_UILayout:getWidgetByName("Panel_1"), "Layout")
	local diamond_drawPanel = tolua.cast(m_UILayout:getWidgetByName("Panel_1_0"), "Layout")

	local will_getLabel = tolua.cast(m_UILayout:getWidgetByName("AtlasLabel_86"), "LabelAtlas")
	will_getLabel:setStringValue(will_get)

	--设置金币抽卡
	if gold_countdown == 0 then
		local baseImage = tolua.cast(gold_drawPanel:getChildByName("Image_5"), "ImageView")
		local countdownPanel = tolua.cast(baseImage:getChildByName("Panel_9"), "Layout")
		if gold_FreeTime ==0 then
			countdownPanel:setVisible(false)
		else
			countdownPanel:setVisible(false)
			local castImage = tolua.cast(baseImage:getChildByName("Image_14"), "ImageView")
			castImage:setVisible(false)
			m_goldbtn:loadTextures(m_freeImg1,m_freeImg2,"")
		end
	else
		local baseImage = tolua.cast(gold_drawPanel:getChildByName("Image_5"), "ImageView")
		local countdownPanel = tolua.cast(baseImage:getChildByName("Panel_9"), "Layout")
		countdownPanel:setVisible(true)
		local castImage = tolua.cast(baseImage:getChildByName("Image_14"), "ImageView")
		castImage:setVisible(true)
		m_GoldSecoundLabel = tolua.cast(countdownPanel:getChildByName("AtlasLabel_3_1"), "LabelAtlas")
		m_goldMinusLabel = tolua.cast(countdownPanel:getChildByName("AtlasLabel_3_0"), "LabelAtlas")
		m_GoldCountDown = gold_countdown
		m_goldbtn:loadTextures(m_chargeImg1,m_chargeImg1,"")

	end

	--设置钻石抽卡
	if diamond_countdown == 0 then
		local baseImage = tolua.cast(diamond_drawPanel:getChildByName("Image_5"), "ImageView")
		local countdownPanel = tolua.cast(baseImage:getChildByName("Panel_9"), "Layout")
		countdownPanel:setVisible(false)
		local castImage = tolua.cast(baseImage:getChildByName("Image_14"), "ImageView")
		castImage:setVisible(false)
		m_diamondbtn:loadTextures(m_freeImg1,m_freeImg2,"")
	else
		local baseImage = tolua.cast(diamond_drawPanel:getChildByName("Image_5"), "ImageView")
		local countdownPanel = tolua.cast(baseImage:getChildByName("Panel_9"), "Layout")
		countdownPanel:setVisible(true)
		local castImage = tolua.cast(baseImage:getChildByName("Image_14"), "ImageView")
		castImage:setVisible(true)
		m_DiamondSecoundLabel = tolua.cast(countdownPanel:getChildByName("AtlasLabel_3_1"), "LabelAtlas")
		m_DiamondMinusLabel = tolua.cast(countdownPanel:getChildByName("AtlasLabel_3_0"), "LabelAtlas")
		m_DiamondHourLabel = tolua.cast(countdownPanel:getChildByName("AtlasLabel_3"), "LabelAtlas")
		m_DiamondCountDown = diamond_countdown
		m_diamondbtn:loadTextures(m_chargeImg1,m_chargeImg1,"")

	end

	if( m_schedulerEntry ~= nil) then
		m_scheduler:unscheduleScriptEntry(m_schedulerEntry);
		m_schedulerEntry = nil
	end

	m_schedulerEntry = m_scheduler:scheduleScriptFunc(updateFrame, 1, false);
	m_rootLayer:setVisible(true)

end

function create()
	if(m_isCreate == false)then
		m_rootLayer = CCLayer:create();
		m_rootLayer:retain()  
		local UISource = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "xuyuan_1.json");
	    m_UILayout = TouchGroup:create();
	    m_UILayout:addWidget(UISource);
	    m_rootLayer:addChild(m_UILayout);
	    local panel = tolua.cast(m_UILayout:getWidgetByName("Panel_14"), "Layout")
	    panel:addTouchEventListener(closeOnClick);
	    m_isCreate = true;
	end

end

function open(messageData)
    if (not m_isOpen) then
        create();
        m_isOpen = true;
        local uiLayer = getGameLayer(SCENE_UI_LAYER);
        uiLayer:addChild(m_rootLayer);
        m_rootLayer:setVisible(false)
        -- WishManager.registerMessage()
        WishManager.getWishBaseData(initBaseInfo)
        m_goldbtn = tolua.cast(m_UILayout:getWidgetByName("Button_17"), "Button")
        m_goldbtn:setTag(10001)
        m_goldbtn:addTouchEventListener(choukaOnClick);
        m_diamondbtn = tolua.cast(m_UILayout:getWidgetByName("Button_18"), "Button")
        m_diamondbtn:setTag(10002)
        m_diamondbtn:addTouchEventListener(choukaOnClick);
        m_diamond10btn = tolua.cast(m_UILayout:getWidgetByName("Button_19"), "Button")
        m_diamond10btn:setTag(10003)
        m_diamond10btn:addTouchEventListener(choukaOnClick);
        
    end
end
function close()
	if(m_isOpen)then
		m_isOpen = false
		-- WishManager.unRegisterMessage()
		local  uiLayer = getGameLayer(SCENE_UI_LAYER);
		uiLayer:removeChild(m_rootLayer,false);
		if( m_schedulerEntry ~= nil) then
			m_scheduler:unscheduleScriptEntry(m_schedulerEntry);
			m_schedulerEntry = nil
		end
		NotificationManager.onLineCheck("WishManager")
	end

end

function remove()
	if(m_isCreate)then
		m_rootLayer:removeAllChildrenWithCleanup(true);	
		m_rootLayer:release();
		m_rootLayer= nil
		m_isCreate = false;
	end

end
