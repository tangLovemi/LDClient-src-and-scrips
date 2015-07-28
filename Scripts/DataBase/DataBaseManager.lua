module("DataBaseManager", package.seeall)

local m_loadFileNames = 
{
	"ActivityLevelData",
	"ActivityTypeData",
	"LevelData",
	"sceneSetData",
	"exp",
	"instance_box",
	"FailMsg",
	"MainCityScene",
	"drop",
	"WorldMapArea"
}

function init()
	for i = 1, #m_loadFileNames do
		require("DataMgr/ConfigureData/" .. m_loadFileNames[i]);--load lua file 
	end
end

function getTableByName(name)--get one lua file by file name
	local temp = _G[name];

	return _G[name];
end

function getData(fileName,index)
	return getTableByName(fileName)[index];
end


function getValue(fileName,index,key)
	if(getData(fileName,index) == nil)then
		return nil;
	else
		return getTableByName(fileName)[index][key];
	end
end