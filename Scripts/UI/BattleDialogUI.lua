--
-- Author: Gao Jiefeng
-- Date: 2015-05-09 11:01:50
--
	
module("BattleDialogUI", package.seeall)

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
local m_callBack = nil 
local function touchEvent(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then			
    	local contents = Util.Split(string.sub(m_dialogContents[m_dialogID],2,-2),"&")
    	if contents[1]~= "0" then
    		m_dialogLabel:setText(contents[1])
    		m_dialogID = m_dialogID+1
    		local headPostion = contents[2]
    		if headPostion~= "self" then
    			m_head2:setVisible(true)
    			m_head2:loadTexture(PATH_CCS_RES..headPostion..".png")
			else
				m_head2:setVisible(false)
			end
    	else				
			m_callBack()
    	end
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

function open(dialogContents,callback)
	if m_isOpen ==false then
		m_isOpen = true
		m_callBack = callback
		local uiLayer = getGameLayer(SCENE_UI_LAYER);
		uiLayer:addChild(m_rootLayer)
    	m_dialogContents = Util.Split(dialogContents,";")
    	local contents = Util.Split(string.sub(m_dialogContents[m_dialogID],2,-2),"&")
    	local headPostion = contents[2]
    	if contents[1]~= 0 then
    		m_dialogLabel:setText(contents[1])
    		m_dialogID = m_dialogID+1
    		if headPostion~= "self" then
    			m_head2:loadTexture(PATH_CCS_RES..headPostion..".png")
    			m_head2:setVisible(true)
			else
				m_head2:setVisible(false)
			end
		end
	end
end
function close()
	if(m_isOpen)then
		m_isOpen = false
		local  uiLayer = getGameLayer(SCENE_UI_LAYER);
		uiLayer:removeChild(m_rootLayer,false);
		m_dialogContents = {}
	 	m_dialogID = 1

		-- if TaskManager.getNewState() then
		-- 	UIManager.open("GuiderLayer");
		-- end
	end

end

function remove()
	if(m_isCreate)then
		m_rootLayer:removeAllChildrenWithCleanup(true);	
		m_rootLayer:release();
		m_rootLayer= nil
		m_isCreate = false;
	end

end
