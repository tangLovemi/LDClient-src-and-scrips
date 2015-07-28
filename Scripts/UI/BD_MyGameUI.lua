module("BD_MyGameUI", package.seeall)

local m_rootLayer = nil;
local m_gameRecordsTable = nil; 
local m_myGameList = nil;

local m_item = nil;

WINSIZE = CCDirector:sharedDirector():getWinSize();
SETTING_POSITION = ccp(WINSIZE.width/2 - 777/2,WINSIZE.height/2 - 547/2);

local function exitTouchEvent(sender,eventType)
	-- body
	if eventType == TOUCH_EVENT_TYPE_END then 
		UIManager.close("BD_MyGameUI");
	end
end

function removeCurrentSources()
	MainCityLogic.removeMainCity();
end

local function playVideoEvent(sender,eventType)
	-- body

	if eventType == TOUCH_EVENT_TYPE_END then
		id = tolua.cast(sender,"Layout"):getName();
			
			BattleManager.enterBattleRecord(BATTLE_MAIN_TYPE_PVP,BATTLE_SUBTYPE_TOURNAMENT,id,removeCurrentSources);
	end
end

local function initItem(item,data)
	-- local panel = item:getChildByName();
	local titlePanel  = item:getChildByName("tou_panel");
	local btnPanel = item:getChildByName("di3_panel");
	local btn = item:getChildByName("anniu_panel");
	local leftname = titlePanel:getChildByName("mingzi1_label");
	local rightname = titlePanel:getChildByName("mingzi2_label");
	local lefticon = titlePanel:getChildByName("win_img");
	local righticon = titlePanel:getChildByName("lost_img");
	tolua.cast(leftname,"Label"):setText(data.name1);
	tolua.cast(rightname,"Label"):setText(data.name2);
	if(tonumber(data.isWinner) == 1)then
		btn:setVisible(false);
	else
		local leftX = lefticon:getPositionX();
		local rightX = righticon:getPositionX();
		lefticon:setPositionX(rightX);
		righticon:setPositionX(leftX);
		btn:addTouchEventListener(playVideoEvent);
		btn:setName(data.videoid);
	end
end

function initListView()
	-- body
    local item = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "MyGameUI_1.json");
    m_item = tolua.cast(item,"Widget");
	for i,v in pairs(TournamentManager.getMyGameData())do
		local item = m_item:clone();
		initItem(item,v);
		m_myGameList:pushBackCustomItem(item);
	end
end

local function initVariables()
	-- body
	 m_gameRecordsTable = nil; 
	 m_myGameList = nil;
	 -- m_item:release();
	 -- m_item = nil;
end

local function onTouch( eventType,x,y )
	-- body
	if eventType == "began" then
		return true;
	elseif eventType == "ended" then
		UIManager.close("BD_MyGameUI");
	end
end
function create()
	-- body
	
	NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_TOURNANMENT_BETTLE, {});
	m_rootLayer = CCLayer:create();

	local bgLayer = SJLayerColor:createSJLayer(BLACK_COLOR4,WINSIZE.width,WINSIZE.height);
	bgLayer:registerScriptTouchHandler(onTouch);
	m_rootLayer:addChild(bgLayer);

	local uiLayout = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "MyGameList_1.json");

    local uiLayer = TouchGroup:create();
    uiLayer:addWidget(uiLayout);
    -- m_rootLayer:addChild(uiLayer);

    uiLayer:setPosition(SETTING_POSITION);
    -- m_rootLayer:retain();

    local myGameList = tolua.cast(uiLayer:getWidgetByName("myGame_list"),"ListView");
    m_myGameList = myGameList;
    
	m_rootLayer:addChild(UIManager.bounceOut(uiLayer));



end

function open()
	-- body
	local uiLayer = getGameLayer(SCENE_UI_LAYER);
	uiLayer:addChild(m_rootLayer);
end

function close()
	-- body
	m_rootLayer:removeAllChildrenWithCleanup(true);
	local  uiLayer = getGameLayer(SCENE_UI_LAYER);
	uiLayer:removeChild(m_rootLayer,false);
	m_rootLayer = nil;
	initVariables();
end

function remove()

end