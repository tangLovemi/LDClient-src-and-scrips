module("Mission", package.seeall)

require (PATH_SCRIPT_SCENE_MISSION .. "Dialog")
require (PATH_SCRIPT_SCENE_MISSION .. "CounterMonster")
require (PATH_SCRIPT_SCENE_MISSION .. "Collection")
require (PATH_SCRIPT_SCENE_MISSION .. "Equipment")
require (PATH_SCRIPT_SCENE_MISSION .. "Walk")
require (PATH_SCRIPT_SCENE_MISSION .. "Activity")

local m_closeCB = nil;
local m_delegate = nil;

local TYPE_DIALOG			 = 0;  --对话任务
local TYPE_COUNTER_MONSTER   = 1;  --打怪任务
local TYPE_COLLECTION  		 = 2;  --收集任务
local TYPE_EQUIP    		 = 3;  --装备任务
local TYPE_WALK   		 	 = 4;  --走路任务
local TYPE_ACTIVITY 		 = 5;  --参加活动任务

local TYPE_COUNTER_MONSTER_GET = 2;  --打怪任务，接受
local TYPE_COUNTER_MONSTER_SET = 3;  --打怪任务，完成

local TYPE_COLLECTION_GET	   = 4;  --收集任务，接受
local TYPE_COLLECTION_SET	   = 5;  --收集任务，完成

local TYPE_EQUIP_GET		 = 6;  --装备任务，接受
local TYPE_EQUIP_SET		 = 7;  --装备任务，完成

local TYPE_WALK_GET		 	 = 8;  --走路任务，接受
local TYPE_WALK_SET		 	 = 9;  --走路任务，完成

local TYPE_ACTIVITY_GET		 = 10; --参加活动任务，接受
local TYPE_ACTIVITY_SET		 = 11; --参加活动任务，完成


-- 对话0 打怪2 收集4 装备6 走路8 参加活动10
function clearMission()
	CloseButton.close();
	CloseButton.remove();
	_G[m_delegate].close();

    MainCityLogic.registerTouchFunction();
    if(m_closeCB) then
    	m_closeCB();
    end
end

function showMission(sceneId, npcName, closeCB)
	m_closeCB = closeCB;

	MainCityLogic.unregisterTouchFunction();

	CloseButton.create();
	CloseButton.open(clearMission);
	requestMission(sceneId, npcName);
end

function onReceiveMissionMsg(messageType, messageData)
	ProgressRadial.close();
	--得到任务数据，根据任务id查表得到数据内容显示UI
	--messageData = {id = , type = }
	print("missionId = " .. messageData.id);
	print("missionType = " .. messageData.type);
	local typeId = messageData.type;
	if(typeId == TYPE_DIALOG) then
		m_delegate = "Dialog";
	elseif(typeId == TYPE_COUNTER_MONSTER) then
		m_delegate = "CounterMonster";
	elseif(typeId == TYPE_COLLECTION) then
		m_delegate =  "Collection";
	elseif(typeId == TYPE_EQUIP) then
		m_delegate = "Equipment";
	elseif(typeId == TYPE_WALK) then
		m_delegate = "Walk";
	elseif(typeId == TYPE_ACTIVITY) then
		m_delegate = "Activity";
	end
	_G[m_delegate].open(messageData.id, clearMission);
end

function registerMissionMsg()
	NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_GETMISSION, onReceiveMissionMsg);
end

function unregisterMissionMsg()
	NetMessageManager.unregisterMessage(NETWORK_MESSAGE_RECEIVE_GETMISSION, onReceiveMissionMsg);
end

function requestMission(sceneId, npcName)
	ProgressRadial.open();
	NetMessageManager.sendMessage(NETWORK_MESSAGE_SEND_MISSIONREQUEST, {sceneId, npcName});
end