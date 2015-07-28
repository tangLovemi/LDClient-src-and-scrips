module("Rob",package.seeall)

require "UI/CoolingTime"


local scheduler = CCDirector:sharedDirector():getScheduler();
local m_schedulerEntry               = nil;   --定时器

local m_rootLayer           = nil;
local m_robLevel            = nil;
local m_robplayerTable      = {};
local m_uiLayer   	        = nil;
local m_selectedTag         = nil;
local m_lastSelectTag       = nil;

local m_timeLabel           = nil;
local m_timeData            = 0;


COMMONROB_LEVEL   = 1
ADVANCEROB_LEVEL  = 2
TOPROB_LEVEL      = 3

NAMEINDEX         = 1
LEVELINDEX        = 2
IMAGEINDEX        = 3

SELECT_COLOR      = ccc3(255,0,0)
DISSELECT_COLOR   = ccc3(255,255,255)

ROBCOOLINGTIME_INDEX   = 1

ROB_INQUIRE = 2;


ROB_SUCEESS = 1;
ROB_FAILT   = 2;
ROB_COUNT   = 3;
ROB_TIME    = 4;
ROB_NOONE   = 5;

local function exitTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then

		CoolingTime.saveCoolingtime(m_timeData,ROBCOOLINGTIME_INDEX);
		close();

	end

end

local function initTheHeadImage(rolePanel,robplayerData)
	-- body
end

-- 选中后改变颜色，前一个颜色还原
local function changeLabelColor(tag) 
	-- body

	local panelStr = "rolePanel" .. tag;
	local rolePanel = m_uiLayer:getWidgetByName(panelStr);
	local nameLable = tolua.cast(rolePanel:getChildByName("nameLabel"),"Label");
	local levelLabel = tolua.cast(rolePanel:getChildByName("level"),"Label");

	nameLable:setColor(SELECT_COLOR);
	levelLabel:setColor(SELECT_COLOR);

	if m_lastSelectTag then
		panelStr = "rolePanel" .. m_lastSelectTag;
		rolePanel = m_uiLayer:getWidgetByName(panelStr);
		nameLable = tolua.cast(rolePanel:getChildByName("nameLabel"),"Label");
		levelLabel = tolua.cast(rolePanel:getChildByName("level"),"Label");
		nameLable:setColor(DISSELECT_COLOR);
		levelLabel:setColor(DISSELECT_COLOR);
	end
	
	m_lastSelectTag = tag;
end 

local function pressPanelTouchEvent(sender,eventType)
	-- body
	local tag = sender:getTag();
	local count = #(m_robplayerTable);

	if eventType == TOUCH_EVENT_TYPE_END and tag ~= count + 1  then

		m_selectedTag = tag;
		changeLabelColor(tag);

	end
end


local function initData()
	-- body
	m_selectedTag 	= nil;
	m_lastSelectTag = nil;

	for i=1,5 do

			local panelStr = "rolePanel" .. i;
			local rolePanel = m_uiLayer:getWidgetByName(panelStr);
			rolePanel:setVisible(true);
			rolePanel:setTag(i);
			rolePanel:addTouchEventListener(pressPanelTouchEvent);
			local nameLable = tolua.cast(rolePanel:getChildByName("nameLabel"),"Label");
			local levelLabel = tolua.cast(rolePanel:getChildByName("level"),"Label");
			nameLable:setColor(DISSELECT_COLOR);
			levelLabel:setColor(DISSELECT_COLOR);
	end

	local robplayerTable = m_robplayerTable;

	for i=1,#robplayerTable do

		local robplayerData = robplayerTable[i];
		local panelStr = "rolePanel" .. i;
		local rolePanel = m_uiLayer:getWidgetByName(panelStr);


		local nameLable = tolua.cast(rolePanel:getChildByName("nameLabel"),"Label");
		local levelLabel = tolua.cast(rolePanel:getChildByName("level"),"Label");

		local nameStr = robplayerData.name;
		nameLable:setText(nameStr);

		local levelStr = robplayerData.lv;
		levelLabel:setText(levelStr);

		CCLuaLog(robplayerData.uid);
		initTheHeadImage(rolePanel,robplayerData);
	end

	local count = #robplayerTable;
	count = count + 1;

	for i=count,5 do
		local panelStr = "rolePanel" .. i;
		local rolePanel = m_uiLayer:getWidgetByName(panelStr);
		rolePanel:setVisible(false);
	end
	
end 


local function analysisPersonList(messageData)
	-- body
	CCLuaLog("刷新人物！");
	m_robplayerTable = messageData;


	initData();
end

local function enterThefight(isWin)
	-- body
	if isWin == true then
		CCLuaLog("进入战斗，战斗胜利！");
	else
		CCLuaLog("进入战斗，战斗失败！");
	end
