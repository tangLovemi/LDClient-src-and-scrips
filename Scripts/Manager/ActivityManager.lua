module("ActivityManager", package.seeall)


-- local m_info = nil;
local m_info = nil;
function registMessage()--注册信息
	NetMessageManager.registerMessage(NETWORK_MESSAGE_RECEIVE_ACT_INSTANCE_INFO, Response);
end



function Response(messageType, messageData)
	if(m_info == nil)then
		m_info = {};
	end
	-- messageData
	for i=1,#messageData/2 do
		local data = messageData[i];
		local res = {};
		res.isOpen = data.limits;
		m_info[tonumber(data.b_open)] = res;
	end
	for i = #messageData/2+1,#messageData do
		local data = messageData[i];
		m_info[tonumber(data.b_open)].times = data.limits;
	end
	ActivityType.init();
end

function getInfo()
	return m_info;
end

function getTable(id)
	return m_info[id];
end

function getValue(id,index)
	return m_info[id][index];
end


function hasData()
	if(m_info == nil)then
		return false;
	end
	return true;
end

