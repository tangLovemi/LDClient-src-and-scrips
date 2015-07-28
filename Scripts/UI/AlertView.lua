module("AlertView", package.seeall)

local m_rootLayer = nil
local function onTouchEvent(sender,eventType)
print("this is a click")
	if eventType == TOUCH_EVENT_TYPE_END then
		UIManager.close("AlertView")
	end
end
function create()
	m_rootLayer = CCLayer:create();
	-- m_rootLayer:retain()  
end
function open(info)
	create();
	local uiLayer = getGameLayer(SCENE_UI_LAYER);
	uiLayer:addChild(m_rootLayer)

	local label = Label:create();
    label:setText(info[1]);
    label:setPosition(ccp(SCREEN_WIDTH/2, SCREEN_HEIGHT/2));
    label:setFontSize(35);
    label:setColor(ccc3(127, 255, 0));
    m_rootLayer:addChild(label)
end
function close()
	local  uiLayer = getGameLayer(SCENE_UI_LAYER);
	uiLayer:removeChild(m_rootLayer,false);
end

function remove()
	m_rootLayer:removeAllChildrenWithCleanup(true);	
	m_rootLayer:release();
	m_rootLayer= nil
end