end

local function robEnd(messageData)
	-- body
	if messageData.type == ROB_SUCEESS then
		enterThefight(true);
	end

	if messageData.type == ROB_FAILT then
		enterThefight(false);
	end

	if messageData.type == ROB_COUNT then
		CCLuaLog("劫镖数量已满！无法再截~");
	end

	if messageData.type == ROB_TIME then
		CCLuaLog("劫镖还在冷却时间！");
	end

	if messageData.type == ROB_NOONE then
		CCLuaLog("此人无法被劫镖！");
	end
end

local function receiveDataFromServer(messageType,messageData)
	-- body
	if messageType == NETWORK_MESSAGE_RECEIVE_ROB_PERSON then
		analysisPersonList(messageData);
		local count = #messageData;
		CCLuaLog("messageType:"..messageType .. "  count:"..count);
	end

	if messageType == NETWORK_MESSAGE_RECEIVE_ROB_SURE then
		robEnd(messageData)
	end
end




local function flushTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then
		NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_ROB, {ROB_INQUIRE,4});
	end
end 

local function sureTouchEvent(sender,eventType)
	-- body

	if eventType == TOUCH_EVENT_TYPE_END then

		if m_selectedTag then

			local robplayerData = m_robplayerTable[m_selectedTag];
			local nameStr = robplayerData.name;
			local uid = robplayerData.uid;
			CCLuaLog("你打劫的对象是:" .. nameStr .. "uid" .. uid);
		
			NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_ROBPERSON, {uid});

		else
			CCLuaLog("你没有选择打劫对象！");
		end

	end
end 

local function updateLabelTime(dt)
	-- body

	m_timeData = m_timeData - 1;
	if m_timeData <= 0 then	
		m_timeData = 0;
		return;
	end

	local timeStr = CoolingTime.timeChangeString(m_timeData);
	CCLuaLog(timeStr);
	m_timeLabel:setText(timeStr);

end 

local function initVariables()
	-- body
	m_rootLayer        = nil;
	m_robLevel         = nil;
	m_robplayerTable   = {};
	m_uiLayer   	   = nil;
	m_selectedTag      = nil;
	m_lastSelectTag    = nil;
	m_schedulerEntry   = nil;   --定时器
	m_timeLabel        = nil;
	m_timeData         = 0;
end

function open()
	-- body
	create();
	local uiLayer = getGameLayer(SCENE_UI_LAYER);
	uiLayer:addChild(m_rootLayer);

	CCLuaLog("你打开的是" .. m_robLevel);

	m_schedulerEntry = scheduler:scheduleScriptFunc(updateLabelTime, 1, false);

end

function close()
	-- body

	local uiLayer = getGameLayer(SCENE_UI_LAYER);
	uiLayer:removeChild(m_rootLayer,false);
	scheduler:unscheduleScriptEntry(m_schedulerEntry);
end

function setRobLevel(level,time)
	-- body
	m_robLevel = level;
	m_timeData = time;

	CCLuaLog("level"..level.."time:"..time)
	NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_ROB, {ROB_INQUIRE,level});
end

function create()
	-- body
	m_rootLayer = CCLayer:create();
	local uiLayout = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "Rob.json");
	local uiLayer = TouchGroup:create();
    uiLayer:addWidget(uiLayout);
    m_rootLayer:addChild(uiLayer);

    -- m_rootLayer:retain();

    local exitBtn = uiLayer:getWidgetByName("exit_btn");
    exitBtn:addTouchEventListener(exitTouchEvent);

    local flushBtn = uiLayer:getWidgetByName("flush_btn");
    flushBtn:addTouchEventListener(flushTouchEvent);

    local sureBtn = uiLayer:getWidgetByName("sure_btn");
    sureBtn:addTouchEventListener(sureTouchEvent);

    local timeLabel = uiLayer:getWidgetByName("timeDataLabel");
    timeLabel = tolua.cast(timeLabel,"Label");
    timeLabel:setText("00:00:00");
    m_timeLabel = timeLabel;


    
    m_uiLayer = uiLayer;
    initData();

    NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_ROB_PERSON, receiveDataFromServer);
    NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_ROB_SURE, receiveDataFromServer);
end

function remove()
	-- body
	m_rootLayer:removeAllChildrenWithCleanup(true);
	m_rootLayer:release();
	initVariables();

	NetMessageManager.unregisterMessage(NETWORK_MESSAGE_RECEIVE_ROB_PERSON, receiveDataFromServer);
    NetMessageManager.unregisterMessage(NETWORK_MESSAGE_RECEIVE_ROB_SURE, receiveDataFromServer);
end

