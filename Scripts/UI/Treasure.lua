module("Treasure",package.seeall)

require "UI/Hire"

WHITE_QUALITY    = 1
GREEN_QUALITY	 = 2
BLUE_QUALITY     = 3
PURPlE_QUALITY   = 4
ORANGE_QUALITY   = 5

COMMON_PRODUCT   = 1
ADVANCE_PRODUCT  = 2
TREASURE_PRODUCT = 3

local m_rootLayer = nil;
local m_productLevel = nil;
local m_qualityLevel = nil;

REQUIREST_OPEN = 2;
REQUIREST_FLUSH = 4;

SURE_SUCCESS = 1;
SURE_FAIL_COUNT = 2;
SURE_FAIL_TIME = 3;

COOLINGTIME = 1 * 60;

local scheduler = CCDirector:sharedDirector():getScheduler();
local m_schedulerEntry               = nil;   --定时器


local function sendDelayMessage()
	-- body
	NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_ESCORT, {4,0});
	scheduler:unscheduleScriptEntry(m_schedulerEntry);
end 

local function updateLabelTime(dt)
	-- body
	sendDelayMessage();
end


local function sureTheServer(sureType)
	-- body
	if sureType == SURE_SUCCESS then
		CCLuaLog("押镖开始!");
		m_schedulerEntry = scheduler:scheduleScriptFunc(updateLabelTime, COOLINGTIME, false);
		UIManager.close("Treasure");
	end

	if sureType == SURE_FAIL_TIME then
		CCLuaLog("失败，镖令不足！");
	end

	if sureType == SURE_FAIL_COUNT then
		CCLuaLog("失败，冷却时间不够！");
	end

end 

local function receiveDataFromServer(messageType, messageData)
	-- body
	if messageType == NETWORK_MESSAGE_RECEIVE_ESCORT_QUALITY then
		CCLuaLog(messageData.quality);
		m_qualityLevel = messageData.quality;
	end

	if messageType == NETWORK_MESSAGE_RECEIVE_ESCORT_SURE then
		local sureType = messageData.type;
		sureTheServer(sureType);
	end

	if messageType == NETWORK_MESSAGE_RECEIVE_ESCORT_END then
		local coolingTime = messageData.time;
		CCLuaLog("messageType:"..messageType);
		CCLuaLog("coolingTime:"..coolingTime);
		if coolingTime == 0 then
			CCLuaLog("运镖成功！");
			scheduler:unscheduleScriptEntry(m_schedulerEntry);
		else
			m_schedulerEntry = scheduler:scheduleScriptFunc(updateLabelTime, coolingTime, false);
		end
	end
end

local function enterHireInterFace()
	-- body
	
	UIManager.open("Hire");

end

local function exitTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then
	   UIManager.close("Treasure")
	end
end


local function hireTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then

	   enterHireInterFace();
	   UIManager.close("Treasure");
	end
end 

local function imProveQuality()
	-- body
	if m_qualityLevel == ORANGE_QUALITY then
		CCLuaLog("无法提升品质，已经是最高了！");
		return;
	end

	local qualityLevel = math.random(5);

	if m_qualityLevel < qualityLevel then
		m_qualityLevel  = qualityLevel;
	else 
		m_qualityLevel = m_qualityLevel + 1;
	end

	if m_qualityLevel == 2 then
		local str = "你的品质提升到了绿色!";
		CCLuaLog(str);
	elseif m_qualityLevel == 3 then
		local str = "你的品质提升到了蓝色!";
		CCLuaLog(str);
	elseif m_qualityLevel == 4 then
		local str = "你的品质提升到了紫色!";
		CCLuaLog(str);
	elseif m_qualityLevel == 5 then
		local str = "你的品质提升到了橙色!";
		CCLuaLog(str);
	end

end 

local function flushTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then
		if m_qualityLevel == ORANGE_QUALITY  then
			CCLuaLog("无法提升品质，已经是最高了！")
		else
			NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_ESCORT, {2,4});
		end
	end

end 

local function sureTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then

	   NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_ESCORT, {3,4});

	end

end 

function setProductLevel(productLevel)
	-- body
	m_productLevel = productLevel;
	NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_ESCORT, {2,m_productLevel});
end

local function initVariables()
	-- body
	m_rootLayer = nil;
	m_productLevel = nil;
	m_qualityLevel = nil;
end

function open()
	-- body
	create();
	local uiLayer = getGameLayer(SCENE_UI_LAYER);
	uiLayer:addChild(m_rootLayer);
	local str = "现在进入的是" .. m_productLevel;
	CCLuaLog(str);

end

function close()
	-- body
	local  uiLayer = getGameLayer(SCENE_UI_LAYER);
	uiLayer:removeChild(m_rootLayer,false);
end

function create()
	-- body
	m_rootLayer = CCLayer:create();
	local uiLayout = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "Treasures.json");
	local uiLayer = TouchGroup:create();
    uiLayer:addWidget(uiLayout);
    m_rootLayer:addChild(uiLayer);
    -- m_rootLayer:retain();



    local exit = uiLayer:getWidgetByName("exit_btn");
    exit:addTouchEventListener(exitTouchEvent);

    local hireBtn = uiLayer:getWidgetByName("hire_btn");
    hireBtn:addTouchEventListener(hireTouchEvent);

    local flushBtn = uiLayer:getWidgetByName("flush_btn");
    flushBtn:addTouchEventListener(flushTouchEvent);

    local sureBtn = uiLayer:getWidgetByName("sure_btn");
    sureBtn:addTouchEventListener(sureTouchEvent);

    m_qualityLevel = WHITE_QUALITY;

    NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_ESCORT_QUALITY, receiveDataFromServer);
    NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_ESCORT_SURE, receiveDataFromServer);
    NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_ESCORT_END, receiveDataFromServer);
end

function remove()
	-- body
	m_rootLayer:removeAllChildrenWithCleanup(true);
	m_rootLayer:release();
	initVariables();
end