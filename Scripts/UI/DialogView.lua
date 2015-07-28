	
module("DialogView", package.seeall)

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
		if(math.modf(m_npcID/1000)==327) then
			local nextContent = DataTableManager.getValue("RewardDialog", m_current_Task.."_index", "DialogContent")
			if(nextContent~= 0) then
				m_dialogLabel:setText(nextContent)
				m_current_Task= m_current_Task+1
	    		--关闭升级界面
		    	if Upgrade.getOpenState() then
    				UIManager.close("Upgrade")
    				return
    			end
			else
				local function callback()
					MainCityLogic.removeMainCity();
					UIManager.close("DialogView")
				end
				

				BattleManager.enterBattle(1, 3,m_npcID,callback);
			end
		elseif (math.modf(m_npcID/1000)==320) then
	    	local contents = Util.Split(string.sub(m_dialogContents[m_dialogID],2,-2),"&")
	    	if contents[1]~= "0" then
	    		--关闭升级界面
		    	if Upgrade.getOpenState() then
    				UIManager.close("Upgrade")
    				return
    			end

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
				if 4 == current_Task_Status then
					Util.showOperateResultPrompt("当前主线任务奖励领取了，再次点击查看新的任务状态吧")
				elseif 2 == current_Task_Status then
					Util.showOperateResultPrompt("当前主线任务已经领取了。。。。。赶快去完成吧")
				end
				-- NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_CLICK_NPC_TASKSTATUS_CHANGE, {m_npcID});	
				UIManager.close("DialogView")
				
	    	end
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

function open(messageData)
	if m_isOpen ==false then
		m_isOpen = true
		create();
		local uiLayer = getGameLayer(SCENE_UI_LAYER);
		uiLayer:addChild(m_rootLayer)
		if messageData~= nil then
		    m_current_Task = tonumber(messageData["task_id"])
		    local current_Task_Status = messageData["status"]
		    local current_Task_Num = messageData["num"]
		    m_npcID = messageData["npcID"]
		    if math.modf(m_npcID/1000) == 327 then
		    	m_dialogLabel:setText(DataTableManager.getValue("RewardDialog", m_current_Task.."_index", "DialogContent"))
		    	m_current_Task =m_current_Task+1
		    elseif math.modf(m_npcID/1000) == 320 then
		    	NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_CLICK_NPC_TASKSTATUS_CHANGE, {m_npcID});	
-- 
		    	m_dialogContents = Util.Split(DataTableManager.getValue("MajorTaskDialog", m_current_Task.."_index", "DialogContent"),";")
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

		if TaskManager.getNewState() then
			UIManager.close("GuiderLayer")
		end
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

		if TaskManager.getNewState() then
			UIManager.open("GuiderLayer");
		end
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
