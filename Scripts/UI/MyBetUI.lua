module("MyBetUI", package.seeall)

local m_rootLayer = nil;
local m_myList 	  = nil;
local myBetList   = {};
local m_uiLayer = nil;
local m_tableView = nil;
local m_item      = nil;

WINSIZE = CCDirector:sharedDirector():getWinSize();
SETTING_POSITION = ccp(WINSIZE.width/2 - 587/2,WINSIZE.height/2 - 380/2);

local function exitTouchEvent(sender,eventType)
	
	if eventType == TOUCH_EVENT_TYPE_END then 
		UIManager.close("MyBetUI");
	end
end

local function initList()
	-- body
	for i=1,#myBetList do
		local item = m_item:clone();
		m_myList:pushBackCustomItem(item);
	end
end

local function initVariables()
	-- body
	myBetList   = {};
	-- m_item:release();
	-- m_item      = nil;
end

local function onTouch( eventType,x,y )
	-- body
	if eventType == "began" then
		return true;
	elseif eventType == "ended" then
		UIManager.close("MyBetUI");
	end
end

function reflushUI()
	local data = TournamentManager.getMyBetData();
	local item = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "MyBetUItem_1.json");
	for i,v in pairs(data)do
		local temp = item:clone();
		initItem(temp,v);
		m_tableView:pushBackCustomItem(temp);
	end
end

function initItem(item,data)
	local text = nil;
	if(data.state < 9)then
		text = "16进8比赛";
	elseif(data.state >=9 and data.state < 13)then
		text = "8进4比赛";
	elseif(data.state >=13 and data.state < 15)then
		text = "半决赛";
	elseif(data.state == 15)then
		text = "决赛";
	end
	local panel = item:getChildByName("MyBetUItem");
	local matchLabel = tolua.cast(panel:getChildByName("Label_6"),"Label");
	matchLabel:setText(text);
	if(data.isEnd == 0)then--没结果 
	elseif(data.isEnd == 1)then--right
		tolua.cast(panel:getChildByName("success"),"Layout"):setVisible(true);
	elseif(data.isEnd == 2)then--error
		tolua.cast(panel:getChildByName("fail"),"Layout"):setVisible(true);
	end
	tolua.cast(panel:getChildByName("Label_name"),"Label"):setText(data.name);
	tolua.cast(panel:getChildByName("Label_money"),"Label"):setText(data.money);
end

function create()
	-- body
	m_rootLayer = CCLayer:create();

	local bgLayer = SJLayerColor:createSJLayer(BLACK_COLOR4,WINSIZE.width,WINSIZE.height);
	bgLayer:registerScriptTouchHandler(onTouch);
	m_rootLayer:addChild(bgLayer);

	local uiLayout = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "MyBetUI_1.json");
    m_uiLayer = TouchGroup:create();

    m_uiLayer:addWidget(uiLayout);

    m_tableView = tolua.cast(m_uiLayer:getWidgetByName("ListView_42"),"ListView");
    -- m_rootLayer:addChild(m_uiLayer);
    m_uiLayer:setPosition(SETTING_POSITION);
    m_rootLayer:addChild(UIManager.bounceOut(m_uiLayer));
end

function open()
	-- body
	local uiLayer = getGameLayer(SCENE_UI_LAYER);
	uiLayer:addChild(m_rootLayer);
	NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_TOURNAMENT_MYBET,{});
end

function close()
	-- body
	m_rootLayer:removeAllChildrenWithCleanup(true);
	local  uiLayer = getGameLayer(SCENE_UI_LAYER);
	uiLayer:removeChild(m_rootLayer,true);
	m_tableView = nil;
	m_rootLayer = nil;
	initVariables();
end

function remove()

end