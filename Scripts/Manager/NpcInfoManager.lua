--
-- Author: gaojiefeng
-- Date: 2015-01-29 13:52:38
module("NpcInfoManager", package.seeall)

local m_handler = nil
local m_handlerMajor = nil
local m_majorTaskData = nil
local m_huntData = nil
local m_huntTaskStatusChange = nil 
local m_majorTaskStatus = 0
local m_majorTaskId = 0
local function recieveOnHuntData(messageType,messageData)
	m_huntData = messageData
	if MainCityLogic.isOpen() then 
		if 1== messageData["status"] then
			Util.showOperateResultPrompt("当前赏金任务不可接")
		elseif 2== messageData["status"] then
			Util.showOperateResultPrompt("当前赏金任务可以去接了")
		elseif 3== messageData["status"] then
			Util.showOperateResultPrompt("当前赏金任务正在进行中")
		elseif 4== messageData["status"] then
			Util.showOperateResultPrompt("当前赏金任务可以领取奖励了")
		end
		if tonumber(messageData["task_id"])==0 then 
			getHuntTaskInfo(710001,nil)
		end
		if m_handler~= nil then
			m_handler(messageData)
			m_handler = nil
		end
		
	end

	NotificationManager.onLineCheck("NpcInfoManager")
end
local function onRecieveMajorTaskData(messageType,messageData)
	m_majorTaskData  = messageData
	if 1== messageData["status"] then
		Util.showOperateResultPrompt("当前主线任务不可接")
	elseif 2== messageData["status"] then
		Util.showOperateResultPrompt("当前主线任务可以去接了")
	elseif 3== messageData["status"] then
		Util.showOperateResultPrompt("当前主线任务正在进行中")
	elseif 4== messageData["status"] then
		Util.showOperateResultPrompt("当前主线任务可以领取奖励了")
	end
	-- UIManager.close("RewardDisplay")
-- UIManager.open("RewardDisplay")
	if(WorldMapUI.isOpen()) then
		if nil ~= m_handlerMajor then
			m_handlerMajor(messageData)
			m_handlerMajor = nil
			return;
		end
	end

	if MainCityLogic.isOpen() then
		if nil ~= m_handlerMajor then
			m_handlerMajor(messageData)
			m_handlerMajor = nil
		end
	-- 更新任务状态动画
		checkIsMajorReward(messageData)
		m_majorTaskStatus = messageData["status"] 
		m_majorTaskId = messageData["task_id"]
		MainCityLogic.setMajorTaskStatus()
	end



	NotificationManager.onLineCheck("NpcInfoManager")
end
function checkIsMajorReward(messageData)
	if m_majorTaskStatus>2  and (messageData["status"] == 2 or messageData["status"]==1) then
		RewardDisplay.setTypeAndId(m_majorTaskId,1)
		UIManager.open("RewardDisplay")
	end
end
function onRecieveHuntStatusChange(messageType,messageData)
	if m_handler ~= nil then 
		getHuntTaskInfo(710001,m_handler)
	end
end
function getMajorTaskNpcID()
	if m_majorTaskData~= nil then
	    --获取任务信息
	    local taskData = getMajorTaskData()
	    local current_Task = tonumber(taskData["task_id"])
	    local current_Task_Status = taskData["status"]
	    local npcID
	    if current_Task_Status == 2 then
	        npcID = DataTableManager.getValue("MajorTaskDialog", current_Task.."_index", "NpcID")
	    elseif current_Task_Status == 3   then 
	        npcID = DataTableManager.getValue("MajorTaskDialog", (current_Task+1).."_index", "NpcID")
	    elseif current_Task_Status == 4  then 
	        npcID = DataTableManager.getValue("MajorTaskDialog", (current_Task+1).."_index", "NpcID")
	    end
	    return npcID

	else
		return nil
	end
end
function sendHuntTaskStatusChange(callback)
	m_handler = callback
	NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_CLICK_NPC_TASKSTATUS_CHANGE, {710001,3});
end
function getHuntTaskInfo(npcID,handler)
	m_handler = handler
	NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_CLICK_NPC, {npcID});	 
end
function getMajorTaskInfo(npcID,handler)
	m_handlerMajor = handler
	NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_CLICK_NPC, {npcID});	 
end

function getAreaFirstMajorTaskId(areaID)
	if type(areaID)~= "number" then

	else
		local majorTasks = DataTableManager.getValue("MajorTaskInfo",areaID.."_index","MajorTaskID")
		local majorTaskIds = Util.Split(majorTasks,";")
		return tonumber(majorTaskIds[1])
	end
end
function getMajorTaskData()
	return m_majorTaskData
end
function getHuntSceneLevels()
	local current_Task = 0
	local current_Task_Status =0
	current_Task = tonumber(m_huntData["task_id"])
	current_Task_Status = m_huntData["status"]
	local sceneLeves = {}
	if current_Task ~= 0 then
		if current_Task_Status==3 then 
			local checkpointid = tonumber(DataTableManager.getValue("Hunt", current_Task.."_index", "checkpointid"))
			if checkpointid~= 0 and checkpointid ~= nil then
				local bossid = tonumber(DataTableManager.getValue("RewardDialog", current_Task.."_index", "bossid"))
				local tempTable = {bossid,checkpointid}
				table.insert(sceneLeves,tempTable)
			end
		end
	end	
	return sceneLeves
end

function getHuntBossId()
	if m_huntData == nil then
		getHuntTaskInfo(710001,nil)
		return
	else
    local current_TaskId = tonumber(m_huntData["task_id"])
    local current_Task_Status = m_huntData["status"]
    return current_TaskId,current_Task_Status
    end
end
function getHuntData(handler)
	getHuntTaskInfo(710001,handler)
end
function getHuntDataNoHandle()
	return m_huntData
end
function checkNotification()
	if m_majorTaskData["status"] ==4 then
		return true
	end
	if m_huntData["status"] ==4 then
		return true
	end	
	
    return false
end

function checkNotification_login()
    return checkNotification()
end
function checkNotification_line()
    return checkNotification()
end
function checkNotification_close()
    return checkNotification()
end
NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_REWARD_INFO, recieveOnHuntData);
NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_MAJORTASK_INFO, onRecieveMajorTaskData);
NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_REWARD_CHANGESTATUS, onRecieveHuntStatusChange);
--NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_MAJORTASK_INFO_CHANGE, onRecieveTaskChangeSuccess);