module("DocManager", package.seeall)

local m_userDefault = CCUserDefault:sharedUserDefault();

function loadString( key )
	local value = m_userDefault:getStringForKey(key);
	return value;
end

function loadInt(key)
	local value = m_userDefault:getIntegerForKey(key);
	return value;
end

function loadBool(key)
	local value = m_userDefault:getBoolForKey(key);
	return value;
end

function loadFloat(key)
	local value = m_userDefault:getFloatForKey(key);
	return value;
end

function loadArrayInt(key, length)
	local values = {};
	for i = 1, length do
		local newKey = key .. "_" .. i;
		values[i] = m_userDefault:getIntegerForKey(newKey);
	end
	return values;
end

function loadArrayBool(key, length)
	local values = {};
	for i = 1, length do
		local newKey = key .. "_" .. i;
		values[i] = m_userDefault:getBoolForKey(newKey);
	end
	return values;
end

function saveString(key, value)
	m_userDefault:setStringForKey(key, value);
end

function saveInt(key, value)
	m_userDefault:setIntegerForKey(key, value);
end

function saveBool(key, value)
	m_userDefault:setBoolForKey(key, value);
end

function saveFloat(key, value)
	m_userDefault:setFloatForKey(key, value);
end

function saveArrayInt(key, values)
	for i, value in ipairs(values) do
		m_userDefault:setIntegerForKey(key .. "_" .. i, value);
	end
end

function saveArrayBool(key, values)
	for i, value in ipairs(values) do
		m_userDefault:setBoolForKey(key .. "_" .. i, value);
	end
end

function flush()
    m_userDefault:flush();
end