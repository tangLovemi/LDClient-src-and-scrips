
module("ActivityType", package.seeall)

local m_rootLayer = nil;
local m_layout = nil;
local m_info = nil;
local m_bounceLayer = nil;
WINSIZE = CCDirector:sharedDirector():getWinSize();
SETTING_POSITION = ccp(WINSIZE.width/2 - 780/2,WINSIZE.height/2 - 460/2);
local function help(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then

	end
end


local function backEvent(sender,eventType)
    if eventType == TOUCH_EVENT_TYPE_END then
        UIManager.close("ActivityType");
    end
end

local function onTouch(eventType, x, y)
    if eventType == "began" then
        return true;
    elseif eventType == "ended" then
        UIManager.close("ActivityType");
    end
end

local function onClickType(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
		local type = tonumber(tolua.cast(sender,"Layout"):getName());
        local ttt = m_info[type];
        local name = ttt["isOpen"];
        if(m_info[type]["isOpen"] == 1)then
            ActivityLevel.open(type,ActivityManager.getInfo());
        end

	end
end

function create()
	m_rootLayer = CCLayer:create();
    local bgLayer = SJLayerColor:createSJLayer(BLACK_COLOR4,WINSIZE.width,WINSIZE.height);
    bgLayer:registerScriptTouchHandler(onTouch);
    m_rootLayer:addChild(bgLayer);
    -- m_bounceLayer = CCLayer:create();
    -- m_rootLayer:retain();
    m_layout = TouchGroup:create();
    m_layout:addWidget(GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "huodongfuben_1.json"));
    m_layout:setPosition(SETTING_POSITION);


    local helpBtn = m_layout:getWidgetByName("help_img");
    helpBtn:addTouchEventListener(help);

    local backBtn = m_layout:getWidgetByName("back_img");
    backBtn:addTouchEventListener(backEvent);
    m_rootLayer:addChild(UIManager.bounceOut(m_layout));
    
end

function init()
    m_info = ActivityManager.getInfo();
    local typeData =  DataBaseManager.getTableByName(DATA_BASE_ACTIVITY_TYPE);
    for i,v in pairs(typeData)do
        local name = "huodong" .. v.type .. "_btn";
        CCLuaLog(name);
        local Btn = m_layout:getWidgetByName(name);
        Btn = tolua.cast(Btn,"Button");
        local relevel = v.restrainLevel
        if(v.restrainLevel > UserInfoManager.getRoleInfo("level") or v.energy > UserInfoManager.getRoleInfo("physic") or ActivityManager.getValue(tonumber(v.type),"isOpen") ~= 1)then
            local levelName = "AtlasLabelLevel_" .. v.type;
            local levelLabel = tolua.cast(m_layout:getWidgetByName(levelName),"Layout");
            levelLabel:setVisible(true);
            local prayName = "open_" .. v.type;
            local prayImg = tolua.cast(m_layout:getWidgetByName(prayName),"Layout");
            prayImg:setVisible(true);
            -- levelLabel:setText("");
            Btn:setTouchEnabled(false);
            Btn:setBright(false);
        else
            Btn:addTouchEventListener(onClickType);
        end
        Btn:setName(tostring(v.type)); 
    end
end

function open()
        -- create();
        local uiLayer = getGameLayer(SCENE_UI_LAYER);
        uiLayer:addChild(m_rootLayer, TWO_ZORDER);
        NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_ACTIVITY_INSTANCE,{});
end


function close()
    local uiLayer = getGameLayer(SCENE_UI_LAYER);
    uiLayer:removeChild(m_rootLayer, true);
end

function remove()

end
