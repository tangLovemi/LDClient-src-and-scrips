--
-- Author: Gao Jiefeng
-- Date: 2015-03-11 14:43:11
--
module("TaskManager", package.seeall)

require("UI/Guide/GuideDatas")
local m_daliyActivaties = {} --服务器数据 
local m_dailyTaskHandler = nil
local m_getDailyRewardTaskID = nil
local m_dailyRewardType = 0
local m_achievementData = nil 
local m_achieveHandler

local m_boxInfo ={}
local m_dailyTask = {}
local m_newGuideHandle = nil
local m_newGuideData = {}
local bNewForceGuide  = false
local newStepRecord = 0
local sendNewGuideIndex= -1
local passStep5 = false
local m_localStepRecord = 1
local function onRecieveGetDailyTaskReward(messageType,messageData)
	local messageData ={}
	messageData["bSuccess"] = 1
	if messageData["bSuccess"] == 1 then--判断返回成功信息
		if m_dailyRewardType ==1 then--领取每日后动奖励成功
			m_dailyTask[m_getDailyRewardTaskID] = nil
			m_dailyTaskHandler(m_getDailyRewardTaskID)
		elseif m_dailyRewardType ==2 then --领取宝箱奖励成功
			m_boxInfo[m_getDailyRewardTaskID]["state"] = 2
			m_dailyTaskHandler()
		end
	end
	m_dailyRewardType = 0
	m_getDailyRewardTaskID = nil
	m_dailyTaskHandler = nil
end

local function onRecieveDailyTaskInfo(messageType,messageData)
	m_daliyActivaties = messageData
	for k,v in pairs(m_daliyActivaties) do
		if v["type"] ==2 then 
			m_boxInfo[v["id"]] = v
		end
	end
	for k,v in pairs(m_daliyActivaties) do
		if v["type"] == 1 then 
			m_dailyTask[v["id"]] = v
		end
	end
	if m_dailyTaskHandler~= nil then
		m_dailyTaskHandler()
	end
	m_dailyTaskHandler = nil
	NotificationManager.onLineCheck("TaskManager")
end

function getNewState()
	return bNewForceGuide
end
function setNewState(bState)
	bNewForceGuide = bState
end
--成就列表
local function onRecieveAchievementData(messageType,messageData)
	m_achievementData = messageData
	if m_achieveHandler~= nil then
		DailyTaskUI.initAchieveMentLsit(messageData)
		m_achieveHandler= nil
	end
	NotificationManager.onLineCheck("TaskManager")
end
--成就奖励
local function onRecieveAchievementRewardData(messageType,messageData)
	if m_achieveHandler ~= nil then
		m_achieveHandler(messageData)
	end
end
function getAchievementReward(id,handler)
	m_achieveHandler = handler
	NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_ACHEVEMENT_GET_REWARD, {id});

end

--返回成就列表
function getAchievementList()
	return m_achievementData
