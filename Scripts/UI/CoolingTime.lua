module("CoolingTime",package.seeall)

require (PATH_SCRIPT_SYSTEM .. "DocManager")

ROBCOOLINGTIME_INDEX   = 1

COOLINGTIMETABLECOUNT  = 1 --table的数量

ROBCOOLINGTIME         = 10 * 60 -- 10分钟


local m_coolingTimeTable = {};
local m_closeTime        = nil;

local function saveData()
	-- body
	DocManager.saveInt("coolingTableCount",#m_coolingTimeTable);
	DocManager.saveInt("closeTime",m_closeTime);
	DocManager.saveArrayInt("coolingTimeTable",m_coolingTimeTable);
	DocManager.flush();
end 

function insertCoolingTime(time)
	-- body
	
	local closeTime = os.time();
	m_closeTime = closeTime;

	table.insert(m_coolingTimeTable,time);
	saveData();

end


function saveCoolingtime(timeData,index)
	-- body
	local closeTime = os.time();
	m_coolingTimeTable[index] = timeData;
	m_closeTime = closeTime;
	saveData();

end

function getCoolingTime(index)
	-- body
	loadingData();
	return m_coolingTimeTable[index]; 

end

local function loadingData()
	-- body
	local tableCount = DocManager.loadInt("coolingTableCount");

	if tableCount == 0 then
		tableCount = 1;
	end

	m_coolingTimeTable = DocManager.loadArrayInt("coolingTimeTable",tableCount);
	m_closeTime = DocManager.loadInt("closeTime");

end 

function getCoolingTime(index)
	-- body
	loadingData();

	local coolingIndex = 1;
	local sumTime = 0;
	if index == 1 then
		coolingIndex = ROBCOOLINGTIME_INDEX;
		sumTime = ROBCOOLINGTIME;
	end

	local time = m_coolingTimeTable[coolingIndex];

	local openTime = os.time();
	local subTime = openTime - m_closeTime;

	if time == 0 or time == nil then

		time = ROBCOOLINGTIME;
	else 

		if time < subTime then
			time = 0;
		else
			time = time - subTime;
		end

	end



	return time;

end

--time单位：秒
function timeChangeString(time)
	local day = math.floor(time/(3600*24));
	local hour1        = time / 3600;
	local hour       = math.floor(hour1);
	local oneTime1    = math.mod(time,3600);
	local min         = math.floor(oneTime1 / 60);
	local sec1         = math.floor(oneTime1);
    local sec         = math.mod(sec1,60);
	if(hour >= 0 and min >= 0 and sec >= 0) then
		-- if(day > 0) then
		-- 	return string.format("%02d天%02d时%02d分%02d秒",day,hour,min,sec);
		-- else
		-- 	return string.format("%02d:%02d:%02d",hour,min,sec);
		-- end
		return string.format("%02d:%02d:%02d",hour,min,sec);
	else
		return "00:00:00";
	end
end