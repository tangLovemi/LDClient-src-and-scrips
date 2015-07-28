module("normalEquipment_intensifyNew", package.seeall)

local moduleName = "normalEquipment_intensifyNew";
local m_database = {};
_G[moduleName] = m_database;


function loadData( itemKey, key, value )
	if(m_database[itemKey] == nil) then
		m_database[itemKey] = {};
	end
	m_database[itemKey][key] = value;
end
