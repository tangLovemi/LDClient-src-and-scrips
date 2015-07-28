--
-- Author: Your Name
-- Date: 2015-06-10 11:15:42
--
	
module("NpcWordsUI", package.seeall)

local m_rootLayer = nil
local m_UILayout= nil
local m_current_Task =nil
local m_dialogLabel = nil
local m_npcID = nil
local m_isOpen = false
local m_head2 = nil
local m_dialogContents = {}
local m_dialogID = 1
local m_isCreate = false;

local function touchEvent(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
		UIManager.close("NpcWordsUI")
	end

end
function create()
	if(m_isCreate == false)then
		m_rootLayer = CCLayer:create();
		m_rootLayer:retain()  
		local UISource = GUIReader:shareReader():widgetFromJsonFile(PATH_RES_UI .. "Dialog_1.json");
	    m_UILayout = TouchGroup:create();
	    m_UILayout:addWidget(UISource);
	    m_rootLayer:addChild(m_UILayout);
	    local panel = tolua.cast(m_UILayout:getWidgetByName("Panel_20"), "Layout")
	    panel:addTouchEventListener(touchEvent);
	    m_dialogLabel = tolua.cast(m_UILayout:getWidgetByName("dialogContent"), "Label");
	    m_head2 = tolua.cast(m_UILayout:getWidgetByName("head2"), "ImageView");
	    m_isCreate = true;
	end

end

function open(npcId)
	if m_isOpen ==false then
		m_isOpen = true
		create();
		local uiLayer = getGameLayer(SCENE_UI_LAYER);
		uiLayer:addChild(m_rootLayer)

    	m_dialogLabel:setText(DataTableManager.getValue("npcWords","id_"..npcId, "Words"))

		m_head2:loadTexture(PATH_CCS_RES..npcId..".png")

		MainCityLogic.unregisterTouchFunction()
	end
end
function close()
	if(m_isOpen)then
		m_isOpen = false
		local  uiLayer = getGameLayer(SCENE_UI_LAYER);
		uiLayer:removeChild(m_rootLayer,false);
		m_dialogContents = {}
	 	m_dialogID = 1
	end

end

function remove()
	if(m_isCreate)then
		m_rootLayer:removeAllChildrenWithCleanup(true);	
		m_rootLayer:release();
		m_rootLayer= nil
		m_isCreate = false;
		m_rootLayer = nil
		m_UILayout= nil
		m_current_Task =nil
		m_dialogLabel = nil
		m_npcID = nil
		m_head2 = nil
		m_dialogContents = nil
		m_dialogID = nil
	end

end
