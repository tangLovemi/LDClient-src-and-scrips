 module("CloseButton", package.seeall)

local m_closeLayout = nil;
local m_closeCB = nil;
local m_isOpen = false;
local m_isCreate = false;

local function closeDetailsOnClick( sender,eventType )
	if eventType == TOUCH_EVENT_TYPE_END then
		if(m_closeCB) then
			m_closeCB();
		end
	end
end

function create()
    if(not m_isCreate) then
        m_isCreate = true;
        m_closeLayout = TouchGroup:create();
        m_closeLayout:retain();
        local closePanel = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "ClosePanelBtn.json");
        m_closeLayout:addWidget(closePanel);
        local closeBtn = tolua.cast(m_closeLayout:getWidgetByName("close_panel"), "Layout");
        closeBtn:addTouchEventListener(closeDetailsOnClick);
    end
end

function open(cb)
	if (not m_isOpen) then
        m_isOpen = true;
        local uiLayer = getGameLayer(SCENE_UI_LAYER);
        uiLayer:addChild(m_closeLayout, FOUR_ZORDER);
        if(cb) then
            m_closeCB = cb;
        end
    end
end

function close()
	if (m_isOpen) then
        m_isOpen = false;
        local uiLayer = getGameLayer(SCENE_UI_LAYER);
        uiLayer:removeChild(m_closeLayout, false);
    end
end

function remove()
    if(m_isCreate) then
        m_isCreate = false;
        if(m_closeLayout) then
            m_closeLayout:removeAllChildrenWithCleanup(true);
            m_closeLayout:release();
        end
        m_closeLayout = nil;
        m_closeCB = nil;
    end
end