module("ServerListUI", package.seeall)


local m_rootLayer = nil;
local m_adviceData = nil;
WINSIZE = CCDirector:sharedDirector():getWinSize();
SETTING_POSITION = ccp(WINSIZE.width/2 - 700/2,WINSIZE.height/2 - 550/2);

local function selectServer(sender,eventType)
    if eventType == TOUCH_EVENT_TYPE_END then
        local id = sender:getTag();
        CCUserDefault:sharedUserDefault():setStringForKey("defaultid",tostring(id));
        Login.setCurServerID(id);
        UIManager.close("ServerListUI");
        UIManager.open("Login");
    end
end

local function getItem(serverItem,data)
	local item = serverItem:clone();
    local label = tolua.cast(item:getChildByName("index_label"),"Label");
    label:setText(data.id .. "区" .. "   " .. data.serverName);
    local hot =  tolua.cast(item:getChildByName("hot_Panel"),"Layout");
    local new = tolua.cast(item:getChildByName("new_Panel"),"Layout");
    if(data.fire == 1)then
        hot:setVisible(false);
        new:setVisible(true);
    end
    
    return item;
end

local function onTouch(eventType, x, y)
    -- if eventType == "began" then
    --     return true;
    -- elseif eventType == "ended" then
    --     UIManager.close("ActivityType");
    -- end
end

function create()
	m_rootLayer = CCLayer:create();
    local bgLayer = SJLayerColor:createSJLayer(BLACK_COLOR4,WINSIZE.width,WINSIZE.height);
    bgLayer:registerScriptTouchHandler(onTouch);
    local bg = ImageView:create();
    bg:setAnchorPoint(CCPoint(0,0));
    bg:loadTexture(PATH_CCS_RES .. "denglu_bg_1.png");
    m_rootLayer:addChild(bg);
    m_rootLayer:addChild(bgLayer);
	local uiLayout = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "ServerListUI.json");
    local uiLayer = TouchGroup:create();
    uiLayout:setPosition(SETTING_POSITION);
    uiLayer:addWidget(uiLayout);
    m_rootLayer:addChild(uiLayer);
    local tuijianPanel = uiLayer:getWidgetByName("tuijian_img");
    local defaultPabel = uiLayer:getWidgetByName("shangci_img");

    local serverItem = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "ServerListItemUI_1.json");
    serverItem = tolua.cast(serverItem,"Widget");
    m_adviceData = LoginManager.getFireInfo();
    local tuijian = getItem(serverItem,m_adviceData);
    tuijian:setAnchorPoint(CCPoint(0.5,0.5));
    tuijian:setPosition(ccp(0,-15));
    tuijianPanel:addChild(tuijian);

    if(CCUserDefault:sharedUserDefault():getStringForKey("defaultid") ~= "" and CCUserDefault:sharedUserDefault():getStringForKey("defaultaccount") ~= ""
    and CCUserDefault:sharedUserDefault():getStringForKey("defaultpwd") ~= "")then
        local server = getItem(serverItem,LoginManager.getInfoByID(tonumber(CCUserDefault:sharedUserDefault():getStringForKey("defaultid"))));
        server:setAnchorPoint(CCPoint(0.5,0.5));
        server:setPosition(ccp(0,-15));
        defaultPabel:addChild(server);
    end
-- getRemainder
    local serverList = tolua.cast(uiLayer:getWidgetByName("ListView_4"),"ListView");
    local dataList = LoginManager.getServerList();
    local curLayout = nil;
    for i=1,#dataList do
        local item = getItem(serverItem,dataList[i]);
        if(Util.getRemainder(i-1,2) == 0)then
            curLayout = Layout:create();
            curLayout:setSize(CCSize(serverList:getSize().width,serverItem:getSize().height));
            local ooo = curLayout:getSize().width;
            local ooo = curLayout:getSize().height;
            item:setPosition(ccp(0,0));
            serverList:pushBackCustomItem(curLayout);
        else
            item:setPosition(ccp(curLayout:getSize().width - item:getSize().width,0));
        end
        item:setTag(dataList[i].id);
        item:addTouchEventListener(selectServer);
        curLayout:addChild(item);
    end

end

function open()
	local uiLayer = getGameLayer(SCENE_UI_LAYER);
	uiLayer:addChild(m_rootLayer);
end

function close()
	local  uiLayer = getGameLayer(SCENE_UI_LAYER);
	uiLayer:removeChild(m_rootLayer,true);
end

function remove()

end