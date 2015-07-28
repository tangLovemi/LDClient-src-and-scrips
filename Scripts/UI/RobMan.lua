module("RobMan",package.seeall)


require "UI/Rob"

COMMONROB_LEVEL   = 1
ADVANCEROB_LEVEL  = 2
TOPROB_LEVEL      = 3

local m_rootLayer = nil;

local m_robCountLabel = nil;
local m_count = nil;
local m_time = 0;


local scheduler = CCDirector:sharedDirector():getScheduler();
local m_schedulerEntry               = nil;   --定时器

local  function updateLabelTime(dt)
	-- body
	if m_time <= 0 then
		m_time = 0;
		return;
	end

	m_time = m_time - 1;

end

local function exitTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then
	  	UIManager.close("RobMan");
	end
end

local function enterRobInterface(tag)
	-- body
	Rob.setRobLevel(tag,m_time);
	UIManager.open("Rob");
	UIManager.close("RobMan");
end 

local function receiveDataFromServer(messageType,messageData)
	-- body
	if messageType == NETWORK_MESSAGE_RECEIVE_ROB_OPEN then
		CCLuaLog("num:"..messageData.num);
		CCLuaLog("num:"..messageData.time);
		m_robCountLabel:setText(messageData.num);
		m_count = messageData.num;
		m_time = messageData.time;
	end
end

local function commonRobTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then
		enterRobInterface(COMMONROB_LEVEL);
	end
end 

local function advanceRobTouchEvent(sender,eventType)
	-- body

	if eventType == TOUCH_EVENT_TYPE_END then
		enterRobInterface(ADVANCEROB_LEVEL);
	end
end

local function topRobTouchEvent(sender,eventType)
	-- body

	if eventType == TOUCH_EVENT_TYPE_END then
		enterRobInterface(TOPROB_LEVEL);
	end
end 

function open()
	-- body
	create();
	local uiLayer = getGameLayer(SCENE_UI_LAYER);
	uiLayer:addChild(m_rootLayer);
	m_count = 0;
	
	NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_ROB, {1,0});

	m_schedulerEntry = scheduler:scheduleScriptFunc(updateLabelTime, 1, false);
end

function close()
	-- body
	local  uiLayer = getGameLayer(SCENE_UI_LAYER);
	uiLayer:removeChild(m_rootLayer,false);
	
	m_count = nil;
	m_time = 0;
	scheduler:unscheduleScriptEntry(m_schedulerEntry);

end

function create()
	-- body
	m_rootLayer = CCLayer:create();
	local uiLayout = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "RobMan.json");
	local uiLayer = TouchGroup:create();
    uiLayer:addWidget(uiLayout);
    m_rootLayer:addChild(uiLayer);

    -- m_rootLayer:retain();
    local exit = uiLayer:getWidgetByName("exit_btn");
    exit:addTouchEventListener(exitTouchEvent);

    local commonRobBtn = uiLayer:getWidgetByName("customRob_btn");
    commonRobBtn:addTouchEventListener(commonRobTouchEvent);

    local advanceRobBtn = uiLayer:getWidgetByName("advaceRob_btn");
    advanceRobBtn:addTouchEventListener(advanceRobTouchEvent);

    local topRobBtn = uiLayer:getWidgetByName("topRob_btn");
    topRobBtn:addTouchEventListener(topRobTouchEvent);

    local robCountLabel = uiLayer:getWidgetByName("robCountLabel");
    m_robCountLabel = tolua.cast(robCountLabel,"Label");

    NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_ROB_OPEN, receiveDataFromServer);
end

function remove()
	-- body
	m_rootLayer:removeAllChildrenWithCleanup(true);
	m_rootLayer:release();
	m_rootLayer = nil;
	m_robCountLabel = nil;

	NetMessageManager.unregisterMessage(NETWORK_MESSAGE_RECEIVE_ROB_OPEN, receiveDataFromServer);

end

