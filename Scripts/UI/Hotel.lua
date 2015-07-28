module("Hotel", package.seeall)

COMMONTAKETOUCH     = 1
ONETAKETOUCH        = 2
TENTAKETOUCH        = 3

COMMONCOST	        = 10
ONECOST             = 30
TENCOST             = 280	

GREENEQUIPMENT      = 1
BLUEEQUIPMENT       = 2
PURPLEEQUIPMENT     = 3	


PUREQUIPNUM 		= 125;
--颜色

COLOR_BLUE          = ccc3(0,0,255)
COLOR_WHITE         = ccc3(255,255,255)

COMMONLOTTERYTIME                    = 24     --hour
ONELOTERYTIME                        = 72     --hour 

local scheduler = CCDirector:sharedDirector():getScheduler();
local m_schedulerEntry               = nil;   --定时器
local m_rootLayer                    = nil;
local m_costGold                     = 0;
local m_getPurpleCount               = 0;     --得到将要得到紫装的次数(10次必爆紫色)
local m_freeCommomLotteryTimeLabel   = nil;
local m_freeOneLotteryTimeLabel      = nil;
local uiLayer                        = nil;

local m_oneTime                      = 0;     --高级抽的冷却时间
local m_commomTime                   = 0;     --普通抽的冷却时间

local m_currentTime_commonlottery    = 0;     --普通抽的当前时间
local m_lastTime_commonlottery       = 0;     --普通抽的上一次时间
local m_currentTime_onelottery       = 0;     --高级抽的当前时间
local m_lastTime_onelottery          = 0;     --高级抽的上一次时间

local m_subSum_commonlottery         = 0;     --普通抽的累计差时
local m_subSum_onelottery            = 0;     --高级抽的累计差时




local function changeProcessImageColor()
	-- body
	for i=1,9 do
		local processStr = string.format("process_%02d",i);
		local processImage = uiLayer:getWidgetByName(processStr);
		processImage = tolua.cast(processImage,"ImageView");
		processImage:setColor(COLOR_WHITE);
	end

	for i=1,m_getPurpleCount do
		local processStr = string.format("process_%02d",i);
		local processImage = uiLayer:getWidgetByName(processStr);
		processImage = tolua.cast(processImage,"ImageView");
		processImage:setColor(COLOR_BLUE);
	end

end


local function changePurCount(equipNum)
	-- body

	if equipNum >= PUREQUIPNUM then
		m_getPurpleCount = 0;
	else
		m_getPurpleCount = m_getPurpleCount + 1;
	end
	changeProcessImageColor();
end


local function receiveDataFromServer(messageType, messageData)
	-- body
	if messageType == NETWORK_MESSAGE_RECEIVE_HOTEL_TC then
		m_getPurpleCount = messageData.higherCount;
		m_commomTime = messageData.commonTime;
		m_oneTime = messageData.higherTime;
		CCLuaLog(messageData.commonTime);
		changeProcessImageColor();
	end

	if messageType == NETWORK_MESSAGE_RECEIVE_HOTEL_HIGHER then

		if m_oneTime == 0 then
			m_oneTime = 72 * 3600;
		end
		changePurCount(messageData.equip);
		CCLuaLog("equipNum:" .. messageData.equip);
	end

	if messageType == NETWORK_MESSAGE_RECEIVE_HOTEL_TEN then
		for i=1,#messageData do
			local equipNum = messageData[i];
			CCLuaLog("equipNum:" .. equipNum.equip);
		end
	end

	if messageType == NETWORK_MESSAGE_RECEIVE_HOTEL_COMMON then

		if m_commomTime == 0 then
			m_commomTime = 24 * 3600
		end

		CCLuaLog("equipNum:"..messageData.equip)
	end


end


local function tenTakeLottery()
	-- body
	NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_HOTEL_TEN, {true});
	
end

local function oneTakeLottery()
	-- body
	NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_HOTEL_HIGHER, {true});
	
end

local function commonTakeLottery()
	-- body
	
	NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_HOTEL_COMMON, {true});
	
end 

local function backTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then		
		--关闭定时器     	
        UIManager.close("Hotel");
	end
end

local function commonTakeTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then

		if m_commomTime == 0 or m_costGold ~= 0 then
			m_costGold = m_costGold - COMMONCOST;
	   		commonTakeLottery();
		end

	end
end

local function oneTakeTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then

		if m_oneTime == 0 or m_costGold ~= 0  then
			m_costGold = m_costGold - ONECOST;
	   		oneTakeLottery();
		end

	end
end

local function tenTakeTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then

		if  m_costGold ~= 0 then

			m_costGold = m_costGold - TENCOST;
	   		tenTakeLottery();
		end
	end
end

