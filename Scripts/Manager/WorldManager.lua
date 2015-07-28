module("WorldManager", package.seeall)

-- local data1 = {id=1,level=0};


local m_levelInfo = {};
local m_curOpenMap = 1;--当前开启的区域id
local m_isReceived = false;
local m_judianArray = {};
local m_MapBoxState = {};
local m_rewards = {};
local m_curBattleMap = 1;
local DEFAULT_TIMES = 3;
local m_curData = nil;
local taskMapId = nil
local m_unLockID = 0;
local m_curJuDdianID = 0;
local m_needOpenSelectLevel = false;
local function addData(id)
	local mapid = DataBaseManager.getValue(MAP_DATA_NAME, DATABASE_HEAD .. id, "belong");
	if(mapid > m_curOpenMap)then
		m_curOpenMap = mapid;
	end
	local judian = tonumber(DataBaseManager.getValue(MAP_DATA_NAME, DATABASE_HEAD .. id, "judian"));
	if(judian > m_curJuDdianID)then
		m_curJuDdianID = judian;
	end
end
local function onLock_back(messageType, messageData)--接收解锁信息
	m_levelInfo[messageData.stage_id].level = messageData.level;
	m_levelInfo[messageData.stage_id].lock = messageData.lock;
	addData(messageData.stage_id);
end

function getCurJuDdianID()
	return m_curJuDdianID;
end

function init()
	for m,n in pairs(DataBaseManager.getTableByName(DATA_BASE_MAP_LEVEL))do
		local data = {};
		data.id = n.id;
		data.level = 0;
		data.lock = -1;--0开启，1打过
		m_levelInfo[data.id] = data;
		if(DataBaseManager.getValue(DATA_BASE_MAP_LEVEL, DATABASE_HEAD .. n.id, "mode") == 2)then
			data.level = DEFAULT_TIMES;
		end
	end
end

function across(id)
	if(DataBaseManager.getValue(DATA_BASE_MAP_LEVEL, DATABASE_HEAD .. id, "type") == 1)then--小关
		m_levelInfo[id].lock = -1;
	else
		m_levelInfo[id].lock = 1;
	end
end

local function onInfo_back(messageType, messageData)--接收所有信息
	
	for i,info in ipairs(messageData) do
		m_levelInfo[info.stage_id].level = info.level;
		m_levelInfo[info.stage_id].lock = info.lock;
		addData(info.stage_id);
	end
	m_isReceived = true;
end

local function onUnLock_Notify(messageType, messageData)
	setUnLockID(messageData.id);
end

local function onIsSuccess_back(messageType, messageData)
	if(messageData.isOk == 1)then
		setUnLockID(0);
	end
end

function getMaxEliteID()
	local temp = 0;
	for i,v in pairs(m_levelInfo)do
		if(v.id > temp)then
			temp = v.id;
		end
	end
	return temp;
end

function isHasElite(id)
	for i,v in pairs(m_levelInfo)do
		if(v.id == id)then
			return true;
		end
	end
	return false;
end

function getCUrOpenMap()
	return m_curOpenMap;
end

function sort()

end

function getInfo()
	return m_levelInfo;
end

function getInfoByID(id)
	return m_levelInfo[id];
end


function getStarByID(id)
	return m_levelInfo[id].level;
end

function getJuDianInfo()
	return m_judianArray;
end

function registMessage()
	-- m_MapBoxState
	NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_UNLOCK_STAGE, onLock_back);
	NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_ALL_STAGE_INFO, onInfo_back);
	NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_UNLOCK_AREA, onUnLock_Notify);
	NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_UNLOCK_ISSUCCESS, onIsSuccess_back);
	init();
end

function isUnLock(id)
	if(DataBaseManager.getValue(DATA_BASE_MAP_LEVEL, DATABASE_HEAD .. id, "type") == 1)then
		if(m_levelInfo[id].lock ~= 0)then
			return false;
		end
	else
		if(m_levelInfo[id].lock < 0)then
			return false;
		end
	end
	return true;
end

function getOPenID()
	-- return m_curOpenMap;
	return 20;
end

function hasReceived()
	return m_isReceived;
end

function isOpenJuDian(judian)
	for i,v in pairs(m_judianArray)do
		if(v == judian)then
			return true;
		end
	end
	return false;
end

function getCurBattleMap()
	return m_curBattleMap;
end

function setCurBattleMap(id)
	m_curBattleMap = id;
end

function setCurData(data)
	m_curData = data;
end

function getCurData()
	return m_curData;
end

function isNeedStar()
	if(m_curData == nil)then
		return false;
	end
	if(m_curData.type == 1 and m_curData.subType == 1 and DataBaseManager.getValue(DATA_BASE_MAP_LEVEL, DATABASE_HEAD .. m_curData.id, "mode") == 1 and DataBaseManager.getValue(DATA_BASE_MAP_LEVEL, DATABASE_HEAD .. m_curData.id, "type") == 2)then
		return true;
	end
	return false;
end

function setNeedOpenSelectLevel(need)
	m_needOpenSelectLevel = need;
end

function getNeedOpenSelectLevel()
	return m_needOpenSelectLevel;
end

function setTaskMapId(mapId)
	taskMapId = mapId
end

function getTaskMapId()
	return taskMapId 
end

function isUnLockLevel(level)
	for i,v in pairs(m_levelInfo)do
		if(level >= 5000)then
			if(v.id  >=  level)then
				return true;
			end
		else
			if(v.id < 5000 and v.id  >=  level)then
				return true
			end
		end
	end
	return false;
end

function isAcross(id)
	return m_levelInfo[id].lock > 0;
end

function getUnLockID()
	return m_unLockID;
end

function setUnLockID(id)
	m_unLockID = id;
end