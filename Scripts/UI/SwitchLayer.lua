module("SwitchLayer", package.seeall)
local m_layout = nil;
local m_rootLayer = nil;

WINSIZE = CCDirector:sharedDirector():getWinSize();


local function onTouch(eventType, x, y)
    if eventType == "began" then
        return true;
    elseif eventType == "ended" then
        UIManager.close("SwitchLayer");
    end
end

local function switchEvent(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
        local id = sender:getTag();
        if(id ~= MainCityLogic.getCurSceneId())then
            MainCityLogic.switchLayer(id,0,true,nil);
        end
		UIManager.close("SwitchLayer");
	end
end


function create()
	m_rootLayer = CCLayer:create();
    local bgLayer = SJLayerColor:createSJLayer(BLACK_COLOR4_OPAC,WINSIZE.width,WINSIZE.height);
    m_rootLayer:addChild(bgLayer);
    bgLayer:registerScriptTouchHandler(onTouch);
    m_layout = TouchGroup:create();
    m_layout:addWidget(GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "switchLayer.json"));
    m_rootLayer:addChild(m_layout,11);
    local button1 = m_layout:getWidgetByName("Button_1");
    button1:addTouchEventListener(switchEvent);
    button1:setTag(1);

    local button2 = m_layout:getWidgetByName("Button_2");
    button2:addTouchEventListener(switchEvent);
    button2:setTag(2);

    local button3 = m_layout:getWidgetByName("Button_3");
    button3:addTouchEventListener(switchEvent);
    button3:setTag(3);

end

function open()
	local uiLayer = getGameLayer(SCENE_UI_LAYER);
    uiLayer:addChild(m_rootLayer);
end

function close()
	MainCityLogic.registerTouchFunction();
    local uiLayer = getGameLayer(SCENE_UI_LAYER);
    uiLayer:removeChild(m_rootLayer, true);
    m_layout = nil;
    m_rootLayer = nil;
end

function remove()

end