local function updateLabelTime(dt)
	-- body

	m_oneTime = m_oneTime - dt;
	m_commomTime = m_commomTime - dt;

	if m_oneTime <= 0 then
	   m_oneTime = 1;
	end

	if m_commomTime <= 0 then
	   m_commomTime = 1;
	end

	--高级抽的时间
	local hour        = m_oneTime / 3600;
	local hour1       = math.floor(hour);
	local oneTime1    = math.mod(m_oneTime,3600);
	local min         = math.floor(oneTime1 / 60);
	local sec         = math.floor(oneTime1);
	      sec         = math.mod(sec,60);

	local strTime = string.format("%02d:%02d:%02d",hour1,min,sec);
	m_freeOneLotteryTimeLabel:setText(strTime);

	--普通抽的时间
	hour              = m_commomTime / 3600;
	hour1             = math.floor(hour);
	local commomTime1 = math.mod(m_commomTime,3600);
	min               = math.floor(commomTime1 / 60);
	sec               = math.floor(commomTime1);
	sec               = math.mod(sec,60);
	strTime = string.format("%02d:%02d:%02d",hour1,min,sec);
	m_freeCommomLotteryTimeLabel:setText(strTime);

end 


local function requestTCFromSv()
	-- body
	NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_HOTEL_TC, {true});
	

end

local function initVariables()
	-- body
	
	m_schedulerEntry               = nil;   
	m_rootLayer                    = nil;
	m_costGold                     = 0;
	m_getPurpleCount               = 0;     
	m_freeCommomLotteryTimeLabel   = nil;
	m_freeOneLotteryTimeLabel      = nil;
	uiLayer                        = nil;

	m_oneTime                      = 0;    
	m_commomTime                   = 0;    

	m_currentTime_commonlottery    = 0;     
	m_lastTime_commonlottery       = 0;    
	m_currentTime_onelottery       = 0;     
	m_lastTime_onelottery          = 0;     

	m_subSum_commonlottery         = 0;     
	m_subSum_onelottery            = 0;     
end 

function create()
	-- body
	m_rootLayer = CCLayer:create();
	local hotelLayer = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "Hotel.json");
	uiLayer = TouchGroup:create();
	uiLayer:addWidget(hotelLayer);
	m_rootLayer:addChild(uiLayer);


	-- m_rootLayer:retain();
	
	local backBtn = uiLayer:getWidgetByName("back_btn");
	backBtn:addTouchEventListener(backTouchEvent);

	local commonTakeBtn = uiLayer:getWidgetByName("commonTake_btn");
	commonTakeBtn:addTouchEventListener(commonTakeTouchEvent);

	local oneTakeBtn = uiLayer:getWidgetByName("oneTake_btn");
	oneTakeBtn:addTouchEventListener(oneTakeTouchEvent);

	local tenTakeBtn = uiLayer:getWidgetByName("tenTake_btn");
	tenTakeBtn:addTouchEventListener(tenTakeTouchEvent);

	local  freeCommomLotteryTimeLabel = uiLayer:getWidgetByName("freeCommonLottery_label");
	m_freeCommomLotteryTimeLabel = tolua.cast(freeCommomLotteryTimeLabel,"Label");

	local freeOneLotteryTimeLabel = uiLayer:getWidgetByName("freeOneLottery_label");
	m_freeOneLotteryTimeLabel = tolua.cast(freeOneLotteryTimeLabel,"Label");

end

function open()
	-- body
	create();
	local uiLayer = getGameLayer(SCENE_UI_LAYER);
	uiLayer:addChild(m_rootLayer);

	m_costGold = 99;
	requestTCFromSv();
	updateLabelTime(0);
	m_schedulerEntry = scheduler:scheduleScriptFunc(updateLabelTime, 1, false);
	NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_HOTEL_TC, receiveDataFromServer);
	NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_HOTEL_TEN, receiveDataFromServer);
	NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_HOTEL_HIGHER, receiveDataFromServer);
	NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_HOTEL_COMMON, receiveDataFromServer);
end

function close()
	-- body
	local  uiLayer = getGameLayer(SCENE_UI_LAYER);
	uiLayer:removeChild(m_rootLayer,false);
	scheduler:unscheduleScriptEntry(m_schedulerEntry);
	NetMessageManager.unregisterMessage(NETWORK_MESSAGE_RECEIVE_HOTEL_TC, receiveDataFromServer);
	NetMessageManager.unregisterMessage(NETWORK_MESSAGE_RECEIVE_HOTEL_TEN, receiveDataFromServer);
	NetMessageManager.unregisterMessage(NETWORK_MESSAGE_RECEIVE_HOTEL_HIGHER, receiveDataFromServer);
	NetMessageManager.unregisterMessage(NETWORK_MESSAGE_RECEIVE_HOTEL_COMMON, receiveDataFromServer);

end

function remove()
	-- body
	
	m_rootLayer:removeAllChildrenWithCleanup(true);
	m_rootLayer:release();
	m_rootLayer = nil;
	initVariables();
end