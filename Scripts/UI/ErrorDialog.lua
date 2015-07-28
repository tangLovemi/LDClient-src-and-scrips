module("ErrorDialog", package.seeall)

local m_rootLayer = nil;
local m_layout = nil;
local m_leftCallBack = nil;
local m_centerCallBack = nil;
local m_rightCallBack = nil;
WINSIZE = CCDirector:sharedDirector():getWinSize();
function create()
	m_rootLayer = CCLayer:create();
    m_layout = TouchGroup:create();
    m_layout:addWidget(GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "TYDiarog_1.json"));
    m_rootLayer:addChild(m_layout);
end


function open()
	local uiLayer = getGameLayer(SCENE_UI_LAYER);
    uiLayer:addChild(m_rootLayer, 100);
end

local function leftListener(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then--弹出帮助界面
		if(m_leftCallBack ~= nil)then
			m_leftCallBack();
		end
	end
end

local function centerListener(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then--弹出帮助界面
		if(m_centerCallBack ~= nil)then
			m_centerCallBack();
		end
	end
end

local function rightListener(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then--弹出帮助界面
		if(m_rightCallBack ~= nil)then
			m_rightCallBack();
		end
	end
end

function setPanelStyle(content,funs)--funs是数组，根据数组数据数量选择几个按钮，从左到右
	local contentLabel = tolua.cast(m_layout:getWidgetByName("Label_content"),"Label");
	contentLabel:setText(content);
	if(#funs == 1)then
		tolua.cast(m_layout:getWidgetByName("Panel_3_0"),"Layout"):setEnabled(true);
		tolua.cast(m_layout:getWidgetByName("Panel_3"),"Layout"):setEnabled(false);
		m_centerCallBack = funs[1];
		local centerButton = tolua.cast(m_layout:getWidgetByName("Button_center"),"Button");
		centerButton:addTouchEventListener(centerListener);
	else
		tolua.cast(m_layout:getWidgetByName("Panel_3_0"),"Layout"):setEnabled(false);
		tolua.cast(m_layout:getWidgetByName("Panel_3"),"Layout"):setEnabled(true);
		m_leftCallBack = funs[1];
		m_rightCallBack = funs[2];
		local leftButton = tolua.cast(m_layout:getWidgetByName("Button_left"),"Button");
		leftButton:addTouchEventListener(leftListener);
		local rightButton = tolua.cast(m_layout:getWidgetByName("Button_right"),"Button");
		rightButton:addTouchEventListener(rightListener);
	end

end

function close()
	local uiLayer = getGameLayer(SCENE_UI_LAYER);
    uiLayer:removeChild(m_rootLayer, true);
    m_layout = nil;
	m_leftCallBack = nil;
	m_centerCallBack = nil;
	m_rightCallBack = nil;
	m_rootLayer = nil;
end

function remove()

end