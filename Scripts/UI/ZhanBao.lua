module("ZhanBao", package.seeall)

local m_rootLayer = nil;
local m_gameRecordsTable = nil; 
local m_myGameList = nil;

local m_item = nil;

WINSIZE = CCDirector:sharedDirector():getWinSize();
SETTING_POSITION = ccp(WINSIZE.width/2 - 777/2,WINSIZE.height/2 - 547/2);

-- local function exitTouchEvent(sender,eventType)
-- 	-- body
-- 	if eventType == TOUCH_EVENT_TYPE_END then 
-- 		UIManager.close("BD_MyGameUI");
-- 	end
-- end

local function reciveDataFromSever(messageType,messageData)
	-- body
end

local function initListView()
	-- body
	for i=1,9 do
	
		local item = m_item:clone();
		m_myGameList:pushBackCustomItem(item);
       	
	end
end

local function initVariables()
	-- body
	 m_gameRecordsTable = nil; 
	 m_myGameList = nil;
	 m_item:release();
	 m_item = nil;
end

local function onTouch( eventType,x,y )
	-- body
	if eventType == "began" then
		return true;
	elseif eventType == "ended" then
		UIManager.close("ZhanBao");
	end
end
function create()
	-- body
	m_rootLayer = CCLayer:create();

	local bgLayer = SJLayerColor:createSJLayer(BLACK_COLOR4,WINSIZE.width,WINSIZE.height);
	bgLayer:registerScriptTouchHandler(onTouch);
	m_rootLayer:addChild(bgLayer);

	local uiLayout = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "MyGameList_1.json");

    local uiLayer = TouchGroup:create();
    uiLayer:addWidget(uiLayout);
    m_rootLayer:addChild(uiLayer);

    m_rootLayer:setPosition(SETTING_POSITION);
    m_rootLayer:retain();

    local myGameList = tolua.cast(uiLayer:getWidgetByName("myGame_list"),"ListView");
    m_myGameList = myGameList;
    

    local item = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "MyGameUI_1.json");
   
    m_item = tolua.cast(item,"Widget");
    -- m_item:retain();

end

function open()
	-- body
	create();
	local uiLayer = getGameLayer(SCENE_UI_LAYER);
	uiLayer:addChild(m_rootLayer);
	initListView();
end

function close()
	-- body
	local  uiLayer = getGameLayer(SCENE_UI_LAYER);
	uiLayer:removeChild(m_rootLayer,false);
end

function remove()
	-- body
	
	m_rootLayer:removeAllChildrenWithCleanup(true);
	m_rootLayer:release();
	m_rootLayer = nil;
	initVariables();
end