module("BackpackFullTishi", package.seeall)

local m_rootLayer = nil;


function closeOnClick( sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
		m_rootLayer:removeFromParentAndCleanup(false);
	end
end

function show()
	if(m_rootLayer == nil) then
		m_rootLayer = CCLayer:create();
		m_rootLayer:retain();
		local layout = TouchGroup:create();
		local panel = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "has_reached_1.json");
		layout:addWidget(panel);
		m_rootLayer:addChild(layout);
		layout:getWidgetByName("sure_btn"):addTouchEventListener(closeOnClick);
	end
	getGameLayer(SCENE_UI_LAYER):addChild(m_rootLayer, 50);
end