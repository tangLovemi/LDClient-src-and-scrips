module("Escort", package.seeall)

require "UI/Treasure"


COMMON_PRODUCT   = 1
ADVANCE_PRODUCT  = 2
TREASURE_PRODUCT = 3


local m_rootLayer = nil;
local m_escortCount = 5;
local m_escortCountLabel = nil;




local function setEscortCount()
	-- body
	m_escortCount = m_escortCount - 1;
	PlayerInfo.setEscortCount(m_escortCount);
end 

local function setEscortLabel()
	-- body
	m_escortCountLabel:setText(m_escortCount);
end

local function receiveDataFromServer(messageType, messageData)
	-- body
	if messageType == NETWORK_MESSAGE_RECEIVE_ESCORT_OPEN then
		CCLuaLog(messageData.num);
		m_escortCount = messageData.num;
		setEscortLabel();
	end

end 

local function exitTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then
	   UIManager.close("Escort");
	end
end

local function openTreasure(productLevel)
	-- body
	Treasure.setProductLevel(productLevel);
	UIManager.open("Treasure");
	UIManager.close("Escort");
end 

local function enterTreasure(tag)
	-- body
	setEscortCount();
	openTreasure(tag);

end 

local function customProductTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then

	   local escortCount = m_escortCount;
	   if  escortCount ~= 0 then
	   	   enterTreasure(COMMON_PRODUCT);
	   end;

	end
end

local function advanceProductTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then

	   local escortCount = m_escortCount;

	   if  escortCount ~= 0 then
	   	   enterTreasure(ADVANCE_PRODUCT);
	   end;

	end
end

local function treasureTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then

	   local escortCount = m_escortCount;

	   if  escortCount ~= 0 then
	   	   enterTreasure(TREASURE_PRODUCT);
	   end;

	end
end

local function initVariables()
	-- body
	m_rootLayer = nil;
	m_escortCount = 0;
end

function open()
	-- body
	create();
	local uiLayer = getGameLayer(SCENE_UI_LAYER);
	uiLayer:addChild(m_rootLayer);
	NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_ESCORT, {1,0});
end

function create()
	-- body
	m_rootLayer = CCLayer:create();
    
	local uiLayout = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "Escort.json");
	local uiLayer = TouchGroup:create();
    uiLayer:addWidget(uiLayout);
    m_rootLayer:addChild(uiLayer);
    -- m_rootLayer:retain();
  	
  	m_escortCount = PlayerInfo.getEscortCount();

    local exit = uiLayer:getWidgetByName("exit_btn");
    exit:addTouchEventListener(exitTouchEvent);

    local customProductBtn = uiLayer:getWidgetByName("customProduct_btn");
    customProductBtn:addTouchEventListener(customProductTouchEvent);

    local advanceProductBtn = uiLayer:getWidgetByName("advanceProduct_btn");
    advanceProductBtn:addTouchEventListener(advanceProductTouchEvent);

    local treasureBtn = uiLayer:getWidgetByName("treasure_btn");
    treasureBtn:addTouchEventListener(treasureTouchEvent);

    local escortCountLabel = uiLayer:getWidgetByName("countNumber");
    escortCountLabel = tolua.cast(escortCountLabel,"Label");
   	m_escortCountLabel = escortCountLabel;

   	setEscortLabel();

	NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_ESCORT_OPEN, receiveDataFromServer);
	
	NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_ESCORT_SURE, receiveDataFromServer);
end


function close()
	-- body
	setEscortLabel();
	local  uiLayer = getGameLayer(SCENE_UI_LAYER);
	uiLayer:removeChild(m_rootLayer,false);

end

function remove()
	-- body
	m_rootLayer:removeAllChildrenWithCleanup(true);	
	m_rootLayer:release();
	initVariables();
end