end
--新手引导，新手任务
function onRecieveNewGuide(messageType,messageData)
	m_newGuideData = messageData
	if messageData["step"] < 12 then 
		bNewForceGuide = true
	else
		bNewForceGuide = false
	end
	if  messageData["step"] == -2 then
		Util.showOperateResultPrompt("出现未知错误，请从新登录")
	elseif messageData["step"] == -1 then
		if messageData["bSuccess"]==0 then
			bNewForceGuide = false
		end	
	elseif messageData["step"] == 0 then
		if messageData["bSuccess"]==0 then--第一次登录
			--登录处进行判断
		elseif messageData["bSuccess"]==1 then--成功
			if m_newGuideHandle~= nil then 
				m_newGuideHandle()
			end
		end	
	elseif messageData["step"] == 1 then--新手引导第1步
		if messageData["bSuccess"]==0 then
			UIManager.open("GuiderLayer");
			newStepRecord = 1
		end	
	elseif messageData["step"] == 6 then--新手引导第6步
		if messageData["bSuccess"]==0 then
			if m_newGuideHandle~= nil then 
				m_newGuideHandle()
				m_newGuideHandle = nil
			end
			-- GuideDatas.continueNewGUide(m_newGuideData)--新手引导未全部完成
		end	
	elseif messageData["step"] == 7 then--新手引导第7步
		if messageData["bSuccess"]==0 then
			if m_newGuideHandle~= nil then 
				m_newGuideHandle()
				m_newGuideHandle = nil
			end
			-- if MainCityLogic.isOpen() then
			-- 	GuideDatas.continueNewGUide(m_newGuideData)--新手引导未全部完成
			-- end
		end	
	elseif messageData["step"] == 8 then--新手引导第8步
		if messageData["bSuccess"]==0 then
			if m_newGuideHandle~= nil then 
				m_newGuideHandle()
				m_newGuideHandle = nil
			end
			-- GuideDatas.continueNewGUide(m_newGuideData)--新手引导未全部完成
		end
	elseif messageData["step"] == 9 then--新手引导第9步
		if messageData["bSuccess"]==0 then
			if m_newGuideHandle~= nil then 
				m_newGuideHandle()
				m_newGuideHandle = nil
			end
			-- GuideDatas.continueNewGUide(m_newGuideData)--新手引导未全部完成
		end
	elseif messageData["step"] == 10 then--新手引导第10步
		if messageData["bSuccess"]==0 then
			if m_newGuideHandle~= nil then 
				m_newGuideHandle()
				m_newGuideHandle = nil
			end
			-- GuideDatas.continueNewGUide(m_newGuideData)--新手引导未全部完成
		end
	elseif messageData["step"] == 11 then--新手引导第11步
		if messageData["bSuccess"]==0 then
			if m_newGuideHandle~= nil then 
				m_newGuideHandle()
				m_newGuideHandle = nil
			end
		else
			if m_newGuideHandle~= nil then 
				m_newGuideHandle()
				m_newGuideHandle = nil
			end			
		end
	end

	-- if MainCityLogic.isOpen() then
	-- 	GuideDatas.continueNewGUide(m_newGuideData)--新手引导未全部完成
	-- end
end

function getBoxInfo()
	return m_boxInfo
end
function getDailyTaskInfo()
	return m_dailyTask
end
function getDailyTaskReward(type,dailyTaskID,handler)
 	m_dailyRewardType = type
	m_getDailyRewardTaskID = dailyTaskID
	m_dailyTaskHandler = handler
	NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_GET_EVEYDAY_REWARD, {m_dailyRewardType,m_getDailyRewardTaskID});
end

function getTasksInfo(handle)
	m_dailyTaskHandler = handle
	NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_EVERYDAYTASK, {0});	 --日常任务信息
		--赏金任务
		--主线任务
end
function setNewStep(step)
	m_newGuideData["step"] = step
end
-- function getNewStep(step)
-- 	m_newGuideData["step"] = step
-- end
function getNewGuideInfo()
	return m_newGuideData
end
function sendNewGuide(params,handle)
	if sendNewGuideIndex  == params[1] then
		return
	else
		sendNewGuideIndex  = params[1]
	end
	m_newGuideHandle = handle
	NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_NEW_GUIDE, params);	
end

function setLocalStepRecord(index)
	m_localStepRecord = index
end
function getLocalStepRecord()
	return m_localStepRecord
end

--是否第一次战斗展示
function checkFirstShowBattle()
	if  m_newGuideData["step"] == 0 then
		if m_newGuideData["bSuccess"]==0 then--第一次登录
			if BattleManager.isDebugMode() then 
		    	return true
			end
		end	
	end
	return false
end



function checkNotification()
    for k,v in pairs(m_daliyActivaties) do
        if v["state"] ==1  then
            return true
        end

    end
    for k,v in pairs(m_achievementData) do
    	if v["bfinish"] ~= 1 then
    		if v["current_time"] >= v["total_time"] then 
    			return true
    		end
    	end
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
NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_EVERYDAYTASKRESP, onRecieveDailyTaskInfo);--每日任务
NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_GET_EVEYDAY_BSUCCESS, onRecieveGetDailyTaskReward);--每日任务奖励
-- NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_NEW_GUID_RESP, onRecieveNewGuide);--新手引导系统
NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_ACHEVEMENT_LIST, onRecieveAchievementData);--成就系统
NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_ACHEVEMENT_REWARD_LIST, onRecieveAchievementRewardData);--成就系统

