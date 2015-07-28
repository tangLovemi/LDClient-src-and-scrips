module("BattleBuff", package.seeall)

local m_database = nil;

function loadBuffFile(fileName)
	local content = SJTxtFile:openFile(fileName);
	m_database = json.decode(content);
end

function getBuffCount()
	return #m_database;
end

function getEffectCount(buff)
	return #m_database[buff].effects;
end

function getEffectType(buff, index)
	return m_database[buff]["effects"][index].type;
end

function getEffectValues(buff, index)
	return m_database[buff]["effects"][index].values;
end