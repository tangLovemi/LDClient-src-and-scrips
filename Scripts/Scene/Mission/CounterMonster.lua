module("CounterMonster", package.seeall)

local m_missionId = nil;
local m_closeCB = nil;
local m_pos = ccp(SCREEN_WIDTH_HALF - 400, 50);
local m_rootLayout = nil;

function closeAll()
	if(m_closeCB) then
		m_closeCB();
	end
end


local function showInfo(data)
	local title = tolua.cast(m_rootLayout:getWidgetByName("title_textfield"), "Label");
	local content = tolua.cast(m_rootLayout:getWidgetByName("content_textfield"), "Label");


end

function open( id, closeCB )
	m_missionId = id;
	m_closeCB = closeCB;
	--根据任务id查表得到数据内容显示UI
	m_rootLayout = TouchGroup:create();
	m_rootLayout:retain();
	local panel = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "Dialog.json");
	m_rootLayout:addWidget(panel);
	m_rootLayout:setPosition(m_pos);
	local uiLayer = getGameLayer(SCENE_UI_LAYER);
	uiLayer:addChild(m_rootLayout);

	showInfo(data);
end

function close()
	local uiLayer = getGameLayer(SCENE_UI_LAYER);
	uiLayer:removeChild(m_rootLayout, true);
	m_rootLayout = nil;
end