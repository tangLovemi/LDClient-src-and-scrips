module("TrainBuyFightCountDesc", package.seeall)

local m_rootLayer = nil;
local m_uiLayer = nil;
local m_isCreate = false;
local m_isOpen = false;

local COUNT = 3;

local function onTouch(eventType,x,y)
	if eventType == "began" then
		return true;
	elseif eventType == "ended" then
		TrainBuyFightCountDesc.close();
	end
end

local function buyOnClick( sender,eventType )
	if(eventType == TOUCH_EVENT_TYPE_END) then
		NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_TRAIN_BUY_FIGHT_COUNT, {COUNT});
		TrainMgr.open();
		TrainBuyFightCountDesc.close();
	end
end

local function openInit()
	
end

function create()
	if(not m_isCreate) then
		m_isCreate = true;
		m_rootLayer = CCLayer:create();

		local bgLayer = SJLayerColor:createSJLayer(BLACK_COLOR4,WINSIZE.width,WINSIZE.height);
		bgLayer:registerScriptTouchHandler(onTouch);
		m_rootLayer:addChild(bgLayer, 0);

		local uiLayout = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "TrainBuyFightCountDesc.json");
		m_uiLayer = TouchGroup:create();
		m_uiLayer:addWidget(uiLayout);
		m_rootLayer:addChild(m_uiLayer, 1);

		m_rootLayer:retain();
		
		tolua.cast(m_uiLayer:getWidgetByName("buy_btn"), "Button"):addTouchEventListener(buyOnClick);
	end
end


function open()
	if(m_isOpen == false) then
		m_isOpen = true;
		local uiLayer = getGameLayer(SCENE_UI_LAYER);
		uiLayer:addChild(m_rootLayer);

		openInit();
	end
end

function close()
	if(m_isOpen) then
		m_isOpen = false;
		local  uiLayer = getGameLayer(SCENE_UI_LAYER);
		uiLayer:removeChild(m_rootLayer,false);
	end
end

function remove()
	if(m_isCreate) then
		m_isCreate = false;
		-- body	
		m_rootLayer:removeAllChildrenWithCleanup(true);
		m_rootLayer:release();
		m_rootLayer = nil;
		m_uiLayer 	= nil;
	end
end
