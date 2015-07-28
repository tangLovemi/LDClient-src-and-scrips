module("TrainBuffDesc", package.seeall)

local m_rootLayer = nil;
local m_uiLayer = nil;
local m_isCreate = false;
local m_isOpen = false;


local m_upGroupPanel = nil;
local m_nowBuffLabel = nil;
local m_upGroupNameLabel = nil;
local m_upBuffLabel = nil;

local function onTouch(eventType,x,y)
	if eventType == "began" then
		return true;
	elseif eventType == "ended" then
		TrainBuffDesc.close();
	end
end

local function openInit()
	local perData = TrainUI.getPersonalData();
	m_nowBuffLabel:setText(perData.nowBuff .. "%");
	if(perData.jjcGroupid == 0) then
		m_upGroupPanel:setEnabled(false);
	else 
		m_upGroupNameLabel:setText(JJCUI.getGroupName(perData.jjcGroupid));
		m_upBuffLabel:setText(perData.upBuff .. "%");
	end

end

function create()
	if(not m_isCreate) then
		m_isCreate = true;
		m_rootLayer = CCLayer:create();

		local bgLayer = SJLayerColor:createSJLayer(BLACK_COLOR4,WINSIZE.width,WINSIZE.height);
		bgLayer:registerScriptTouchHandler(onTouch);
		m_rootLayer:addChild(bgLayer, 0);

		local uiLayout = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "TrainBuffDesc.json");
		m_uiLayer = TouchGroup:create();
		m_uiLayer:addWidget(uiLayout);
		m_rootLayer:addChild(m_uiLayer, 1);

		m_rootLayer:retain();

		m_nowBuffLabel = tolua.cast(m_uiLayer:getWidgetByName("nowBuff_label"), "Label");
		m_upGroupNameLabel = tolua.cast(m_uiLayer:getWidgetByName("upGroupName_label"), "Label");
		m_upBuffLabel = tolua.cast(m_uiLayer:getWidgetByName("upBuff_label"), "Label");

		m_upGroupPanel = tolua.cast(m_uiLayer:getWidgetByName("upGroup_panel"), "Layout");
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
