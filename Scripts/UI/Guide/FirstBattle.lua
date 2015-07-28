	
module("FirstBattle", package.seeall)

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
local m_HandAnimation = nil
local m_animationNewPath  = PATH_RES_OTHER .."NewAnimation.ExportJson"

function setCallBack( callback )
	m_callBack = callback
end
local function touchEvent(sender,eventType)
	if eventType == TOUCH_EVENT_TYPE_END then
		if m_dialogContents[m_dialogID] == nil then
			m_callBack()
			return
		end
		local contents =  Util.Split(string.sub(m_dialogContents[m_dialogID].text,2,-2),"&")

		local headImg = contents[2]
		m_dialogLabel:setText(contents[1])
		
		if headImg~= "self" then
			m_head2:setVisible(true)
			m_head2:loadTexture(PATH_CCS_RES..headImg..".png")
		else
			m_head2:setVisible(false)
		end

		if tonumber(m_dialogContents[m_dialogID].arrowX)~= nil then
			m_HandAnimation:setPosition(ccp(tonumber(m_dialogContents[m_dialogID].arrowX),tonumber(m_dialogContents[m_dialogID].arrowY)));
			m_HandAnimation:setVisible(true)
		else
			m_HandAnimation:setVisible(false)
		end
		m_dialogID = m_dialogID+1
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

	    CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo(m_animationNewPath);
	    m_HandAnimation = CCArmature:create("NewAnimation");
	    m_HandAnimation:getAnimation():playWithIndex(0);
	    -- m_HandAnimation:setPosition(ccp(tonumber(m_dialogContents[m_dialogID].arrowX),tonumber(m_dialogContents[m_dialogID].arrowY)));
	    -- CCArmatureDataManager:purge();
		m_HandAnimation:setVisible(false)
	    m_rootLayer:addChild(m_HandAnimation);

	end

end

function open(status)
	if m_isOpen ==false then
		m_isOpen = true
		create();
		local uiLayer = getGameLayer(SCENE_UI_LAYER);
		uiLayer:addChild(m_rootLayer)
		if status =="begin" then 
			for i=1,14 do
				m_dialogContents[i] = DataTableManager.getItem("firstBattle",i.."_index")
			end
		end
		if status == "end" then 
			for i=1,4 do
				m_dialogContents[i] = DataTableManager.getItem("firstBattle",(i+14).."_index")
			end
		end
		local contents =  Util.Split(string.sub(m_dialogContents[m_dialogID].text,2,-2),"&")
		local headImg = contents[2]
		if contents[1]~= 0 then
			m_dialogLabel:setText(contents[1])
			
			if headImg~= "self" then
				m_head2:setVisible(true)
				m_head2:loadTexture(PATH_CCS_RES..headImg..".png")
			else
				m_head2:setVisible(false)
			end
		end
		if tonumber(m_dialogContents[m_dialogID].arrowX)~= nil then
			m_HandAnimation:setPosition(ccp(tonumber(m_dialogContents[m_dialogID].arrowX),tonumber(m_dialogContents[m_dialogID].arrowY)));
			m_HandAnimation:setVisible(true)
		else
			m_HandAnimation:setVisible(false)
		end
		m_dialogID = m_dialogID+1
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
	end

end
