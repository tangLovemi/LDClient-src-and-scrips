module("SelectActorDialog", package.seeall)

local m_layout = nil;
local m_rootLayer = nil;
local m_data = nil;
local m_nameLabel = nil;
WINSIZE = CCDirector:sharedDirector():getWinSize();


local function onTouch(eventType, x, y)
    if eventType == "began" then
        return true;
    elseif eventType == "ended" then
        UIManager.close("SelectActorDialog");
    end
end

local function applyFriendEvent(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
		UIManager.close("SelectActorDialog");
		FriendsManager.applyAddFriendBySearch(m_data.name,1);
	end
end

local function chatEvent(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
		UIManager.close("SelectActorDialog");
		UIManager.open("Mail");
        Mail.openWriteMailOutSide(m_data.name);
	end
end

local function checkEvent(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
		UIManager.close("SelectActorDialog");
		-- UIManager.open("FriendsMain");
		FriendsMain.checkDetailForRole(m_data.uid);
	end
end


function create()
	m_rootLayer = CCLayer:create();
    local bgLayer = SJLayerColor:createSJLayer(BLACK_COLOR4_OPAC,WINSIZE.width,WINSIZE.height);
    m_rootLayer:addChild(bgLayer);
    bgLayer:registerScriptTouchHandler(onTouch,false,-99,true);
    m_layout = TouchGroup:create();
    m_layout:addWidget(GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "selectPlayerDialog_1.json"));
    -- m_layout:setPosition(SETTING_POSITION);
    m_rootLayer:addChild(m_layout,11);
    local applyFriendBtn = m_layout:getWidgetByName("Panel_5_0");
    applyFriendBtn:addTouchEventListener(applyFriendEvent);

    local checkEquipBtn = m_layout:getWidgetByName("Panel_5");
    checkEquipBtn:addTouchEventListener(checkEvent);

    local chatBtn = m_layout:getWidgetByName("Panel_5_0_1");
    chatBtn:addTouchEventListener(chatEvent);

    m_nameLabel = tolua.cast(m_layout:getWidgetByName("Label_2"),"Label");
end

function open(data,x,y)
	MainCityLogic.unregisterTouchFunction();
	create();
	m_data = data;
	local uiLayer = getGameLayer(SCENE_UI_LAYER);
    uiLayer:addChild(m_rootLayer, 10);
    m_layout:setPositionX(x);
    m_layout:setPositionY(y);
    m_nameLabel:setText(data.name);
end

function close()
	MainCityLogic.registerTouchFunction();
    local uiLayer = getGameLayer(SCENE_UI_LAYER);
    -- m_rootLayer:unregisterScriptTouchHandler();
    uiLayer:removeChild(m_rootLayer, true);
    m_layout = nil;
    m_rootLayer = nil;
    m_nameLabel = nil;
end

function remove()

end